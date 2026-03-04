pipeline {
agent any

```
environment {
    DOCKER_IMAGE = "sathiyagph/devops-app-dev"
    APP_SERVER = "3.110.177.37"
}

stages {

    stage('Clone Repository') {
        steps {
            git 'https://github.com/gsathiya91/devops-build.git'
        }
    }

    stage('Build Docker Image') {
        steps {
            sh 'docker build -t $DOCKER_IMAGE .'
        }
    }

    stage('Push Docker Image') {
        steps {
            sh 'docker push $DOCKER_IMAGE'
        }
    }

    stage('Deploy to EC2') {
        steps {
            sh '''
            ssh ubuntu@$APP_SERVER "
            docker pull $DOCKER_IMAGE &&
            docker stop devops-container || true &&
            docker rm devops-container || true &&
            docker run -d -p 80:80 --name devops-container $DOCKER_IMAGE
            "
            '''
        }
    }
}
```

}
