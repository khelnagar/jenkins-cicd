pipeline {
    agent {
        docker { image 'node:20.11.1-alpine3.19' }
    }
    stages {
        stage('Build') {
            steps {
                echo "Building.."
                sh '''
                  cd client-react
                  docker build --file ./Dockerfile -t client-react:5 -t floor7/docker-course-client-react-nginx:5 .
                '''
            }
        }
        stage('Deliver') {
            steps {
                echo 'Deliver....'
                sh '''
                  cd client-react
                  docker push floor7/docker-course-client-react-nginx:5
                '''
            }
        }
    }
}