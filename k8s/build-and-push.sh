#!/usr/bin/env bash
set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: ./build-and-push.sh <your_dockerhub_username> [tag]"
  exit 1
fi

DOCKER_USER="$1"
TAG="${2:-latest}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=========================================================="
echo "  Building & Pushing Microservices to Docker Hub"
echo "  Target User: $DOCKER_USER | Tag: $TAG"
echo "=========================================================="

# Check login
docker login

declare -A SERVICES=(
  ["rowad-auth-user-service"]="backend/auth-user-service"
  ["rowad-product-search-service"]="backend/product-search-service"
  ["rowad-payment-service"]="backend/payment-service"
  ["rowad-cart-service"]="backend/cart-service"
  ["rowad-order-service"]="backend/order-service"
  ["rowad-frontend"]="frontend"
)

for NAME in "${!SERVICES[@]}"; do
  IMAGE="${DOCKER_USER}/${NAME}:${TAG}"
  CONTEXT="${PROJECT_ROOT}/${SERVICES[$NAME]}"
  
  echo ""
  echo "--> Building: $IMAGE from $CONTEXT"
  docker build -t "$IMAGE" "$CONTEXT"
  
  echo "--> Pushing: $IMAGE"
  docker push "$IMAGE"
done

echo ""
echo "--> Updating Kubernetes manifests with new username: $DOCKER_USER..."
for FILE in "$SCRIPT_DIR"/*.yaml; do
  sed -i "s|image: .*/rowad-|image: ${DOCKER_USER}/rowad-|g" "$FILE"
  echo "    Updated $FILE"
done

echo ""
echo "=========================================================="
echo "  SUCCESS! Manifests updated and ready."
echo "  Deploy with: kubectl apply -k k8s/"
echo "=========================================================="
