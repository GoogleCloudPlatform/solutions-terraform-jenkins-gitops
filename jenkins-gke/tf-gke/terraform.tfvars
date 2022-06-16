

project_id = "im-shared-sp-prd-iac"
tfstate_gcs_backend = "im-shared-sp-prd-iac-tfstate"
region = "us-central1"
zones = ["us-central1-a"]
ip_range_pods_name = "ip-range-pods"
ip_range_services_name = "ip-range-scv"
network_name = "jenkins-network"
subnet_ip = "10.10.10.0/24"
subnet_name = "jenkins-subnet"
jenkins_k8s_config = "jenkins-k8s-config"
