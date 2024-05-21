node {
    def app

    stage('Clone repository') {
        checkout scm
    }

    stage('Build image') {
        app = docker.build("floor7/docker-course-client-react-nginx:55", "-t client-react:55 ./client-react")
    }

    stage('Push image') {
        docker.withRegistry('https://hub.docker.com/', 'docker-private-credentials') {
            app.push("55")
        }
    }

}