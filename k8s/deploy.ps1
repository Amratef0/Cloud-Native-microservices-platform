# Windows PowerShell deployment script for Rowad E-Commerce Kubernetes stack
$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Deploying Rowad E-Commerce Platform to Kubernetes" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "--> Applying Kubernetes manifests..." -ForegroundColor Yellow
kubectl apply -k "$ScriptDir"

Write-Host "--> Waiting for MongoDB to become ready..." -ForegroundColor Yellow
kubectl rollout status deployment/mongo -n rowad-ecommerce --timeout=120s

Write-Host "--> Waiting for Backend Microservices to become ready..." -ForegroundColor Yellow
kubectl rollout status deployment/auth-user-service -n rowad-ecommerce --timeout=120s
kubectl rollout status deployment/product-search-service -n rowad-ecommerce --timeout=120s
kubectl rollout status deployment/payment-service -n rowad-ecommerce --timeout=120s
kubectl rollout status deployment/cart-service -n rowad-ecommerce --timeout=120s
kubectl rollout status deployment/order-service -n rowad-ecommerce --timeout=120s

Write-Host "--> Waiting for Frontend to become ready..." -ForegroundColor Yellow
kubectl rollout status deployment/frontend -n rowad-ecommerce --timeout=120s

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "  All pods deployed successfully!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Current pod status:" -ForegroundColor Cyan
kubectl get pods -n rowad-ecommerce
Write-Host ""
Write-Host "Current services:" -ForegroundColor Cyan
kubectl get svc -n rowad-ecommerce
Write-Host ""
Write-Host "To access the platform locally without Ingress:" -ForegroundColor Yellow
Write-Host "  kubectl port-forward svc/frontend 8080:80 -n rowad-ecommerce" -ForegroundColor White
Write-Host "Then open: http://localhost:8080" -ForegroundColor White
