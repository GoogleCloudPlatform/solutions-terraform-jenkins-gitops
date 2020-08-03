# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

export JENKINS_PROJECT_ID=$(cd ../jenkins-gke/tf-gke && terraform output jenkins_project_id)
export ZONE=$(cd ../jenkins-gke/tf-gke && terraform output zone)
export CLUSTER_NAME=$(cd ../jenkins-gke/tf-gke && terraform output cluster_name)
gcloud container clusters get-credentials ${CLUSTER_NAME} --zone=${ZONE} --project=${JENKINS_PROJECT_ID}
printf jenkins-username:admin;echo
printf jenkins-password: ; printf $(kubectl get secret --namespace default jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
