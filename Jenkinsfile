pipeline{
    agent{
        docker{
            image 'node:16'
            // Connect to the DinD container trough TLS certificate
            args '''
                --network jenkins_dind
                -v docker-certs-client:/certs/client:ro
                -e DOCKER_HOST=tcp://docker:2376
                -e DOCKER_CERT_PATH=/certs/client
                -e DOCKER_TLS_VERIFY=1
            '''
        }
    }
    environment{
        DOCKER_IMAGE = 'app-repo2'
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_CREDENTIALS = credentials('dockerhub-credentials')
    }
    stages{
        stage("Install dependencies"){
            steps {
                echo "Installing dependencies"
                sh 'npm ci'
            }
        }
        stage("Dependency security scan"){
            steps {
                echo "Running dependency scan"
                sh 'npm audit --audit-level=high'
            }
        }
        stage("Unit testing"){
            steps {
                echo "Running unit tests"
                sh 'npm test'
            }
        }
        stage("Building application"){
            steps {
                echo "Building application"
                //sh 'npm run build'
                sh 'node --check app.js'
            }
        }
        stage("Build docker image"){
            steps {
                echo "Building docker image"
                withCredentials([
                        usernamePassword(
                            credentialsId: 'dockerhub-credentials',
                            usernameVariable: 'DOCKER_USERNAME',
                            passwordVariable: 'DOCKER_PASSWORD'
                        )
                    ]) {
                        sh """
                            docker build \
                            --tag ${DOCKER_USERNAME}/${DOCKER_IMAGE}:${IMAGE_TAG} \
                            --tag ${DOCKER_USERNAME}/${DOCKER_IMAGE}:latest \
                        """
                    }
            }
        }
        stage("Docker push"){
            steps {
                echo "Pushing docker image"
                withCredentials([
                        usernamePassword(
                            credentialsId: 'dockerhub-credentials',
                            usernameVariable: 'DOCKER_USERNAME',
                            passwordVariable: 'DOCKER_PASSWORD'
                        )
                    ]) {
                        sh """
                            echo "${DOCKER_PASSWORD}" | docker login \
                                    --username "${DOCKER_USERNAME}" \
                                    --password-stdin

                            docker push ${DOCKER_USERNAME}/${DOCKER_IMAGE}:${IMAGE_TAG}
                            docker logout
                        """
                    }
            }
        }
    }
    post {
        always {
            echo 'CI/CD pipeline completed.'
        }

        success {
            echo 'Pipeline completed successfully.'
        }

        failure {
            echo 'Pipeline failed. Check the stage logs for details.'
        }
    }
}