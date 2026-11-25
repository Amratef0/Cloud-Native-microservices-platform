pipeline {
    agent any

    environment {
        // Store your Docker Hub credentials in Jenkins with ID 'dockerhub-credentials'
        DOCKERHUB_CREDS = credentials('dockerhub-credentials')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Login to Docker Hub') {
            steps {
                sh 'echo "$DOCKERHUB_CREDS_PSW" | docker login -u "$DOCKERHUB_CREDS_USR" --password-stdin'
            }
        }

        stage('Build and Push Services') {
            parallel {
                stage('Auth Service') {
                    steps {
                        sh '''
                            docker build -t judyassem0/rowad-auth-user-service:latest ./backend/auth-user-service
                            docker push judyassem0/rowad-auth-user-service:latest
                        '''
                    }
                }

                stage('Product Search Service') {
                    steps {
                        sh '''
                            docker build -t judyassem0/rowad-product-search-service:latest ./backend/product-search-service
                            docker push judyassem0/rowad-product-search-service:latest
                        '''
                    }
                }

                stage('Cart Service') {
                    steps {
                        sh '''
                            docker build -t judyassem0/rowad-cart-service:latest ./backend/cart-service
                            docker push judyassem0/rowad-cart-service:latest
                        '''
                    }
                }

                stage('Order Service') {
                    steps {
                        sh '''
                            docker build -t judyassem0/rowad-order-service:latest ./backend/order-service
                            docker push judyassem0/rowad-order-service:latest
                        '''
                    }
                }

                stage('Payment Service') {
                    steps {
                        sh '''
                            docker build -t judyassem0/rowad-payment-service:latest ./backend/payment-service
                            docker push judyassem0/rowad-payment-service:latest
                        '''
                    }
                }

                stage('Frontend') {
                    steps {
                        sh '''
                            docker build -t judyassem0/rowad-frontend:latest ./frontend
                            docker push judyassem0/rowad-frontend:latest
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            // Always log out of Docker Hub after the build finishes
            sh 'docker logout'
        }
    }
}