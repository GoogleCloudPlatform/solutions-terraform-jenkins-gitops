# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource "google_storage_bucket" "tfb" {
  name                        = "${var.project_id}-tf-backend"
  project                     = var.project_id
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
}

module "tf-gke" {
  source                 = "../../../jenkins-gke/tf-gke"
  project_id             = var.project_id
  tfstate_gcs_backend    = google_storage_bucket.tfb.name
  region                 = "us-east4"
  zones                  = ["us-east4-a"]
  ip_range_pods_name     = "ip-range-pods"
  ip_range_services_name = "ip-range-scv"
  network_name           = "jenkins-network"
  subnet_ip              = "10.10.10.0/24"
  subnet_name            = "jenkins-subnet"
  jenkins_k8s_config     = "jenkins-k8s-config"
  github_username        = "test"
  github_token           = "test"
}
