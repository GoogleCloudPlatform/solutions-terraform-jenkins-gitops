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
  Locals
 *****************************************/
locals {
  vpc_network_name = "example-vpc-${var.environment}"
  vm_name = "example-vm-${var.environment}-001"
}

/*****************************************
  Google Provider Configuration
 *****************************************/
provider "google" {
  version = "~> 2.18.0"
}

/*****************************************
  Create a VPC Network 
 *****************************************/
module "gcp-network" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 1.4.0"
  project_id   = var.project_id
  network_name = local.vpc_network_name

  subnets = [
    {
      subnet_name   = "${local.vpc_network_name}-${var.subnet1_region}"
      subnet_ip     = var.subnet1_cidr
      subnet_region = var.subnet1_region
    },
  ]
}

/*****************************************
  Create a GCE VM Instance
 *****************************************/
resource "google_compute_instance" "vm_0001" {
  project      = var.project_id
  zone         = var.subnet1_zone
  name         = local.vm_name
  machine_type = "f1-micro"
  network_interface {
    network    = module.gcp-network.network_name
    subnetwork = module.gcp-network.subnets_self_links[0]
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
}
