node {
    def app

    stage('Clone repository') {
        checkout scm
    }

    stage('Build image') {
        docker.withServer('tcp://172.18.0.2:2375') {
            app = docker.build("client-react:55", "-t floor7/docker-course-client-react-nginx:55 ./client-react")
        }
    }

    stage('Push image') {
        docker.withRegistry('https://hub.docker.com/', 'docker-private-credentials') {
            app.push("55")
        }
    }
}