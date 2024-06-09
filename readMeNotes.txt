# for flutter web app

create CORS.json

gcloud init

gcloud config set project YOUR_PROJECT_ID
gsutil cors set cors.json gs://YOUR_BUCKET_NAME
gsutil cors get gs://<your-bucket-name>

*flutter clean
*flutter build web

firebase init
*firebase deploy --only hosting,firestore,database,storage,auth,remoteconfig,extensions
