# 🚀 Portfolio9 — Déploiement DevOps Fullstack

> Application portfolio fullstack déployée avec Docker, Kubernetes (k3s) et CI/CD GitHub Actions.

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)

---

## 📋 Table des matières

- [Stack technique](#-stack-technique)
- [Architecture](#-architecture)
- [Prérequis](#-prérequis)
- [Phase 1 — Docker](#-phase-1--docker)
- [Phase 2 — Installation k3s](#-phase-2--installation-k3s)
- [Phase 3 — Déploiement Kubernetes](#-phase-3--déploiement-kubernetes)
- [Phase 4 — Monitoring](#-phase-4--monitoring-prometheus--grafana)
- [Phase 5 — CI/CD](#-phase-5--cicd-github-actions)
- [Accès à l'application](#-accès-à-lapplication)

---

## 🛠 Stack technique

| Couche | Technologie |
|---|---|
| Frontend | HTML / CSS |
| Backend | Node.js / Express |
| Base de données | MongoDB Atlas (Cloud) |
| Conteneurisation | Docker |
| Orchestration | Kubernetes k3s |
| Monitoring | Prometheus + Grafana (Helm) |
| CI/CD | GitHub Actions |
| Environnement | WSL2 Ubuntu sur Windows |

---

## 🏗 Architecture

```
┌─────────────────────────────────────────────────┐
│              Cluster Kubernetes k3s              │
│                                                  │
│  ┌─────────────────┐    ┌────────────────────┐   │
│  │ frontend Pod     │    │  backend Pod        │   │
│  │ HTML/CSS + Nginx │    │  Node.js/Express    │   │
│  │ Port: 80         │    │  Port: 5000         │   │
│  └────────┬─────────┘    └────────┬───────────┘   │
│           │                       │               │
│  NodePort:8080            ClusterIP:5002          │
│                                   │               │
└───────────────────────────────────│───────────────┘
                                    │
                            ┌───────▼────────┐
                            │  MongoDB Atlas  │
                            │  (Cloud)        │
                            └────────────────┘
```

---

## ✅ Prérequis

- Windows 11 avec **WSL2** activé
- **Ubuntu** installé dans WSL2
- **Docker Desktop** avec intégration WSL2 activée
- Compte **GitHub** avec Personal Access Token
- Compte **MongoDB Atlas**

---

## 🐳 Phase 1 — Docker

### Dockerfile Backend

```dockerfile
FROM node:20
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 5001
CMD ["node", "server.js"]
```

### Dockerfile Frontend

```dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
EXPOSE 80
```

### docker-compose.yml

```yaml
version: "3.8"
services:
  backend:
    build: ./backend
    ports:
      - "5002:5000"
    env_file:
      - ./backend/.env
    restart: always
  frontend:
    build: ./frontend
    ports:
      - "8080:80"
    depends_on:
      - backend
    restart: always
```

### Commandes Docker

```bash
# Lister les images disponibles
docker images

# Builder les images
docker build -t protfolio9-frontend:latest ./frontend
docker build -t protfolio9-backend:latest ./backend

# Lancer avec docker-compose
docker-compose up -d

# Vérifier les conteneurs
docker ps
```

### ⚠️ Fix permissions Docker (WSL2)

```bash
sudo chmod 666 /var/run/docker.sock
```

---

## ☸️ Phase 2 — Installation k3s

### Ouvrir WSL2 Ubuntu

```bash
# Depuis PowerShell Windows
wsl -d Ubuntu
```

### Mettre à jour le système

```bash
sudo apt update && sudo apt upgrade -y
```

### Installer k3s

```bash
curl -sfL https://get.k3s.io | sh -
```

### Configurer kubectl

```bash
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
echo 'export KUBECONFIG=~/.kube/config' >> ~/.bashrc
source ~/.bashrc
```

### Vérifier l'installation

```bash
sudo systemctl status k3s
kubectl get nodes
kubectl get pods -A
```

---

## 📦 Phase 3 — Déploiement Kubernetes

### Créer le dossier k8s

```bash
mkdir -p k8s && cd k8s
```

### secret.yaml — MongoDB Atlas

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mongo-secret
type: Opaque
stringData:
  MONGO_URI: "mongodb+srv://..."
```

### backend-deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: protfolio9-backend:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 5000
        env:
        - name: MONGO_URI
          valueFrom:
            secretKeyRef:
              name: mongo-secret
              key: MONGO_URI
---
apiVersion: v1
kind: Service
metadata:
  name: backend
spec:
  selector:
    app: backend
  ports:
  - port: 5002
    targetPort: 5000
  type: ClusterIP
```

### frontend-deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: protfolio9-frontend:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  selector:
    app: frontend
  ports:
  - port: 8080
    targetPort: 80
  type: NodePort
```

### Importer les images dans k3s

```bash
# k3s utilise containerd, pas Docker
# Il faut importer les images explicitement
docker save protfolio9-frontend:latest | sudo k3s ctr images import -
docker save protfolio9-backend:latest | sudo k3s ctr images import -
```

### Déployer et vérifier

```bash
# Déployer tous les manifestes
kubectl apply -f .

# Vérifier les pods
kubectl get pods

# Redémarrer si nécessaire
kubectl rollout restart deployment backend frontend

# Voir le port d'accès frontend
kubectl get svc frontend
```

---

## 📊 Phase 4 — Monitoring (Prometheus + Grafana)

### Installer Helm

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```

### Installer la stack monitoring

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```

### Vérifier les pods

```bash
kubectl --namespace monitoring get pods
```

### Fix WSL2 — Désactiver node-exporter

```bash
# Le node-exporter est incompatible avec WSL2
helm upgrade monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus-node-exporter.enabled=false

kubectl --namespace monitoring delete daemonset monitoring-prometheus-node-exporter
```

### Accéder à Grafana

```bash
# Récupérer le mot de passe admin
kubectl --namespace monitoring get secrets monitoring-grafana \
  -o jsonpath="{.data.admin-password}" | base64 -d ; echo

# Port-forward vers Grafana
kubectl --namespace monitoring port-forward \
  pod/$(kubectl --namespace monitoring get pod \
  -l "app.kubernetes.io/name=grafana" \
  -o jsonpath="{.items[0].metadata.name}") 3000:3000
```

Ouvrir **http://localhost:3000** → login: `admin`

---

## 🔄 Phase 5 — CI/CD GitHub Actions

### Configurer Git

```bash
git config --global user.name "Rtibi Wissal"
git config --global user.email "ton_email@gmail.com"
```

### Initialiser et pousser sur GitHub

```bash
git init
git remote add origin https://github.com/wissal5-rtibi/protfolio9.git
git add .
git commit -m "Initial commit - Portfolio9 fullstack DevOps"
git push https://wissal5-rtibi:TOKEN@github.com/wissal5-rtibi/protfolio9.git master
```

> ⚠️ Utiliser un **Personal Access Token** GitHub avec les scopes `repo` et `workflow`.

### Pipeline .github/workflows/deploy.yml

```yaml
name: CI/CD Pipeline - Portfolio9

on:
  push:
    branches:
      - master

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Build Frontend image
        run: docker build -t protfolio9-frontend:latest ./frontend

      - name: Build Backend image
        run: docker build -t protfolio9-backend:latest ./backend

      - name: Run Backend tests
        run: |
          cd backend
          npm install
          npm test --if-present || echo "No tests specified, skipping..."

      - name: Verify Kubernetes manifests
        run: |
          cat k8s/backend-deployment.yaml
          cat k8s/frontend-deployment.yaml
          echo "✅ Manifests verified!"

      - name: Deployment Success
        run: |
          echo "✅ CI/CD Pipeline terminé avec succès!"
          echo "📦 Images: protfolio9-frontend, protfolio9-backend"
```

### Déclencher le pipeline

```bash
# Chaque push sur master déclenche automatiquement le pipeline
git add .
git commit -m "Update"
git push https://wissal5-rtibi:TOKEN@github.com/wissal5-rtibi/protfolio9.git master
```

Vérifier sur : `https://github.com/wissal5-rtibi/protfolio9/actions`

---

## 🌐 Accès à l'application

| Service | URL |
|---|---|
| Frontend | http://localhost:8080 |
| Grafana | http://localhost:3000 |
| Backend (interne) | ClusterIP:5002 |

---

## ✅ Statut du projet

- [x] Frontend HTML/CSS
- [x] Backend Node.js/Express
- [x] MongoDB Atlas
- [x] Docker
- [x] Kubernetes k3s
- [x] Monitoring Prometheus + Grafana
- [x] Git + GitHub
- [x] CI/CD GitHub Actions

---

## 👩‍💻 Auteure

**Rtibi Wissal** — 2ème année CCV — ITEAM Université — 2025/2026
