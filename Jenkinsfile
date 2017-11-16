node{
    checkout scm 

    try {
        stage 'running Unit/Integration Test...'
        sh 'make test'

        stage 'Build artifact...'
        sh 'make build'

        stage 'release application... '
        sh 'make release'

        stage 'tag application'
        sh 'make tag'

        stage 'login to docker.io'
        sh 'make login'


    }finally {
        stage 'clean workspace'
        sh 'make clean'

        stage 'logout form docker.io'
        sh 'make logout'
    }
}