#!/bin/sh

#####################
# Pre-requisites    #
# gcloud auth login #
#####################
GOOGLE_PROJECT="test-project-1-315714"
echo "Switch to project ${GOOGLE_PROJECT}"
gcloud config set project ${GOOGLE_PROJECT}

echo "Create the Cloud Storage bucket"
#PROJECT_PID=$(gcloud config get-value project)
gsutil mb gs://${GOOGLE_PROJECT}-tfstate
echo "Enable Object Versioning to keep the history of your deployments"
gsutil versioning set on gs://${GOOGLE_PROJECT}-tfstate

PROJECT_ID=$(gcloud config get-value project)
sed -i.bak "s/PROJECT_ID/${PROJECT_ID}/g" ./example-pipelines/environments/*/terraform.tfvars
sed -i.bak "s/PROJECT_ID/${PROJECT_ID}/g" ./example-pipelines/environments/*/backend.tf

sed -i.bak "s/PROJECT_ID/${PROJECT_ID}/g" ./jenkins-gke/tf-gke/terraform.tfvars
sed -i.bak "s/PROJECT_ID/${PROJECT_ID}/g" ./jenkins-gke/tf-gke/backend.tf