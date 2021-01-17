# Lab: Using GCP services to implement the CQRS pattern in microservices architecture

Disclaimer: This is not an official Google product.

## Products
- [Cloud Run][1]
- [Datastore][2]
- [Pub/Sub][3]
- [Cloud Scheduler][4]

[1]: https://cloud.google.com/run
[2]: https://cloud.google.com/datastore
[3]: https://cloud.google.com/pubsub
[4]: https://cloud.google.com/scheduler


## Language
- [Python][6]

[6]: https://www.python.org/

## Introduction

## Build the example application

### Prerequisites

1. A Google Cloud Platform Account

1. [A new Google Cloud Platform Project][8] for this lab with billing enabled

1. Select "Datastore mode" from [the Datastore menu on Cloud Console][0].

[8]: https://console.cloud.google.com/project
[9]: https://console.cloud.google.com/apis/library
[0]: https://console.cloud.google.com/datastore

## Do this first

In this section you will start your [Google Cloud Shell][10] and clone the application code repository to it.

1. [Open the Cloud Console][11]

1. Click the Google Cloud Shell icon in the top-right and wait for your shell to open.

1. Set your project ID in the environment variable.

```shell
PROJECT_ID=[your project ID]
```

3. Set project ID in the session.

```shell
gcloud config set project $PROJECT_ID
```

4. Enable the Cloud Run API, Cloud Build API and Cloud Scheduler API.

```shell
gcloud services enable \
  run.googleapis.com \
  cloudbuild.googleapis.com \
  cloudscheduler.googleapis.com
```

5. Clone the lab repository in your cloud shell.

```shell
cd $HOME
git clone https://github.com/GoogleCloudPlatform/transactional-microservice-examples
```

[10]: https://cloud.google.com/cloud-shell/docs/
[11]: https://console.cloud.google.com/

## Deploy server-side components for the "Choreography-based saga" architecture

### Build container images and deploy them on Cloud Run

```shell
cd $HOME/transactional-microservice-examples/cqrs/services/order
gcloud builds submit --tag gcr.io/$PROJECT_ID/order-service-cqrs
gcloud run deploy order-service-cqrs \
  --image gcr.io/$PROJECT_ID/order-service-cqrs \
  --platform=managed --region=us-central1 \
  --no-allow-unauthenticated

cd $HOME/transactional-microservice-examples/cqrs/services/product
gcloud builds submit --tag gcr.io/$PROJECT_ID/product-service-cqrs
gcloud run deploy product-service-cqrs \
  --image gcr.io/$PROJECT_ID/product-service-cqrs \
  --platform=managed --region=us-central1 \
  --no-allow-unauthenticated

SERVICE_NAME="product-service-cqrs"
SERVICE_URL=$(gcloud run services list --platform managed \
    --format="table[no-heading](URL)" --filter="metadata.name:${SERVICE_NAME}")

cd $HOME/transactional-microservice-examples/cqrs/services/orderinfo
gcloud builds submit --tag gcr.io/$PROJECT_ID/orderinfo-service-cqrs
gcloud run deploy orderinfo-service-cqrs \
  --image gcr.io/$PROJECT_ID/orderinfo-service-cqrs \
  --platform=managed --region=us-central1 \
  --no-allow-unauthenticated \
  --set-env-vars "PRODUCT_SERVICE_URL=$PRODUCT_SERVICE_URL"

cd $HOME/transactional-microservice-examples/cqrs/services/event-publisher
gcloud builds submit --tag gcr.io/$PROJECT_ID/event-publisher
gcloud run deploy event-publisher \
  --image gcr.io/$PROJECT_ID/event-publisher \
  --platform=managed --region=us-central1 \
  --no-allow-unauthenticated \
  --set-env-vars "PROJECT_ID=$PROJECT_ID"
```

Create a BQ table for order information.

```shell
cd $HOME/transactional-microservice-examples/cqrs/services/orderinfo
bq mk --dataset $PROJECT_ID:cqrs_example
bq mk --table cqrs_example.order_information table_schema.json
```

Create an index for Datastore.

```shell
cd $HOME/transactional-microservice-examples/cqrs/services/orderinfo
gcloud datastore indexes create index.yaml --quiet

cd $HOME/transactional-microservice-examples/cqrs/services/event-publisher
gcloud datastore indexes create index.yaml --quiet
```

Open [the Datastore's index menu][13] on Cloud Console and wait a few minutes until the index becomes ready.

[13]: https://console.cloud.google.com/datastore/indexes

### Create a service account to invoke microservices on Cloud Run

You need a service account with an appropriate role to invoke REST APIs of microservices running on Cloud Run.

```shell
SERVICE_ACCOUNT_NAME="cloud-run-invoker"
SERVICE_ACCOUNT_EMAIL=${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
  --display-name "Cloud Run Invoker"
```

### Define schedule to call the Event Publisher service

In this example, you define a schedule that calls the Event Publisher service in every minute. You let Scheduler use the service account, that you created in the previous step, to call the Event Publisher service with `run.invoker` role.

```shell
SERVICE_NAME="event-publisher"
gcloud run services add-iam-policy-binding $SERVICE_NAME \
    --member=serviceAccount:$SERVICE_ACCOUNT_EMAIL \
    --role=roles/run.invoker \
    --platform=managed --region=us-central1

SERVICE_URL=$(gcloud run services list --platform managed \
    --format="table[no-heading](URL)" --filter="metadata.name:$SERVICE_NAME")
gcloud scheduler jobs create http event-publisher-scheduler \
       --schedule='* * * * *' \
       --http-method=GET \
       --uri=${SERVICE_URL}/api/v1/event/publish \
       --oidc-service-account-email=$SERVICE_ACCOUNT_EMAIL \
       --oidc-token-audience=${SERVICE_URL}/api/v1/event/publish
```

### Create Pub/Sub topics

The topic `order-service-cqrs-event` is used to publish events from the Order service.

```shell
gcloud pubsub topics create order-service-cqrs-event 
```

### Define push-subscriptions to notify events to microservices

First, you assign `iam.serviceAccountTokenCreator` role to the project's Pub/Sub service account so that it can create an access token that is used to invoke microservices on Cloud Run.

```shell
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format "value(projectNumber)")
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-pubsub.iam.gserviceaccount.com \
  --role=roles/iam.serviceAccountTokenCreator
```

You create a push-subscription that delivers messages in the `order-service-cqrs-event` topic to the Order Information service. You let Pub/Sub use the service account, that you created before, to invoke the Customer service with `run.invoker` role.

```shell
SERVICE_NAME="orderinfo-service-cqrs"
SERVICE_URL=$(gcloud run services list --platform managed \
  --format="table[no-heading](URL)" --filter="metadata.name:${SERVICE_NAME}")

gcloud run services add-iam-policy-binding $SERVICE_NAME \
  --member=serviceAccount:$SERVICE_ACCOUNT_EMAIL \
  --role=roles/run.invoker \
  --platform=managed --region=us-central1

gcloud pubsub subscriptions create push-order-to-orderinfo \
  --topic order-service-cqrs-event \
  --push-endpoint=${SERVICE_URL}/api/v1/orderinfo/pubsub \
  --push-auth-service-account=$SERVICE_ACCOUNT_EMAIL
```

## Test the server-side components

Before using a web client, you test the server-side components using the `curl` command.

Set environment variables to point URLs of API endpoints of microservices.

```shell
SERVICE_NAME="order-service-cqrs"
ORDER_SERVICE_URL=$(gcloud run services list --platform managed \
    --format="table[no-heading](URL)" --filter="metadata.name:${SERVICE_NAME}")

SERVICE_NAME="product-service-cqrs"
PRODUCT_SERVICE_URL=$(gcloud run services list --platform managed \
    --format="table[no-heading](URL)" --filter="metadata.name:${SERVICE_NAME}")

SERVICE_NAME="orderinfo-service-cqrs"
ORDERINFO_SERVICE_URL=$(gcloud run services list --platform managed \
    --format="table[no-heading](URL)" --filter="metadata.name:${SERVICE_NAME}")
```

Create a new product entry.

```shell
curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d '{"product_id":"product00001", "product_name":"Gaming Display", "unit_price": 800}' \
  -s $PRODUCT_SERVICE_URL/api/v1/product/create | jq .
```
[Output]
```json
{
  "product_id": "product00001",
  "product_name": "Gaming Display",
  "unit_price": 800
}
```

```shell
curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d '{"product_id":"product00001"}' \
  -s $PRODUCT_SERVICE_URL/api/v1/product/get | jq .

{
  "product_id": "product00001",
  "product_name": "Gaming Display",
  "unit_price": 800
}


curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d '{"customer_id":"customer01", "product_id": "product00001", "number":3}' \
  -s $ORDER_SERVICE_URL/api/v1/order/create | jq .

{
  "customer_id": "customer01",
  "number": 3,
  "order_date": "2021-01-17",
  "order_id": "551479ac-c665-43b7-aa35-f00b11c3219f",
  "product_id": "product00001"
}

ORDER_ID="551479ac-c665-43b7-aa35-f00b11c3219f"

curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d "{\"customer_id\":\"customer01\", \"order_id\": \"$ORDER_ID\"}" \
  -s $ORDERINFO_SERVICE_URL/api/v1/orderinfo/get | jq .
  
{
  "message": "The order does not exist."
}

curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d "{\"customer_id\":\"customer01\", \"order_id\": \"$ORDER_ID\"}" \
  -s $ORDERINFO_SERVICE_URL/api/v1/orderinfo/get | jq .

{
  "customer_id": "customer01",
  "number": 3,
  "order_date": "2021-01-17",
  "order_id": "551479ac-c665-43b7-aa35-f00b11c3219f",
  "product_id": "product00001",
  "product_name": "Gaming Display",
  "total_price": 2400,
  "unit_price": 800
}


====

curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d '{"customer_id":"customer01", "product_id": "product00001", "number":5}' \
  -s $ORDER_SERVICE_URL/api/v1/order/create | jq .

curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d '{"customer_id":"customer01", "product_id": "product00001", "number":3, "order_date": "2020-12-31"}' \
  -s $ORDER_SERVICE_URL/api/v1/order/create | jq .

curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d '{"customer_id":"customer01", "order_date": "2021-01"}' \
  -s $ORDERINFO_SERVICE_URL/api/v1/orderinfo/list | jq .

{
  "order_date": "2021-01",
  "orders": [
    {
      "customer_id": "customer01",
      "number": 3,
      "order_date": "2021-01-17",
      "order_id": "551479ac-c665-43b7-aa35-f00b11c3219f",
      "product_id": "product00001",
      "product_name": "Gaming Display",
      "total_price": 2400,
      "unit_price": 800
    },
    {
      "customer_id": "customer01",
      "number": 5,
      "order_date": "2021-01-17",
      "order_id": "c3abe0eb-481c-4b31-8d34-d344b6e6b9ce",
      "product_id": "product00001",
      "product_name": "Gaming Display",
      "total_price": 4000,
      "unit_price": 800
    }
  ]
}


curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d '{"customer_id":"customer01", "order_date": "2020"}' \
  -s $ORDERINFO_SERVICE_URL/api/v1/orderinfo/list | jq .

{
  "order_date": "2020-12",
  "orders": [
    {
      "customer_id": "customer01",
      "number": 3,
      "order_date": "2020-12-31",
      "order_id": "cd790c68-2b07-4fbe-b033-66e6e552b79f",
      "product_id": "product00001",
      "product_name": "Gaming Display",
      "total_price": 2400,
      "unit_price": 800
    }
  ]
}

bq query "select product_name, count(*) as total_number, sum(total_price) as revenue \
  from cqrs_example.order_information group by product_name"
  
+----------------+--------------+---------+
|  product_name  | total_number | revenue |
+----------------+--------------+---------+
| Gaming Display |            2 |    6400 |
+----------------+--------------+---------+
```

