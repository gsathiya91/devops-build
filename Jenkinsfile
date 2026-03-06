pipeline {
agent any

environment {
    IMAGE_NAME = "devops-app"
    DEV_REPO   = "sathiyagph/devops-app-dev"
    PROD_REPO  = "sathiyagph/devops-app-prod"
}

stages {

    stage('Checkout') {
        steps {
            checkout scm
        }
    }

    stage('Build Docker Image') {
        steps {
            script {
                echo "Building Docker image for branch: ${env.BRANCH_NAME}"

                if (env.BRANCH_NAME == 'dev') {
                    sh "docker build -t ${IMAGE_NAME}:dev ."
                }

                if (env.BRANCH_NAME == 'master') {
                    sh "docker build -t ${IMAGE_NAME}:prod ."
                }
            }
        }
    }

    stage('Docker Login & Push Image') {
        steps {
            script {

                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {

                    sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    '''

                    if (env.BRANCH_NAME == 'dev') {
                        sh """
                        docker tag ${IMAGE_NAME}:dev ${DEV_REPO}:latest
                        docker push ${DEV_REPO}:latest
                        """
                    }

                    if (env.BRANCH_NAME == 'master') {
                        sh """
                        docker tag ${IMAGE_NAME}:prod ${PROD_REPO}:latest
                        docker push ${PROD_REPO}:latest
                        """
                    }

                }
            }
        }
    }

    stage('Deploy to EC2 (DEV only)') {
        when {
            branch 'dev'
        }

        steps {
            sshagent(['ec2-deploy-key']) {

                sh '''
                ssh -o StrictHostKeyChecking=no ubuntu@3.110.177.37 "
                docker pull sathiyagph/devops-app-dev:latest &&
                docker stop devops-container || true &&
                docker rm devops-container || true &&
                docker run -d -p 80:80 --name devops-container sathiyagph/devops-app-dev:latest
                "
                '''

            }
        }
    }

}

post {
    success {
        echo "Pipeline SUCCESS for branch: ${env.BRANCH_NAME}"
    }

    failure {
        echo "Pipeline FAILED for branch: ${env.BRANCH_NAME}"
    }
}

}
