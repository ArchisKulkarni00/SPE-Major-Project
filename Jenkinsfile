pipeline {
    agent any

    // Use polling instead of webhook if needed
    triggers {
        pollSCM('* * * * *') // Every minute
    }

    environment {
        DOCKER_IMAGE_NAME = 'archis002/iiitb-chatbot'
        DOCKER_IMAGE_NAME_FE = 'archis002/rag-chatbot'
        GITHUB_REPO_URL = 'https://github.com/ArchisKulkarni00/SPE-Major-Project.git'
        GITHUB_REPO_URL_FE = 'https://github.com/nitin-rajesh/rag-chatbot.git'
    }

    stages {
        stage('Checkout FE') {
            steps {
                dir('frontend') {
                    git branch: 'Archis-config', url: "${GITHUB_REPO_URL_FE}"
                }
            }
        }

        stage('Build Docker Image FE') {
            steps {
                dir('frontend') {
                    script {
                        docker.build("${DOCKER_IMAGE_NAME_FE}", '.')
                    }
                }
            }
        }

        stage('Push Docker Image FE') {
            steps {
                script {
                    docker.withRegistry('', 'DockerHubCred') {
                        sh 'docker tag archis002/rag-chatbot archis002/iiitb-rag:latest'
                        sh 'docker push archis002/rag-chatbot'
                    }
                }
            }
        }

        stage('Checkout BE') {
            steps {
                dir('backend') {
                    git branch: 'master', url: "${GITHUB_REPO_URL}"
                }
            }
        }

        stage('Build the database') {
            steps {
                sh "pip install -r requirements-build.txt"
                sh "python3 -m spacy download en_core_web_sm"
                sh "python3 CreateData.py"
            }
        }
        
        stage('Testing') {
            steps {
                sh "python3 Test.py"
            }
        }

        stage('Build Docker Image BE') {
            steps {
                dir('backend') {
                    script {
                        docker.build("${DOCKER_IMAGE_NAME}", '.')
                    }
                }
            }
        }

        stage('Push Docker Image BE') {
            steps {
                script {
                    docker.withRegistry('', 'DockerHubCred') {
                        sh 'docker tag archis002/iiitb-chatbot archis002/iiitb-chatbot:latest'
                        sh 'docker push archis002/iiitb-chatbot'
                    }
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                dir('backend') {
                    script {
                        ansiblePlaybook(
                            playbook: './ansible/deploy.yml',
                            inventory: './ansible/inventory'
                        )
                    }
                }
            }
        }

        stage('Run Minikube and Setup K8s') {
            steps {
                dir('backend') {
                    script {
                        sh 'chmod +x ./ansible/run-as-linuxboi.sh'
                        sh './ansible/run-as-linuxboi.sh'
                    }
                }
            }
        }
    }
}
