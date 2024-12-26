pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKER_HUB_USERNAME = 'abderrazzaknouari'
        SONARQUBE_URL = 'http://sonarqube:9000'
        SONARQUBE_TOKEN = credentials('SonareQubeToken')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
    


        stage('SonarQube Analysis') {
          def mvn = tool 'Default Maven';
          withSonarQubeEnv() {
            sh "${mvn}/bin/mvn clean verify sonar:sonar -Dsonar.projectKey=Project-Java-app1 -Dsonar.projectName='Project Java app1'"
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
