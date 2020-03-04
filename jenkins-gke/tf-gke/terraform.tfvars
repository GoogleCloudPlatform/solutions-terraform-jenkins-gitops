

project_id = "festive-terrain-2"
tfstate_gcs_backend = "festive-terrain-2-tfstate"
restart_policy = "Always"
region = "us-east4"
zones = ["us-east4-a"]
ip_range_pods_name = "ip-range-pods"
ip_range_services_name = "ip-range-scv"
network_name = "jenkins-network"
subnet_ip = "10.10.10.0/24"
subnet_name = "jenkins-subnet"
jenkins_project_name = "jenkins-gke"
jenkins_k8s_config = "jenkins-k8s-config"
