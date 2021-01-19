# Lab: Using GCP services to execute transactional workflows in microservices architecture

Disclaimer: This is not an official Google product.

## Products
- [Cloud Run][1]
- [Datastore][2]
- [Pub/Sub][3]
- [Cloud Scheduler][4]
- [Workflows][5]

[1]: https://cloud.google.com/run
[2]: https://cloud.google.com/datastore
[3]: https://cloud.google.com/pubsub
[4]: https://cloud.google.com/scheduler
[5]: https://cloud.google.com/workflows


## Language
- [Python][6]

[6]: https://www.python.org/

## Introduction
This is an example application that explains how you can execute transactional workflows in microservices architecture. There are several patterns to execute a transactional workflow in microservices. In this example, you use the following two patterns.

- Choreography-based saga
- Synchronous orchestration

### Choreography-based saga

In this pattern, microservices work as an autonomous distributed system. Each service publishes an event to notify the status change of entities owned by that service. The notification event triggers actions of other services. In this way, multiple services work together to complete a transactional process. The communication between microservices is completely asynchronous. When a service publishes an event, it doesn't know when and which service will receive it.

In this example, you use [Cloud Run][1] as a runtime of microservices, [Pub/Sub][3] as a messaging service to deliver events between microservices, and [Datastore][2] as a backend database of each service. In addition, you use Datastore to store events before publishing them. The stored events are published periodically using [Cloud Scheduler][4]. The reason why microservices store events instead of publish them immediately is explained in the later section.

### Synchronous orchestration

In this pattern, a single orchestrator controls the execution flow of a transaction. The communication between microservices and orchestrator is done synchronously through REST APIs.

In this example, you use Cloud Run as a runtime of microservices and Datastore as a backend database of each service. In addition, you use [Cloud Workflows][5] as an orchestrator.

## Usecase

This example application implements a simple usecase described at the web site [Microservice Architecture][7] with a little modification. Two microservices "Order service" and "Customer service" participate in the following transactional workflow.

[7]: https://microservices.io/patterns/data/saga.html

1. The customer submits an order request with specifying a customer ID and a number of items.
1. The Order service assigns an order ID, and stores the order information in the database. The status of the order is marked as "pending".
1. The Customer service increases the customer's credit usage, that is stored in the database, according to the number of ordered items.
1. If the total credit usage is lower than (or equal to) the predefined limit, the order is accepted and the Order service changes the status of the order in the database as "accepted".
1. Otherwise, the Order service changes the status of the order as "rejected". In this case, the customer's credit usage is not increased.

## Architecture

### Choreography-based saga

<img src="https://github.com/GoogleCloudPlatform/transactional-microservice-examples/blob/main/docs/img/choreography-architecture.png" width="640px">

As described in Introduction, two services communicate with each other through events. In this architecture, the customer's order is processed as below:

1. The customer submits an order request with specifying a customer ID and a number of items. The request is sent to the Order service through the REST API.

1. The Order service assigns an order ID, and stores the order information in the database. The status of the order is marked as "pending".The Order service returns the order information to the customer, and publishes an event containing the order information to the Pub/Sub topic "order-service-event".

1. The Customer service receives the event through a push notification. It increases the customer's credit usage, that is stored in the database, according to the number of ordered items.

1. If the total credit usage is lower than (or equal to) the predefined limit, the Customer service publishes an event containing the information that the credit increase has succeeded. Otherwise, it publishes an event containing the information that the credit increase has failed. In that case, the credit usage is not increased.

1. The Order service receives the event through a push notification. It changes the order status as "accepted" or "rejected" accordingly. The customer can track the status of the order using the order ID returned from the Order service.

### Notes on the event publishing process

When a microservice modifies its own data in the backend database and publishes an event to notify it, these two operations should be conducted in an atomic way. For example, if the microservice fails after modifying data without publishing an event, the transactional process halts there. It potentially leaves the data in an inconsistent state, across multiple microservices involved in the transaction. To avoid it, in this example application, the microservices write event data in the backend database, instead of directly publishing them. The modification of data and writing the associated event data are conducted in an atomic way using the transactional feature of the backend database. Later, another service, the Event Publisher service in this example, periodically scans the database and publishes events with which the "published" column is "False". After successfully publishing an event, it changes the "published" column to "True". 

<img src="https://github.com/GoogleCloudPlatform/transactional-microservice-examples/blob/main/docs/img/event-publishing-process.png" width="640px">

There is another consideration in terms of consistency in this process. If the Event Publisher service fails after publishing an event without changing the "published" column, it will publish the same event again after the recovery. Because it causes the duplicate event, the microservices that receive the event should check the duplication and handle it accordingly. In other words, it should guarantee the idempotence of the event handling. To deal with it, in this example application, the microservices update the backend database based on the business logic triggered by an event, and write its event id in the backend database. These two writes are conducted in an atomic way using the transactional feature of the backend database. If they receive the duplicate event, they can detect it by looking up the event id in the database. Note that handling duplicate events is a common practice when receiving events from Pub/Sub because Pub/Sub could cause the duplicate message delivery even though it's only in a rare situation.

<img src="https://github.com/GoogleCloudPlatform/transactional-microservice-examples/blob/main/docs/img/event-handling-process.png" width="420px">

### Synchronous orchestration

In this example, you use Workflows as an orchestrator. Workflows is a managed service that orchestrates and automates Google Cloud and HTTP-based API services with serverless workflows. Communication between microservices and Workflows are conducted in a synchronous way.

<img src="https://github.com/GoogleCloudPlatform/transactional-microservice-examples/blob/main/docs/img/orchestration-architecture.png" width="640px">

In this architecture, the customer's order is processed as below:

1. The customer submits an order request with specifying a customer ID and a number of items. The request is sent to the Order Processing service through the REST API.

1. The Order Processing service executes a workflow with passing the customer ID and the number of items to Workflows.

1. The workflow calls the Order service's REST API with passing the customer ID and the number of items. Then the Order service assigns an order ID, and stores the order information in the database. The status of the order is marked as "pending". The Order service returns the order information to the workflow.

1. The workflow calls the Customer service's REST API with passing the customer ID and the number of items. Then the Customer increases the customer's credit usage, that is stored in the database, according to the number of ordered items.

1. If the total credit usage is lower than (or equal to) the predefined limit, the Customer service returns data describing that the credit increase has succeeded. Otherwise, it returns data describing that the credit increase has failed. In that case, the credit usage is not increased.

1. The workflow calls the Order service's REST API to change the order status as "accepted" or "rejected" accordingly. Finally, it returns the order information in the final status to the Order Processing service. Then the Order Processing service return that information to the customer.

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

4. Enable the Cloud Run API, Workflows API, Cloud Build API and Cloud Scheduler API.

```shell
gcloud services enable \
  run.googleapis.com \
  workflows.googleapis.com \
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
cd $HOME/transactional-microservice-examples/services/order-async
gcloud builds submit --tag gcr.io/$PROJECT_ID/order-service-async
gcloud run deploy order-service-async \
  --image gcr.io/$PROJECT_ID/order-service-async \
  --platform=managed --region=us-central1 \
  --no-allow-unauthenticated

cd $HOME/transactional-microservice-examples/services/customer-async
gcloud builds submit --tag gcr.io/$PROJECT_ID/customer-service-async
gcloud run deploy customer-service-async \
  --image gcr.io/$PROJECT_ID/customer-service-async \
  --platform=managed --region=us-central1 \
  --no-allow-unauthenticated

cd $HOME/transactional-microservice-examples/services/event-publisher
gcloud builds submit --tag gcr.io/$PROJECT_ID/event-publisher
gcloud run deploy event-publisher \
  --image gcr.io/$PROJECT_ID/event-publisher \
  --platform=managed --region=us-central1 \
  --no-allow-unauthenticated \
  --set-env-vars "PROJECT_ID=$PROJECT_ID"
```

Create an index for Datastore.

```shell
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
SERVICE_URL="${SERVICE_URL}/api/v1/event/publish"
gcloud scheduler jobs create http event-publisher-scheduler \
       --schedule='* * * * *' \
       --http-method=GET \
       --uri=$SERVICE_URL \
       --oidc-service-account-email=$SERVICE_ACCOUNT_EMAIL \
       --oidc-token-audience=$SERVICE_URL
```

### Create Pub/Sub topics

The topic `order-service-event` is used to publish events from the Order service, and the topic `customer-service-event` is used to publish events from the Customer service.

```shell
gcloud pubsub topics create order-service-event
gcloud pubsub topics create customer-service-event
```

### Define push-subscriptions to notify events to microservices

First, you assign `iam.serviceAccountTokenCreator` role to the project's Pub/Sub service account so that it can create an access token that is used to invoke microservices on Cloud Run.

```shell
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format "value(projectNumber)")
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-pubsub.iam.gserviceaccount.com \
  --role=roles/iam.serviceAccountTokenCreator
```

You create a push-subscription that delivers messages in the `order-service-event` topic to the Customer service. You let Pub/Sub use the service account, that you created before, to invoke the Customer service with `run.invoker` role.

```shell
SERVICE_NAME="customer-service-async"
SERVICE_URL=$(gcloud run services list --platform managed \
  --format="table[no-heading](URL)" --filter="metadata.name:${SERVICE_NAME}")
SERVICE_URL="${SERVICE_URL}/api/v1/customer/pubsub"

gcloud run services add-iam-policy-binding $SERVICE_NAME \
  --member=serviceAccount:$SERVICE_ACCOUNT_EMAIL \
  --role=roles/run.invoker \
  --platform=managed --region=us-central1

gcloud pubsub subscriptions create push-order-to-customer \
  --topic order-service-event \
  --push-endpoint=$SERVICE_URL \
  --push-auth-service-account=$SERVICE_ACCOUNT_EMAIL
```

You create a push-subscription that delivers messages in the `customer-service-event` topic to the Order service. You let Pub/Sub use the service account, that you created before, to invoke the Order service with `run.invoker` role.

```shell
SERVICE_NAME="order-service-async"
SERVICE_URL=$(gcloud run services list --platform managed \
  --format="table[no-heading](URL)" --filter="metadata.name:${SERVICE_NAME}")
SERVICE_URL="${SERVICE_URL}/api/v1/order/pubsub"

gcloud run services add-iam-policy-binding $SERVICE_NAME \
  --member=serviceAccount:$SERVICE_ACCOUNT_EMAIL \
  --role=roles/run.invoker \
  --platform=managed --region=us-central1

gcloud pubsub subscriptions create push-customer-to-order \
  --topic customer-service-event \
  --push-endpoint=$SERVICE_URL \
  --push-auth-service-account=$SERVICE_ACCOUNT_EMAIL
```

## Deploy server-side components for the "Synchronous orchestration" architecture.

### Build container images and deploy them on Cloud Run

```shell
cd $HOME/transactional-microservice-examples/services/order-sync
gcloud builds submit --tag gcr.io/$PROJECT_ID/order-service-sync
gcloud run deploy order-service-sync \
  --image gcr.io/$PROJECT_ID/order-service-sync \
  --platform=managed --region=us-central1 \
  --no-allow-unauthenticated

cd $HOME/transactional-microservice-examples/services/customer-sync
gcloud builds submit --tag gcr.io/$PROJECT_ID/customer-service-sync
gcloud run deploy customer-service-sync \
  --image gcr.io/$PROJECT_ID/customer-service-sync \
  --platform=managed --region=us-central1 \
  --no-allow-unauthenticated

cd $HOME/transactional-microservice-examples/services/order-processor
gcloud builds submit --tag gcr.io/$PROJECT_ID/order-processor-service
gcloud run deploy order-processor-service \
  --image gcr.io/$PROJECT_ID/order-processor-service \
  --platform=managed --region=us-central1 \
  --no-allow-unauthenticated \
  --set-env-vars "PROJECT_ID=$PROJECT_ID"
```

### Create a service account to invoke microservices on Cloud Run

You reuse the service account that you created in the previous step. So you don't create a new one here.

### Deploy a workflow to process an order

You let the workflow use the service account, that you created before, to invoke the Order service and the Customer service with role `run.invoker` and `run.viewer`.

```shell
SERVICE_NAME="order-service-sync"
gcloud run services add-iam-policy-binding $SERVICE_NAME \
    --member=serviceAccount:$SERVICE_ACCOUNT_EMAIL \
    --role=roles/run.invoker \
    --platform=managed --region=us-central1
gcloud run services add-iam-policy-binding $SERVICE_NAME \
    --member=serviceAccount:$SERVICE_ACCOUNT_EMAIL \
    --role=roles/run.viewer \
    --platform=managed --region=us-central1

SERVICE_NAME="customer-service-sync"
gcloud run services add-iam-policy-binding $SERVICE_NAME \
    --member=serviceAccount:$SERVICE_ACCOUNT_EMAIL \
    --role=roles/run.invoker \
    --platform=managed --region=us-central1
gcloud run services add-iam-policy-binding $SERVICE_NAME \
    --member=serviceAccount:$SERVICE_ACCOUNT_EMAIL \
    --role=roles/run.viewer \
    --platform=managed --region=us-central1
```

You deploy a workflow to process a customer's order.

```shell
SERVICE_NAME="customer-service-sync"
CUSTOMER_SERVICE_URL=$(gcloud run services list --platform managed \
    --format="table[no-heading](URL)" --filter="metadata.name:${SERVICE_NAME}")

SERVICE_NAME="order-service-sync"
ORDER_SERVICE_URL=$(gcloud run services list --platform managed \
    --format="table[no-heading](URL)" --filter="metadata.name:${SERVICE_NAME}")
    
cd $HOME/transactional-microservice-examples/services/order-processor
cp order_workflow.yaml.template order_workflow.yaml
sed -i "s#ORDER-SERVICE-URL#${ORDER_SERVICE_URL}#" order_workflow.yaml
sed -i "s#CUSTOMER-SERVICE-URL#${CUSTOMER_SERVICE_URL}#" order_workflow.yaml

gcloud beta workflows deploy order_workflow \
  --source=order_workflow.yaml \
  --service-account=$SERVICE_ACCOUNT_EMAIL
```

## Test the server-side components

Before using a web client, you test the server-side components using the `curl` command.

### "Choreography-based saga" architecture

Set environment variables to point URLs of API endpoints of microservices.

```shell
SERVICE_NAME="customer-service-async"
CUSTOMER_SERVICE_URL=$(gcloud run services list --platform managed \
    --format="table[no-heading](URL)" --filter="metadata.name:${SERVICE_NAME}")

SERVICE_NAME="order-service-async"
ORDER_SERVICE_URL=$(gcloud run services list --platform managed \
    --format="table[no-heading](URL)" --filter="metadata.name:${SERVICE_NAME}")
```

Create a new customer entry.

```shell
curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d '{"customer_id":"customer01", "limit":10000}' \
  -s ${CUSTOMER_SERVICE_URL}/api/v1/customer/limit | jq .
```
[Output]
```json
{
  "credit": 0,
  "customer_id": "customer01",
  "limit": 10000
}
```

Get a customer information.

```shell
curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d '{"customer_id":"customer01"}' \
  -s ${CUSTOMER_SERVICE_URL}/api/v1/customer/get | jq .
```
[Output]
```json
{
  "credit": 0,
  "customer_id": "customer01",
  "limit": "10000"
}
```

Submit a new order.

```shell
curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d '{"customer_id":"customer01", "number":10}' \
  -s ${ORDER_SERVICE_URL}/api/v1/order/create | jq .
```
[Output]
```json
{
  "customer_id": "customer01",
  "number": 10,
  "order_id": "7f51dcf1-877f-4e04-8aa9-d6d99cf50f67",
  "status": "pending"
}
```

Set an environment variable with the assigned `order_id`.

```shell
ORDER_ID="7f51dcf1-877f-4e04-8aa9-d6d99cf50f67"
```

Get the order information.

```shell
curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d "{\"customer_id\":\"customer01\", \"order_id\":\"$ORDER_ID\"}" \
  -s ${ORDER_SERVICE_URL}/api/v1/order/get | jq .
```
[Output]
```json
{
  "customer_id": "customer01",
  "number": 10,
  "order_id": "7f51dcf1-877f-4e04-8aa9-d6d99cf50f67",
  "status": "pending"
}
```

If the order process hasn't finished yet, the status is `pending`. In that case wait a few minutes and check the status again.

```shell
curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d "{\"customer_id\":\"customer01\", \"order_id\":\"$ORDER_ID\"}" \
  -s ${ORDER_SERVICE_URL}/api/v1/order/get | jq .
```
[Output]
```json
{
  "customer_id": "customer01",
  "number": 10,
  "order_id": "7f51dcf1-877f-4e04-8aa9-d6d99cf50f67",
  "status": "accepted"
}
```

The status is `accepted` now. Get the customer information.

```shell
curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d '{"customer_id":"customer01"}' \
  -s ${CUSTOMER_SERVICE_URL}/api/v1/customer/get | jq .
```
[Output]
```json
{
  "credit": 1000,
  "customer_id": "customer01",
  "limit": 10000
}
```

The credit has been increased by 1000. (The business logic behind it is to increase the credit by 100 for one item.)

Submit an order that will get the credit usage over the limit.

```shell
curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d '{"customer_id":"customer01", "number":95}' \
  -s ${ORDER_SERVICE_URL}/api/v1/order/create | jq .
```
[Output]
```json
{
  "customer_id": "customer01",
  "number": 95,
  "order_id": "9d749a13-b21d-4b19-a979-4e7f51f3598d",
  "status": "pending"
}
```

Set an environment variable with the assigned `order_id`.

```shell
ORDER_ID="9d749a13-b21d-4b19-a979-4e7f51f3598d"
```

Wait a few minutes, and get the order information.

```shell
curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d "{\"customer_id\":\"customer01\", \"order_id\":\"$ORDER_ID\"}" \
  -s ${ORDER_SERVICE_URL}/api/v1/order/get | jq .
```
[Output]
```json
{
  "customer_id": "customer01",
  "number": 95,
  "order_id": "9d749a13-b21d-4b19-a979-4e7f51f3598d",
  "status": "rejected"
}
```

The order status become `rejected` in this case. Get the customer information.

```shell
curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d '{"customer_id":"customer01"}' \
  -s ${CUSTOMER_SERVICE_URL}/api/v1/customer/get | jq .
```
[Output]
```json
{
  "credit": 1000,
  "customer_id": "customer01",
  "limit": 10000
}
```

The credit was not increased.

You can see the contents of the backend database from [the Datastore's entity menu][12] with the following Kind's.

- `Order`: Order information owned by the Order service
- `Customer`: Customer information owned by the Customer service
- `Event`: Event database
- `ProcessedEvent`: Processed event database

[12]: https://console.cloud.google.com/datastore/entities

### "Synchronous orchestration" architecture

Set environment variables to point URLs of API endpoints of microservices.

```shell
SERVICE_NAME="customer-service-sync"
CUSTOMER_SERVICE_URL=$(gcloud run services list --platform managed \
    --format="table[no-heading](URL)" --filter="metadata.name:${SERVICE_NAME}")

SERVICE_NAME="order-service-sync"
ORDER_SERVICE_URL=$(gcloud run services list --platform managed \
    --format="table[no-heading](URL)" --filter="metadata.name:${SERVICE_NAME}")

SERVICE_NAME="order-processor-service"
ORDER_PROCESSOR_URL=$(gcloud run services list --platform managed \
    --format="table[no-heading](URL)" --filter="metadata.name:${SERVICE_NAME}")
```

Create a new customer entry.

```shell
curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d '{"customer_id":"customer02", "limit":10000}' \
  -s ${CUSTOMER_SERVICE_URL}/api/v1/customer/limit | jq .
```
[Output]
```json
{
  "credit": 0,
  "customer_id": "customer02",
  "limit": 10000
}
```

Submit an order

```shell
curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d '{"customer_id":"customer02", "number":10}' \
  -s ${ORDER_PROCESSOR_URL}/api/v1/order/process | jq .
```
```json
{
  "customer_id": "customer02",
  "number": 10,
  "order_id": "fb6d5087-dd99-4d5a-84c2-0e381016b9d3",
  "status": "accepted"
}
```

Because the transaction process is conducted in a synchronous way, the client gets the final result. In this case, the final status is `accepted`.

Get the customer information.

```shell
curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d '{"customer_id":"customer02"}' \
  -s ${CUSTOMER_SERVICE_URL}/api/v1/customer/get | jq .
```
[Output]
```json
{
  "credit": 1000,
  "customer_id": "customer02",
  "limit": 10000
}
```

Submit an order that will get the credit usage over the limit.

```shell
curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d '{"customer_id":"customer02", "number":95}' \
  -s ${ORDER_PROCESSOR_URL}/api/v1/order/process | jq .
```
[Output]
```json
{
  "customer_id": "customer02",
  "number": 95,
  "order_id": "6b9c7e25-8999-437f-a8b2-dbedf5b8240f",
  "status": "rejected"
}
```

In this case, the final status is `rejected`.

## Access from a web application

Follow the [instruction](https://github.com/GoogleCloudPlatform/transactional-microservice-examples/blob/main/frontend/README.md) to deploy a web application example.


