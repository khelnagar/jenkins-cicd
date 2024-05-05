pipeline {
    agent {
        node {
            label 'docker-agent-node'
        }
      }
    triggers {
        pollSCM '* * * * *'
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