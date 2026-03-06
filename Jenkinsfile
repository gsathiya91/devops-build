pipeline {
  agent any
 
  environment {
    IMAGE_NAME = "ecom-app"
    DEV_REPO   = "pranathi20222/ecomm_publicrepo"
    PROD_REPO  = "pranathi20222/ecomm_privaterepo"
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
              credentialsId: 'dockercreds',
              usernameVariable: 'DOCKER_USER',
              passwordVariable: 'DOCKER_PASS'
            )
          ]) {
 
            sh '''
              echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            '''
 
            if (env.BRANCH_NAME == 'dev') {
              sh """
                docker tag ${IMAGE_NAME}:dev ${DEV_REPO}:dev
                docker push ${DEV_REPO}:dev
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
 
    stage('Deploy to Server') {
      when {
        branch 'master'
      }
      steps {
        sh """
          ./deploy.sh ${PROD_REPO} latest
        """
      }
    }
  }
 
  post {
    success {
      echo "✅ Pipeline SUCCESS for branch: ${env.BRANCH_NAME}"
    }
    failure {
      echo "❌ Pipeline FAILED for branch: ${env.BRANCH_NAME}"
    }
  }
}