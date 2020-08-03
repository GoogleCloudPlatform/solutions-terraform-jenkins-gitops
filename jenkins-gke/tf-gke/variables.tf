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

variable "project_id" {
  description = "The project id to deploy Jenkins on GKE"
}

variable "tfstate_gcs_backend" {
  description = "Name of the GCS bucket to use as a backend for Terraform State"
  default     = "TFSTATE_GCS_BACKEND"
}

variable "region" {
  description = "The GCP region to deploy instances into"
  default     = "us-east4"
}

variable "zones" {
  description = "The GCP zone to deploy gke into"
  default     = ["us-east4-a"]
}

variable "ip_range_pods_name" {
  description = "The secondary ip range to use for pods"
  default     = "ip-range-pods"
}

variable "ip_range_services_name" {
  description = "The secondary ip range to use for pods"
  default     = "ip-range-scv"
}

variable "network_name" {
  description = "Name for the VPC network"
  default     = "jenkins-network"
}
variable "subnet_ip" {
  description = "IP range for the subnet"
  default     = "10.10.10.0/24"
}
variable "subnet_name" {
  description = "Name for the subnet"
  default     = "jenkins-subnet"
}

variable "jenkins_k8s_config" {
  description = "Name for the k8s secret required to configure k8s executers on Jenkins"
  default     = "jenkins-k8s-config"
}

variable "github_username" {
  description = "Github user/organization name where the terraform repo resides."
}

variable "github_token" {
  description = "Github token to access repo."
}

variable "github_repo" {
  description = "Github repo name."
  default     = "solutions-terraform-jenkins-gitops"
}
