pipeline {
    agent any

    parameters {
        choice(name: 'ACTION_TYPE', choices: ['apply', 'destroy'], description: 'Choose whether to apply or destroy infrastructure')
    }

    environment {
        TF_VAR_key_name = 'zantac-key'
        AWS_DEFAULT_REGION = 'us-west-1'
        TF_IN_AUTOMATION = 'true'
        GIT_REPO_URL = 'https://github.com/SWAGATAM04/sapient-assignment.git'
    }

    options {
        timestamps()
    }

    stages {

        stage('Clone Terraform Repo') {
            when {
                expression { params.ACTION_TYPE == 'apply' }
            }
            steps {
                dir('terraform-code') {
                    git branch: 'main', url: "${env.GIT_REPO_URL}"
                }
            }
        }

        stage('Install Terraform (if missing)') {
            steps {
                sh '''
                if ! terraform -version > /dev/null 2>&1; then
                  echo "Terraform not found, installing..."
                  curl -fsSL https://releases.hashicorp.com/terraform/1.8.0/terraform_1.8.0_linux_amd64.zip -o terraform.zip
                  unzip -o terraform.zip
                  sudo mv -f terraform /usr/local/bin/
                  sudo rm -f terraform.zip
                else
                  echo "Terraform already installed."
                fi
                '''
            }
        }

        stage('Terraform Init/Validate/Plan') {
            when {
                expression { params.ACTION_TYPE == 'apply' }
            }
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    dir('terraform-code') {
                        sh '''
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                        export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION

                        terraform init
                        terraform validate
                        terraform plan -out=tfplan
                        '''
                    }
                }
            }
        }

        stage('User Approval for Apply') {
            when {
                expression { params.ACTION_TYPE == 'apply' }
            }
            steps {
                script {
                    input message: 'Approve Terraform Apply?', ok: 'Apply Now'
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.ACTION_TYPE == 'apply' }
            }
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    dir('terraform-code') {
                        sh '''
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                        export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION

                        terraform apply -auto-approve tfplan
                        '''
                    }
                }
            }
        }

        stage('User Approval for Destroy') {
            when {
                expression { params.ACTION_TYPE == 'destroy' }
            }
            steps {
                script {
                    input message: 'Are you sure you want to destroy the infrastructure?', ok: 'Yes, Destroy'
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.ACTION_TYPE == 'destroy' }
            }
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    dir('terraform-code') {
                        git branch: 'main', url: "${env.GIT_REPO_URL}"
                        sh '''
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                        export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION

                        terraform init
                        terraform destroy -auto-approve
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up temporary files...'
        }
        success {
            echo 'Terraform pipeline completed successfully!'
        }
        failure {
            echo 'Terraform pipeline failed.'
        }
    }
}

