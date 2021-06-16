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
  Google Provider Configuration
 *****************************************/
provider "google" {
  version = "~>  3.1"
}

provider "google-beta" {
  version = "~>  3.1"
}

/*****************************************
  Kubernetes provider configuration
 *****************************************/
provider "kubernetes" {
  version                = "~> 1.10"
  load_config_file       = false
  host                   = module.jenkins-gke.endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.jenkins-gke.ca_certificate)
}

/*****************************************
  Helm provider configuration
 *****************************************/
module "gke_auth" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  version = "~> 9.1"

  project_id   = module.enables-google-apis.project_id
  cluster_name = module.jenkins-gke.name
  location     = module.jenkins-gke.location
}

provider "helm" {
  kubernetes {
    cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
    host                   = module.gke_auth.host
    token                  = module.gke_auth.token
  }
}
