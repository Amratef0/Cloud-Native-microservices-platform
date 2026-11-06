#!/usr/bin/env bash
set -euo pipefail

echo "=========================================================="
echo "  Deploying Rowad E-Commerce Platform to Kubernetes"
echo "=========================================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "--> Applying Kubernetes manifests..."
kubectl apply -k "$SCRIPT_DIR"

echo "--> Waiting for MongoDB to become ready..."
kubectl rollout status deployment/mongo -n rowad-ecommerce --timeout=120s

echo "--> Waiting for Backend Microservices to become ready..."
kubectl rollout status deployment/auth-user-service -n rowad-ecommerce --timeout=120s
kubectl rollout status deployment/product-search-service -n rowad-ecommerce --timeout=120s
kubectl rollout status deployment/payment-service -n rowad-ecommerce --timeout=120s
kubectl rollout status deployment/cart-service -n rowad-ecommerce --timeout=120s
kubectl rollout status deployment/order-service -n rowad-ecommerce --timeout=120s

echo "--> Waiting for Frontend to become ready..."
kubectl rollout status deployment/frontend -n rowad-ecommerce --timeout=120s

echo ""
echo "=========================================================="
echo "  All pods deployed successfully!"
echo "=========================================================="
echo ""
echo "Current pod status:"
kubectl get pods -n rowad-ecommerce
echo ""
echo "Current services:"
kubectl get svc -n rowad-ecommerce
echo ""
echo "To access the platform locally without Ingress:"
echo "  kubectl port-forward svc/frontend 8080:80 -n rowad-ecommerce"
echo "Then open: http://localhost:8080"
