node{
    checkout scm 

    try {
        stage 'running Unit/Integration Test...'
        sh 'make test'

        stage 'Build artifact...'
        sh 'make build'

        stage 'login to docker.io'
        sh 'make login'

        stage 'release application... '
        sh 'make release'

        stage 'tag application'
        sh 'make tag'

        stage 'publish todoBackend Image to docker.io'
        sh 'make publish'

    }finally {
        stage 'clean workspace'
        sh 'make clean'

        stage 'logout form docker.io'
        sh 'make logout'
    }
}