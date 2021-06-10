/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


/*****************************************
  Activate Services in Jenkins Project
 *****************************************/
module "enables-google-apis" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "6.0.0"

  project_id = var.project_id

  activate_apis = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "containerregistry.googleapis.com",
    "container.googleapis.com",
    "storage-component.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ]
}

/*****************************************
  Jenkins VPC
 *****************************************/
module "jenkins-vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.0"

  project_id   = module.enables-google-apis.project_id
  network_name = var.network_name

  subnets = [
    {
      subnet_name   = var.subnet_name
      subnet_ip     = "10.0.0.0/17"
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    "${var.subnet_name}" = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }
}

/*****************************************
  Jenkins GKE
 *****************************************/
module "jenkins-gke" {
  source                   = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster/"
  version                  = "~> 7.0"
  project_id               = module.enables-google-apis.project_id
  name                     = "jenkins"
  regional                 = false
  region                   = var.region
  zones                    = var.zones
  network                  = module.jenkins-vpc.network_name
  subnetwork               = module.jenkins-vpc.subnets_names[0]
  ip_range_pods            = var.ip_range_pods_name
  ip_range_services        = var.ip_range_services_name
  logging_service          = "logging.googleapis.com/kubernetes"
  monitoring_service       = "monitoring.googleapis.com/kubernetes"
  remove_default_node_pool = true
  service_account          = "create"
  identity_namespace       = "${module.enables-google-apis.project_id}.svc.id.goog"
  node_metadata            = "GKE_METADATA_SERVER"
  node_pools = [
    {
      name         = "butler-pool"
      min_count    = 3
      max_count    = 6
      auto_upgrade = true
    }
  ]
}

/*****************************************
  IAM Bindings GKE SVC
 *****************************************/
# allow GKE to pull images from GCR
resource "google_project_iam_member" "gke" {
  project = module.enables-google-apis.project_id
  role    = "roles/storage.objectViewer"

  member = "serviceAccount:${module.jenkins-gke.service_account}"
}

/*****************************************
  Jenkins Workload Identity
 *****************************************/
module "workload_identity" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version             = "~> 7.0"
  project_id          = module.enables-google-apis.project_id
  name                = "jenkins-wi-${module.jenkins-gke.name}"
  namespace           = "default"
  use_existing_k8s_sa = false
}

# enable GSA to add and delete pods for jenkins builders
resource "google_project_iam_member" "cluster-dev" {
  project = module.enables-google-apis.project_id
  role    = "roles/container.developer"
  member  = module.workload_identity.gcp_service_account_fqn
}

data "google_client_config" "default" {
}

/*****************************************
  K8S secrets for configuring K8S executers
 *****************************************/
resource "kubernetes_secret" "jenkins-secrets" {
  metadata {
    name = var.jenkins_k8s_config
  }
  data = {
    project_id          = module.enables-google-apis.project_id
    kubernetes_endpoint = "https://${module.jenkins-gke.endpoint}"
    ca_certificate      = module.jenkins-gke.ca_certificate
    jenkins_tf_ksa      = module.workload_identity.k8s_service_account_name
  }
}

/*****************************************
  K8S secrets for GH
 *****************************************/
resource "kubernetes_secret" "gh-secrets" {
  metadata {
    name = "github-secrets"
  }
  data = {
    github_username = var.github_username
    github_repo     = var.github_repo
    github_token    = var.github_token
  }
}

/*****************************************
  Grant Jenkins SA Permissions to store
  TF state for Jenkins Pipelines
 *****************************************/
resource "google_storage_bucket_iam_member" "tf-state-writer" {
  bucket = var.tfstate_gcs_backend
  role   = "roles/storage.admin"
  member = module.workload_identity.gcp_service_account_fqn
}

/*****************************************
  Grant Jenkins SA Permissions project editor
 *****************************************/
resource "google_project_iam_member" "jenkins-project" {
  project = module.enables-google-apis.project_id
  role    = "roles/editor"

  member = module.workload_identity.gcp_service_account_fqn

}

data "local_file" "helm_chart_values" {
  filename = "${path.module}/values.yaml"
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.helm.sh/stable"
  chart      = "jenkins"
  version    = "1.9.18"
  timeout    = 1200

  values = [data.local_file.helm_chart_values.content]

  depends_on = [
    kubernetes_secret.gh-secrets,
  ]
}
