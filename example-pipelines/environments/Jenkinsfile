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

pipeline {
  agent {
      label "terraform-exec"
  }
  stages {
    // [START tf-init, tf-validate]
    stage('TF init & validate') {
      when { anyOf {branch "prod";branch "dev";changeRequest() } }
      steps {
        container('terraform') {
          sh '''
          if [[ $CHANGE_TARGET ]]; then
            TARGET_ENV=$CHANGE_TARGET
          else
            TARGET_ENV=$BRANCH_NAME
          fi

          if [ -d "example-pipelines/environments/${TARGET_ENV}/" ]; then
            cd example-pipelines/environments/${TARGET_ENV}
            terraform init
            terraform validate
          else
            for dir in example-pipelines/environments/*/
            do 
              cd ${dir}
              env=${dir%*/}
              env=${env#*/}
              echo ""
              echo "*************** TERRAFOM INIT and VALIDATE ******************"
              echo "******* At environment: ${env} ********"
              echo "*************************************************"
              terraform init || exit 1
              terraform validate || exit 1
              cd ../../../
            done
          fi'''
        }
      }
    }
    // [END tf-init, tf-validate]

    // [START tf-plan]
    stage('TF plan') {
      when { anyOf {branch "prod";branch "dev";changeRequest() } }
      steps {
        container('terraform') {
          sh '''
          if [[ $CHANGE_TARGET ]]; then
            TARGET_ENV=$CHANGE_TARGET
          else
            TARGET_ENV=$BRANCH_NAME
          fi
         
          if [ -d "example-pipelines/environments/${TARGET_ENV}/" ]; then
            cd example-pipelines/environments/${TARGET_ENV}
            terraform plan
          else
            for dir in example-pipelines/environments/*/
            do 
              cd ${dir}
              env=${dir%*/}
              env=${env#*/}
              echo ""
              echo "*************** TERRAFOM PLAN ******************"
              echo "******* At environment: ${env} ********"
              echo "*************************************************"
              terraform plan || exit 1
              cd ../../../
            done
          fi'''
        }
      }
    }
    // [END tf-plan]

    // [START tf-apply]
    stage('TF Apply') {
      when { anyOf {branch "prod";branch "dev" } }
      steps {
        container('terraform') {
          sh '''
          TARGET_ENV=$BRANCH_NAME

          if [ -d "example-pipelines/environments/${TARGET_ENV}/" ]; then
            cd example-pipelines/environments/${TARGET_ENV}
            terraform apply -input=false -auto-approve
          else
            echo "*************** SKIPPING APPLY ******************"
            echo "Branch '$TARGET_ENV' does not represent an official environment."
            echo "*************************************************"
          fi'''
        }
      }
    }
    // [END tf-apply]
  }
}
