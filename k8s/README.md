# 🚀 Kubernetes Deployment Guide: Rowad E-Commerce Platform

This directory contains full Kubernetes (K8s) deployment manifests for the polyglot microservices e-commerce platform.

---

## 🏛️ Architecture Overview

The platform is deployed under the dedicated `rowad-ecommerce` namespace:

```
[ Client / Browser ]
         │
         ▼
[ Ingress / Frontend Service (:80 / NodePort 30080) ]
         │
         ├── / ───────────────────────────> [ Frontend Pod (Nginx + React 19 SPA) ]
         │
         ├── /api/auth, /api/users ───────> [ auth-user-service (:5001) ] ──┐
         ├── /api/products, /categories ──> [ product-search-service (:5002) ] │
         ├── /api/payment ────────────────> [ payment-service (:5003) ]     ├──> [ MongoDB (:27017) ]
         ├── /api/cart ───────────────────> [ cart-service (:5004) ]        │    (mongo-pvc: 5Gi)
         └── /api/orders ─────────────────> [ order-service (:5005) ] ──────┘
                                                    │
                                                    └──> [ SQLite payments.db ]
                                                         (payment-pvc: 1Gi)
```

---

## 📁 Manifests Structure

| File | Resource(s) | Description |
|:---|:---|:---|
| [`00-namespace.yaml`](00-namespace.yaml) | `Namespace` | Creates isolated `rowad-ecommerce` namespace |
| [`01-secrets.yaml`](01-secrets.yaml) | `Secret` | JWT Secret & Brevo SMTP credentials |
| [`02-configmaps.yaml`](02-configmaps.yaml) | `ConfigMap` | Backend configuration + Frontend Nginx dynamic CoreDNS proxy configuration |
| [`03-storage.yaml`](03-storage.yaml) | `PersistentVolumeClaim` | 5Gi for MongoDB data (`/data/db`), 1Gi for Payment ledger (`/app/data`) |
| [`04-mongodb.yaml`](04-mongodb.yaml) | `Deployment`, `Service` | MongoDB 7 engine with live/ready probes |
| [`05-payment-service.yaml`](05-payment-service.yaml) | `Deployment`, `Service` | C# ASP.NET Core 9 Payment Service |
| [`06-auth-service.yaml`](06-auth-service.yaml) | `Deployment`, `Service` | Node.js Express Auth & User Management |
| [`07-product-service.yaml`](07-product-service.yaml) | `Deployment`, `Service` | Python FastAPI Product Catalog & Auto-seed |
| [`08-cart-service.yaml`](08-cart-service.yaml) | `Deployment`, `Service` | Node.js Express Cart Service |
| [`09-order-service.yaml`](09-order-service.yaml) | `Deployment`, `Service` | Node.js Express Order Placement Service |
| [`10-frontend.yaml`](10-frontend.yaml) | `Deployment`, `Service` | React 19 Frontend + LoadBalancer / NodePort 30080 |
| [`11-ingress.yaml`](11-ingress.yaml) | `Ingress` | Nginx Ingress Controller path routing rules |
| [`kustomization.yaml`](kustomization.yaml) | `Kustomization` | Unified deployment definition |

---

## ⚡ Quick Start: Deploying to Kubernetes

### Prerequisites
- A running Kubernetes cluster (Minikube, Kind, Docker Desktop K8s, K3s, EKS, GKE, or AKS)
- `kubectl` CLI installed and configured to your cluster

### 1. One-Click Deployment

#### Linux / macOS:
```bash
chmod +x k8s/deploy.sh
./k8s/deploy.sh
```

#### Windows PowerShell:
```powershell
.\k8s\deploy.ps1
```

#### Or using pure `kubectl`:
```bash
# Apply all manifests using Kustomize:
kubectl apply -k k8s/

# Or apply directory directly:
kubectl apply -f k8s/
```

---

## 🌐 Accessing the Application

### Option A: Local Port-Forwarding (Works Everywhere)
```bash
kubectl port-forward svc/frontend 8080:80 -n rowad-ecommerce
```
Open **`http://localhost:8080`** in your browser.

### Option B: Minikube
```bash
# If using minikube service tunnel:
minikube service frontend -n rowad-ecommerce

# Or enable ingress addon:
minikube addons enable ingress
```

### Option C: Cloud LoadBalancer (EKS / GKE / AKS)
```bash
kubectl get svc frontend -n rowad-ecommerce
```
Copy the `EXTERNAL-IP` from the output and visit it in your browser on port 80.

---

## 🩺 Verifying Health & Status

```bash
# Check all pods
kubectl get pods -n rowad-ecommerce -o wide

# Check services & endpoints
kubectl get svc -n rowad-ecommerce

# Check logs of any service (e.g. order-service)
kubectl logs -f deployment/order-service -n rowad-ecommerce

# View MongoDB status
kubectl exec -it deploy/mongo -n rowad-ecommerce -- mongosh --eval "db.adminCommand('ping')"
```

---

## 🧹 Teardown

To delete all resources and persistent volumes created:

```bash
kubectl delete -k k8s/
```
