pipeline {
    agent any

    environment {
        // Docker Hub credentials stored in Jenkins with ID 'dockerhub-credentials'
        DOCKERHUB_CREDS = credentials('dockerhub-credentials')
        IMAGE_PREFIX    = 'judyassem0/rowad'
        K8S_NAMESPACE   = 'rowad-ecommerce'
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
                            docker build -t $IMAGE_PREFIX-auth-user-service:$BUILD_NUMBER -t $IMAGE_PREFIX-auth-user-service:latest ./backend/auth-user-service
                            docker push $IMAGE_PREFIX-auth-user-service:$BUILD_NUMBER
                            docker push $IMAGE_PREFIX-auth-user-service:latest
                        '''
                    }
                }
                stage('Product Search Service') {
                    steps {
                        sh '''
                            docker build -t $IMAGE_PREFIX-product-search-service:$BUILD_NUMBER -t $IMAGE_PREFIX-product-search-service:latest ./backend/product-search-service
                            docker push $IMAGE_PREFIX-product-search-service:$BUILD_NUMBER
                            docker push $IMAGE_PREFIX-product-search-service:latest
                        '''
                    }
                }
                stage('Cart Service') {
                    steps {
                        sh '''
                            docker build -t $IMAGE_PREFIX-cart-service:$BUILD_NUMBER -t $IMAGE_PREFIX-cart-service:latest ./backend/cart-service
                            docker push $IMAGE_PREFIX-cart-service:$BUILD_NUMBER
                            docker push $IMAGE_PREFIX-cart-service:latest
                        '''
                    }
                }
                stage('Order Service') {
                    steps {
                        sh '''
                            docker build -t $IMAGE_PREFIX-order-service:$BUILD_NUMBER -t $IMAGE_PREFIX-order-service:latest ./backend/order-service
                            docker push $IMAGE_PREFIX-order-service:$BUILD_NUMBER
                            docker push $IMAGE_PREFIX-order-service:latest
                        '''
                    }
                }
                stage('Payment Service') {
                    steps {
                        sh '''
                            docker build -t $IMAGE_PREFIX-payment-service:$BUILD_NUMBER -t $IMAGE_PREFIX-payment-service:latest ./backend/payment-service
                            docker push $IMAGE_PREFIX-payment-service:$BUILD_NUMBER
                            docker push $IMAGE_PREFIX-payment-service:latest
                        '''
                    }
                }
                stage('Frontend') {
                    steps {
                        sh '''
                            docker build -t $IMAGE_PREFIX-frontend:$BUILD_NUMBER -t $IMAGE_PREFIX-frontend:latest ./frontend
                            docker push $IMAGE_PREFIX-frontend:$BUILD_NUMBER
                            docker push $IMAGE_PREFIX-frontend:latest
                        '''
                    }
                }
            }
        }

        stage('Deploy to k3s') {
            when { expression { env.BRANCH_NAME == null || env.BRANCH_NAME == 'main' } }
            steps {
                // From this point on, a failure must trigger a rollback
                script { env.DEPLOYED = 'true' }
                // 'k3s-kubeconfig' is a Secret file credential in Jenkins
                withCredentials([file(credentialsId: 'k3s-kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                        rm -rf k8s-render
                        cp -r k8s k8s-render
                        sed -i "s/:latest/:${BUILD_NUMBER}/g" k8s-render/*.yaml
                        kubectl apply -k k8s-render
                        for d in auth-user-service product-search-service payment-service cart-service order-service frontend; do
                            kubectl -n $K8S_NAMESPACE rollout status deployment/$d --timeout=180s
                        done
                    '''
                }
            }
        }

        stage('Smoke test') {
            when { expression { env.BRANCH_NAME == null || env.BRANCH_NAME == 'main' } }
            steps {
                withCredentials([file(credentialsId: 'k3s-kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                        kubectl -n $K8S_NAMESPACE exec deploy/frontend -- wget -qO- http://127.0.0.1/nginx-health
                        for s in auth-user-service:5001 product-search-service:5002 payment-service:5003 cart-service:5004 order-service:5005; do
                            kubectl -n $K8S_NAMESPACE exec deploy/frontend -- wget -qO- http://$s/health
                            echo
                        done
                        kubectl -n $K8S_NAMESPACE exec deploy/frontend -- wget -qO- http://127.0.0.1/api/products/ | grep -q products
                    '''
                }
            }
        }
    }

    post {
        failure {
            script {
                if (env.DEPLOYED == 'true') {
                    withCredentials([file(credentialsId: 'k3s-kubeconfig', variable: 'KUBECONFIG')]) {
                        sh '''
                            for d in auth-user-service product-search-service payment-service cart-service order-service frontend; do
                                kubectl -n $K8S_NAMESPACE rollout undo deployment/$d || true
                            done
                        '''
                    }
                }
            }
        }
        always {
            // Always log out of Docker Hub after the build finishes
            sh 'docker logout'
        }
    }
}
