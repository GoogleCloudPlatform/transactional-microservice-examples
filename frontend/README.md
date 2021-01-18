# Web frontend example

Disclaimer: This is not an official Google product.

## Introduction

This project works on top of the [example application](https://github.com/GoogleCloudPlatform/transactional-microservice-examples).

You deploy a web application using [Firebase Hosting](https://firebase.google.com/docs/hosting)
that interacts with backend microservices running on Cloud Run. Firebase hosting is natively
integrated with Cloud Run so that you can invoke services on Cloud Run with authentication.
In other types of deployment, you may have Cross-Origin Resource Sharing (CORS) issues. Refer
to the [link](https://cloud.google.com/run/docs/authenticating/end-users#web_apps_authentication_and_cors)
for details.

![Frontend architecture with Firebase Hosting](./docs/img/frontend_on_firebase_hosting_architecture.png)

## Prerequisites

1. Complete building the example application following the
   [instruction](https://github.com/GoogleCloudPlatform/transactional-microservice-examples/blob/main/README.md).

2. Open the Google Cloud Shell and set your project ID.

   ```shell
   PROJECT_ID=[your project ID]
   gcloud config set project $PROJECT_ID
   ```

3. We assume that you have cloned the lab repository in your cloud shell
   directory `$HOME/transactional-microservice-examples`.

## Create OAuth 2.0 Client

1. Open [OAuth consent screen](https://console.developers.google.com/apis/credentials/consent)
   from the APIs & Services menu on Cloud Console.

1. Check [External] and click [CREATE] button.

   1. OAuth consent screen.

      1. Input App name (e.g. `Saga Frontend Demo`).
      1. Select User support email.
      1. Input Developer contact information.
      1. Click [SAVE AND CONTINUE].

   1. Scopes

      1. Click [SAVE AND CONTINUE] to proceed.

   1. Test users

      1. Click [SAVE AND CONTINUE] to proceed.

   1. Summary

      1. Click [BACK TO DASHBOARD] to finish.

1. Open [Credentials](https://console.developers.google.com/apis/credentials)
   from the APIs & Services menu on Cloud Console.

   1. Click [+ CREATE CREDENTIALS] and select "OAuth client ID".
   1. Select "Web application" for Application type.
   1. Click [+ ADD URI] in the "Authorized JavaScript origins" section and
      set `https://[PROJECT ID].web.app` for URIs. (Replace `[PROJECT ID]` with your project ID.)
   1. Click [CREATE].
   1. Copy OAuth client ID from the "Your Client ID" field.

1. Set the client ID (that you copied in the previous step) in the environment variable.

   ```shell
   CLIENT_ID=[Client ID]
   ```

1. Redeploy Cloud Run services so that the services recognize the client.

   ```shell
   gcloud run deploy order-service-async \
     --image gcr.io/$PROJECT_ID/order-service-async \
     --platform=managed --region=us-central1 \
     --no-allow-unauthenticated

   gcloud run deploy customer-service-async \
     --image gcr.io/$PROJECT_ID/customer-service-async \
     --platform=managed --region=us-central1 \
     --no-allow-unauthenticated

   gcloud run deploy order-service-sync \
     --image gcr.io/$PROJECT_ID/order-service-sync \
     --platform=managed --region=us-central1 \
     --no-allow-unauthenticated

   gcloud run deploy customer-service-sync \
     --image gcr.io/$PROJECT_ID/customer-service-sync \
     --platform=managed --region=us-central1 \
     --no-allow-unauthenticated

   gcloud run deploy order-processor-service \
     --image gcr.io/$PROJECT_ID/order-processor-service \
     --platform=managed --region=us-central1 \
     --no-allow-unauthenticated \
     --set-env-vars "PROJECT_ID=$PROJECT_ID"
   ```

## Deploy the web frontend application

### Build the web frontend application

```bash
cd $HOME/transactional-microservice-examples/frontend
gcloud builds submit . --config=cloudbuild.yaml
```

### Download assets from Cloud Storage

```bash
gsutil -m cp -r gs://${PROJECT_ID}-web-frontend-example-assets/build ./web_frontend_example/
```

### Refreash the firebase admin credential

Login with your google account that is the owner of your project to refresh the firebase admin credential.

```shell
firebase login --reauth --no-localhost
```

Note: **The URL string displayed on the Cloud Shell may contain line breaks at the right end of the terminal.**
In that case, copy the URL string to your text editor and delete line breaks
before accessing the URL from your browser.

### Initialize the Firebase project

```shell
cd $HOME/transactional-microservice-examples/frontend
mkdir firebase_hosting
cd firebase_hosting
firebase init hosting
```

1. Select `Add Firebase to an existing Google Cloud Platform project`
1. Input the project ID that you used to deploy the backend services.
1. Press Enter Key for the name of public directory. (Use default name: public)
1. Press Enter Key for the configuration about single-page app. (Use default value: No)
1. Press Enter Key for setting up automatic builds. (Use default value: No)
1. Confirm you have successfully completed Firebase initialization.

### Update the frontend app to use the OAuth 2.0 Client ID

```shell
cp -r ../web_frontend_example/build/web/* public/
sed -i "s/__CLIENT_ID__/$CLIENT_ID/" public/index.html
```

### Deploy the frontend app with Firebase Hosting

```shell
cp ../firebase/firebase.json ./
firebase deploy
```

## Screens of the web frontend application

The web frontend application consists of two screens.

- Admin screen

  This is for administrative operations. You can call raw APIs and confirm raw requests and responses.

- Usecase screen

  This imitates the order process in an e-commerce application using APIs.

## Use the web frontend application - Admin screen

Open the `Hosting URL` url on your browser. Click [Sign in with Google] and sign in
with your Google account. You must use the account that is the GCP project owner.

### Create a new customer entry

Click "Customer" on the left menu, and select "limit" from the pull down menu.
Set "customer_id" and "limit" as in the screenshot and click [Send!].
You can choose the synchronous service (Sync) or the asynchronous service (Async)
with the slide switch. The result will be the same for both services.

<img src="https://github.com/GoogleCloudPlatform/transactional-microservice-examples/blob/main/frontend/docs/img/screenshot01.png" width="720px">

### Submit an order using the asynchronous service

Click "Order" on the left menu. Choose "Async" with the slide switch, and select
"create" from the pull down menu. Set "customer_id" and "number" as in the screenshot
and click [Send!]. The response shows that the order status is "pending" for now.
Take note of the "order_id".

<img src="https://github.com/GoogleCloudPlatform/transactional-microservice-examples/blob/main/frontend/docs/img/screenshot02.png" width="720px">

### Get the order status

Select "get" from the pull down menu. Set "customer_id" and "order_id" as in the
screenshot. The "order_id" should be replaced with the one that you took note in the
previous step. Click [Send!]. If the order status is still "pending", wait a few minutes
and click [Send!] again. Eventually, the status becomes "accepted".

<img src="https://github.com/GoogleCloudPlatform/transactional-microservice-examples/blob/main/frontend/docs/img/screenshot03.png" width="720px">

### Submit an order using the synchronous service

Click "Order" on the left menu. Choose "Sync" with the slide switch, and select
"process" (not "create") from the pull down menu. Set "customer_id" and "number" as in
the screenshot and click [Send!]. The response shows that the order status is "accepted".

<img src="https://github.com/GoogleCloudPlatform/transactional-microservice-examples/blob/main/frontend/docs/img/screenshot04.png" width="720px">

## Use the web frontend application - Usecase screen

Open the `Hosting URL` url on your browser. Click [Sign in with Google] and sign in
with your Google account. You must use the account that is the GCP project owner.
Click [To Usecase] button to switch to "Usecase" screen.

### Select the process

Click [Async] or [Sync]. You can choose which process to initiate on this page.

<img src="https://github.com/GoogleCloudPlatform/transactional-microservice-examples/blob/main/frontend/docs/img/screenshot05.png" width="720px">

### Create a customer

Set "customer_id" and "limit" and click [Create]. Wait for a moment
and you will see a green popup once it is completed successfully.

<img src="https://github.com/GoogleCloudPlatform/transactional-microservice-examples/blob/main/frontend/docs/img/screenshot06.png" width="720px">

### Submit an order

Set "Qty" and click [Submit order]. Wait for a moment
and you will see a green popup once it is completed successfully.

<img src="https://github.com/GoogleCloudPlatform/transactional-microservice-examples/blob/main/frontend/docs/img/screenshot07.png" width="720px">

### Confirm the result

In "Sync" process, confirm the result. Click [Start over] to restart the process.
In "Async" process, you will see "pending" as the order status.
It means that the order is still under processing. Keep clicking [Refresh]
until the order status becomes "accepted" or "rejected".

<img src="https://github.com/GoogleCloudPlatform/transactional-microservice-examples/blob/main/frontend/docs/img/screenshot08.png" width="720px">
