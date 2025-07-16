pipeline {
    agent any

    environment {
        TF_VAR_key_name = 'zantac-key'
        AWS_DEFAULT_REGION = 'us-west-1'
        TF_IN_AUTOMATION = 'true'
        GIT_REPO_URL = 'https://github.com/your-org/zantac-terraform'
    }

    options {
        timestamps()
        ansiColor('xterm')
    }

    stages {

        stage('Clone Terraform Repo') {
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
                  unzip terraform.zip
                  sudo mv terraform /usr/local/bin/
                else
                  echo "Terraform already installed."
                fi
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform-code') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir('terraform-code') {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform-code') {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform-code') {
                    input message: 'Approve Terraform Apply?'
                    sh 'terraform apply -auto-approve tfplan'
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

