pipeline {
agent any

environment {
    DEV_IMAGE  = "sathiyagph/devops-app-dev"
    PROD_IMAGE = "sathiyagph/devops-app-prod"
    APP_SERVER = "3.110.177.37"
}

stages {

    stage('Clone Repo') {
        steps {
            git branch: "${env.BRANCH_NAME}",
                url: 'https://github.com/gsathiya91/devops-build.git'
        }
    }

    stage('Build Docker Image') {
        steps {
            sh 'docker build -t devops-app .'
        }
    }

    stage('Login DockerHub') {
        steps {
            withCredentials([
                usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )
            ]) {
                sh 'echo $PASS | docker login -u $USER --password-stdin'
            }
        }
    }

    stage('Push DEV Image') {
        when {
            branch 'dev'
        }
        steps {
            sh '''
            docker tag devops-app $DEV_IMAGE:latest
            docker push $DEV_IMAGE:latest
            '''
        }
    }

    stage('Push PROD Image') {
        when {
            branch 'master'
        }
        steps {
            sh '''
            docker tag devops-app $PROD_IMAGE:latest
            docker push $PROD_IMAGE:latest
            '''
        }
    }

    stage('Deploy to App Server') {
        when {
            branch 'dev'
        }
        steps {
            sshagent(['ec2-deploy-key']) {
                sh '''
                ssh -o StrictHostKeyChecking=no ubuntu@$APP_SERVER "
                docker pull $DEV_IMAGE:latest &&
                docker stop devops-container || true &&
                docker rm devops-container || true &&
                docker run -d -p 80:80 --name devops-container $DEV_IMAGE:latest
                "
                '''
            }
        }
    }
}

}
