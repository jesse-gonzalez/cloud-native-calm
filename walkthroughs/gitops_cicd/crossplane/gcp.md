

### Configure GCP

gcloud organizations list

export EXAMPLE_PROJECT_ID=nutanixsademos
export EXAMPLE_SA="nutanixsademos-sa@$EXAMPLE_PROJECT_ID.iam.gserviceaccount.com"

> enable APIs
gcloud --project $EXAMPLE_PROJECT_ID services enable container.googleapis.com
gcloud --project $EXAMPLE_PROJECT_ID services enable sqladmin.googleapis.com
gcloud --project $EXAMPLE_PROJECT_ID services enable redis.googleapis.com
gcloud --project $EXAMPLE_PROJECT_ID services enable compute.googleapis.com
gcloud --project $EXAMPLE_PROJECT_ID services enable servicenetworking.googleapis.com

> configure service account (optional)
gcloud --project $EXAMPLE_PROJECT_ID iam service-accounts create nutanixsademos-sa --display-name "GCP Service Account - Nutanix SA"
gcloud --project $EXAMPLE_PROJECT_ID iam service-accounts keys create --iam-account $EXAMPLE_SA nutanixsademos-gcp-provider-key.json