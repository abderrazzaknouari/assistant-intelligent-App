pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKER_HUB_USERNAME = 'abderrazzaknouari'
        SONARQUBE_URL = 'http://localhost:9000'
        SONARQUBE_TOKEN = credentials('SonareQubeToken')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                script {
                    // Run SonarQube scanner for each module
                    dir('back-end/eurekaserver') {
                        sh "sonar-scanner \
                            -Dsonar.projectKey=eurekaserver \
                            -Dsonar.sources=. \
                            -Dsonar.host.url=${SONARQUBE_URL} \
                            -Dsonar.login=${SONARQUBE_TOKEN}"
                    }
                    
                    dir('back-end/gateway') {
                        sh "sonar-scanner \
                            -Dsonar.projectKey=gateway \
                            -Dsonar.sources=. \
                            -Dsonar.host.url=${SONARQUBE_URL} \
                            -Dsonar.login=${SONARQUBE_TOKEN}"
                    }
                    
                    dir('back-end/Promp_GPT') {
                        sh "sonar-scanner \
                            -Dsonar.projectKey=gpt-server \
                            -Dsonar.sources=. \
                            -Dsonar.host.url=${SONARQUBE_URL} \
                            -Dsonar.login=${SONARQUBE_TOKEN}"
                    }
                    
                    dir('back-end/gmail-service') {
                        sh "sonar-scanner \
                            -Dsonar.projectKey=gmail-service \
                            -Dsonar.sources=. \
                            -Dsonar.host.url=${SONARQUBE_URL} \
                            -Dsonar.login=${SONARQUBE_TOKEN}"
                    }
                    
                    dir('back-end/calendar-service') {
                        sh "sonar-scanner \
                            -Dsonar.projectKey=calendar-service \
                            -Dsonar.sources=. \
                            -Dsonar.host.url=${SONARQUBE_URL} \
                            -Dsonar.login=${SONARQUBE_TOKEN}"
                    }
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    // Build Docker images for all services
                    dir('back-end/eurekaserver') {
                        sh "docker build -t ${DOCKER_HUB_USERNAME}/eurekaserver:latest ."
                    }
                    dir('back-end/gateway') {
                        sh "docker build -t ${DOCKER_HUB_USERNAME}/gateway:latest ."
                    }
                    dir('back-end/Promp_GPT') {
                        sh "docker build -t ${DOCKER_HUB_USERNAME}/gpt-server:latest ."
                    }
                    dir('back-end/gmail-service') {
                        sh "docker build -t ${DOCKER_HUB_USERNAME}/gmail-server:latest ."
                    }
                    dir('back-end/calendar-service') {
                        sh "docker build -t ${DOCKER_HUB_USERNAME}/calendar-service:latest ."
                    }
                }
            }
        }
        
        stage('Login to Docker Hub') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }
        
        stage('Push Images') {
            steps {
                script {
                    sh "docker push ${DOCKER_HUB_USERNAME}/eurekaserver:latest"
                    sh "docker push ${DOCKER_HUB_USERNAME}/gateway:latest"
                    sh "docker push ${DOCKER_HUB_USERNAME}/gpt-server:latest"
                    sh "docker push ${DOCKER_HUB_USERNAME}/gmail-server:latest"
                    sh "docker push ${DOCKER_HUB_USERNAME}/calendar-service:latest"
                }
            }
        }

        stage('Deploy to Azure') {
            steps {
                sshagent(credentials: ['azure-vm-ssh-key']) {
                    sh '''
                        # Deployment commands to Azure VM
                        ...
                    '''
                }
            }
        }
    }
    
    post {
        always {
            sh 'docker logout'
        }
    }
}
