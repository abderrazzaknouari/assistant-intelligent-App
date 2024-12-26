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
            try {
                // Define common properties for SonarQube analysis
                def mvn = tool 'Default Maven'
                def sonarProjectKey = 'Project-Java-app1'
                def sonarProjectName = 'Project Java app1'

                // List of directories to analyze
                def directories = [
                    'back-end/eurekaserver',
                    'back-end/gateway',
                    'back-end/Promp_GPT',
                    'back-end/gmail-service',
                    'back-end/calendar-service'
                ]

                // Run SonarQube analysis for each directory
                directories.each { dirPath ->
                    dir(dirPath) {
                        withSonarQubeEnv('SonarQube') {
                            sh "${mvn}/bin/mvn clean verify sonar:sonar " +
                               "-Dsonar.projectKey=${sonarProjectKey} " +
                               "-Dsonar.projectName='${sonarProjectName}'"
                        }
                    }
                }
            } catch (Exception e) {
                echo "Error in SonarQube analysis: ${e.getMessage()}"
                currentBuild.result = 'FAILURE'
                throw e  // Fail the build if the stage fails
            }
        }
    }
}


stage('SonarQube Analysis') {
    steps {
        script {
            try {
              dir('back-end/eurekaserver') {
                // Run SonarQube analysis for Maven
                def mvn = tool 'Default Maven'
                withSonarQubeEnv('SonarQube') {
                    sh "${mvn}/bin/mvn clean verify sonar:sonar -Dsonar.projectKey=Project-Java-app1 -Dsonar.projectName='Project Java app1'"
                }
                  
                withSonarQubeEnv('SonarQube') { // You should specify the name of the SonarQube server defined in Jenkins
                sh "${mvn}/bin/mvn clean verify sonar:sonar -Dsonar.projectKey=Project-Java-app1 -Dsonar.projectName='Project Java app1'"
            }
                  }
            } catch (Exception e) {
                echo "Error in SonarQube analysis: ${e.getMessage()}"
                currentBuild.result = 'FAILURE'
                throw e  // Fail the build if the stage fails
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