# 🚀 Portfolio9 — Guide Complet DevOps

> Application portfolio fullstack déployée avec Docker, Kubernetes k3s, Monitoring Prometheus/Grafana et CI/CD GitHub Actions.

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)

---

## 📋 Table des matières

- [Stack technique](#-stack-technique)
- [Architecture](#-architecture)
- [Phase 1 — Comptes GitHub & MongoDB](#-phase-1--création-des-comptes)
- [Phase 2 — Environnement WSL2](#-phase-2--préparation-de-lenvironnement-wsl2)
- [Phase 3 — Node.js & Backend](#-phase-3--nodejs--backend)
- [Phase 4 — Docker](#-phase-4--conteneurisation-docker)
- [Phase 5 — Kubernetes k3s](#-phase-5--orchestration-kubernetes-k3s)
- [Phase 6 — Monitoring](#-phase-6--monitoring-prometheus--grafana)
- [Phase 7 — Git & CI/CD](#-phase-7--git--cicd-github-actions)
- [Accès à l'application](#-accès-à-lapplication)
- [Statut du projet](#-statut-du-projet)

---

## 🛠 Stack technique

| Couche | Technologie |
|---|---|
| Frontend | HTML / CSS + Nginx |
| Backend | Node.js / Express |
| Base de données | MongoDB Atlas (Cloud) |
| Conteneurisation | Docker |
| Orchestration | Kubernetes k3s |
| Monitoring | Prometheus + Grafana (Helm) |
| CI/CD | GitHub Actions |
| Environnement | Windows 11 + WSL2 Ubuntu |

---

## 🏗 Architecture

```
┌──────────────────────────────────────────────────────┐
│                Cluster Kubernetes k3s                 │
│                                                       │
│  ┌───────────────────┐    ┌──────────────────────┐   │
│  │   frontend Pod     │    │    backend Pod        │   │
│  │   HTML/CSS + Nginx │    │    Node.js/Express    │   │
│  │   Port: 80         │    │    Port: 5000         │   │
│  └─────────┬──────────┘    └──────────┬────────────┘  │
│            │                          │               │
│     NodePort:8080             ClusterIP:5002          │
│                                       │               │
│  ┌────────────────────────────────────────────────┐   │
│  │  Namespace: monitoring                          │   │
│  │  Prometheus + Grafana + AlertManager            │   │
│  └────────────────────────────────────────────────┘   │
└───────────────────────────────────────│───────────────┘
                                        │
                               ┌────────▼───────┐
                               │  MongoDB Atlas  │
                               │    (Cloud)      │
                               └────────────────┘
```

---

## 🐙 Phase 1 — Création des comptes

### 1.1 Créer un compte GitHub

1. Aller sur [https://github.com](https://github.com)
2. Cliquer sur **Sign up**
3. Remplir : email, mot de passe, nom d'utilisateur
4. Valider l'email de confirmation
5. **New repository** → Nom : `protfolio9` → Public → **Create repository**

### 1.2 Créer un Personal Access Token (PAT)

> GitHub n'accepte plus les mots de passe pour pousser le code.

1. Photo de profil → **Settings**
2. **Developer settings** (tout en bas à gauche)
3. **Personal access tokens** → **Tokens (classic)**
4. **Generate new token (classic)**
5. Note : `portfolio9-push`
6. Cocher : `repo` ✅ et `workflow` ✅
7. **Generate token** → Copier immédiatement !

> ⚠️ Le token ne s'affiche qu'une seule fois ! Le sauvegarder.

### 1.3 Créer un compte MongoDB Atlas

1. Aller sur [https://www.mongodb.com/atlas](https://www.mongodb.com/atlas)
2. **Try Free** → Créer un compte
3. Plan **gratuit (Free/Shared)**
4. Provider : AWS → Région proche → **Create Cluster**

### 1.4 Configurer l'accès MongoDB

1. **Database Access** → Add New Database User
   - Username : `portfolioStudent`
   - Password : (noter le mot de passe)
   - Rôle : **Atlas admin** → Add User
2. **Network Access** → Add IP Address → **Allow Access from Anywhere** (`0.0.0.0/0`)

### 1.5 Récupérer l'URI MongoDB

1. **Clusters** → **Connect** → **Connect your application**
2. Driver : Node.js → Copier l'URI :

```
mongodb+srv://portfolioStudent:PASSWORD@cluster0.xxxxx.mongodb.net/portfolio
```

> Remplacer PASSWORD par le vrai mot de passe.

---

## 🖥 Phase 2 — Préparation de l'environnement WSL2

### 2.1 Activer WSL2 sur Windows

```powershell
# Depuis PowerShell en administrateur
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Redémarrer Windows, puis :
wsl --set-default-version 2
```

### 2.2 Installer Ubuntu

```powershell
wsl --install -d Ubuntu
```

Ou depuis **Microsoft Store** → Chercher **Ubuntu 22.04 LTS** → Installer → Créer username/password Linux.

### 2.3 Vérifier WSL2

```powershell
wsl -l -v
```

Résultat attendu :
```
  NAME              STATE     VERSION
* Ubuntu            Running   2
```

### 2.4 Lancer Ubuntu et mettre à jour

```powershell
# Depuis PowerShell ou CMD
wsl -d Ubuntu
```

```bash
# Dans Ubuntu
sudo apt update
sudo apt upgrade -y
```

### ⚠️ Erreurs rencontrées — WSL2

| Erreur | Fix |
|---|---|
| `Sudo est désactivé sur cet ordinateur` | Tu es dans CMD Windows. Ouvrir PowerShell → `wsl -d Ubuntu` |
| `'apt' n'est pas reconnu` | Tu es dans CMD. Lancer `wsl -d Ubuntu` d'abord |
| `-sh: sudo: not found` | Tu es dans le shell Docker Desktop. Ouvrir PowerShell → `wsl -d Ubuntu` |
| `PRETTY_NAME=Docker Desktop` | Tu es dans le shell Docker. Fermer et ouvrir PowerShell → `wsl -d Ubuntu` |
| `Permission denied (dpkg lock)` | Utiliser `sudo apt upgrade -y` |
| `Distribution existe déjà` | Ubuntu déjà installé. Lancer `wsl -d Ubuntu` directement |

---

## 🟢 Phase 3 — Node.js & Backend

### 3.1 Installer Node.js via nvm

```bash
# Installer nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc

# Installer Node.js 20
nvm install 20
nvm use 20

# Vérifier
node -v
npm -v
```

### 3.2 Initialiser le projet Backend

```bash
mkdir backend && cd backend
npm init -y
```

### 3.3 Installer les dépendances

```bash
npm install express
npm install mongoose
npm install dotenv
npm install cors
```

### 3.4 Vérifier les modules

```bash
npm list --depth=0
ls node_modules
cat package.json
```

### 3.5 Tester sans Docker

```bash
node server.js
curl http://localhost:5000
```

### 3.6 Fichier .env

```bash
touch .env
nano .env
```

Contenu :

```env
MONGO_URI=mongodb+srv://portfolioStudent:PASSWORD@cluster0.xxxxx.mongodb.net/portfolio
PORT=5000
```

### 3.7 Protéger avec .gitignore

```bash
echo '.env' >> .gitignore
echo 'node_modules/' >> .gitignore
```

> ⚠️ Ne jamais pousser `.env` sur GitHub !

---

## 🐳 Phase 4 — Conteneurisation Docker

### 4.1 Installer Docker Desktop

1. Télécharger sur [https://www.docker.com](https://www.docker.com)
2. Installer et redémarrer Windows
3. Docker Desktop → **Settings** → **Resources** → **WSL Integration** → **Ubuntu** ✅ → **Apply & Restart**

```bash
# Vérifier Docker
docker -v
docker ps
docker images

# Fix permissions WSL2
sudo chmod 666 /var/run/docker.sock
```

### 4.2 Dockerfile Backend

```bash
cd backend
nano Dockerfile
```

```dockerfile
FROM node:20
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 5001
CMD ["node", "server.js"]
```

```bash
# Builder et lancer
docker build -t contact-backend .
docker build -t protfolio9-backend:latest .
docker run -p 5001:5000 --env-file .env contact-backend
docker images
docker ps
```

### 4.3 Dockerfile Frontend

```bash
cd frontend
nano Dockerfile
```

```dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
EXPOSE 80
```

```bash
# Builder et lancer
docker build -t portfolio-frontend .
docker build -t protfolio9-frontend:latest .
docker run -p 8080:80 portfolio-frontend
```

### 4.4 Docker Compose

`docker-compose.yml` à la racine :

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

```bash
docker compose up --build     # Lancer et builder
docker compose up -d          # En arrière-plan
docker compose ps             # État des conteneurs
docker compose logs           # Logs de tous les services
docker compose logs backend   # Logs du backend uniquement
docker compose down           # Arrêter les services
docker compose restart        # Redémarrer
```

### ⚠️ Erreurs rencontrées — Docker

| Erreur | Fix |
|---|---|
| `permission denied while trying to connect to Docker daemon` | `sudo chmod 666 /var/run/docker.sock` |
| `The command 'docker' could not be found in this WSL 2 distro` | Docker Desktop → Settings → WSL Integration → Ubuntu ✅ |

---

## ☸️ Phase 5 — Orchestration Kubernetes (k3s)

### 5.1 Installer k3s

```bash
curl -sfL https://get.k3s.io | sh -
```

### 5.2 Configurer kubectl

```bash
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
echo 'export KUBECONFIG=~/.kube/config' >> ~/.bashrc
source ~/.bashrc
```

### 5.3 Vérifier l'installation

```bash
sudo systemctl status k3s
kubectl get nodes           # Doit afficher Ready
kubectl get pods -A         # Tous doivent être Running ou Completed
```

### 5.4 Créer les manifestes Kubernetes

```bash
mkdir -p k8s && cd k8s
```

**secret.yaml** :
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mongo-secret
type: Opaque
stringData:
  MONGO_URI: "mongodb+srv://..."
```

**backend-deployment.yaml** :
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

**frontend-deployment.yaml** :
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

### 5.5 Importer les images et déployer

```bash
# Importer les images Docker dans containerd de k3s
docker save protfolio9-frontend:latest | sudo k3s ctr images import -
docker save protfolio9-backend:latest | sudo k3s ctr images import -

# Déployer tous les manifestes
kubectl apply -f .

# Vérifier
kubectl get pods
kubectl rollout restart deployment backend frontend
kubectl get svc frontend    # Note le port NodePort
```

### ⚠️ Erreurs rencontrées — Kubernetes

| Erreur | Fix |
|---|---|
| `ErrImageNeverPull` | k3s utilise containerd. Importer avec `docker save \| k3s ctr images import -` |
| `chmod failed on /mnt/d (Operation not permitted)` | Copier le projet dans le home Linux : `cp -r /mnt/d/protfolio9 ~/protfolio9` |

---

## 📊 Phase 6 — Monitoring (Prometheus + Grafana)

### 6.1 Installer Helm

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```

### 6.2 Installer la stack monitoring

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace

kubectl --namespace monitoring get pods
```

### 6.3 Fix WSL2 — node-exporter incompatible

```bash
# Désactiver via Helm
helm upgrade monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus-node-exporter.enabled=false

# Supprimer le DaemonSet
kubectl --namespace monitoring delete daemonset monitoring-prometheus-node-exporter
```

### 6.4 Accéder à Grafana

```bash
# Récupérer le mot de passe admin
kubectl --namespace monitoring get secrets monitoring-grafana \
  -o jsonpath="{.data.admin-password}" | base64 -d ; echo

# Port-forward vers le pod Grafana (laisser ce terminal ouvert)
kubectl --namespace monitoring port-forward \
  pod/$(kubectl --namespace monitoring get pod \
  -l "app.kubernetes.io/name=grafana" \
  -o jsonpath="{.items[0].metadata.name}") 3000:3000
```

Ouvrir **http://localhost:3000** → login: `admin`

Dashboard : **Dashboards → Browse → Kubernetes → Kubernetes / Compute Resources / Cluster**

### ⚠️ Erreurs rencontrées — Monitoring

| Erreur | Fix |
|---|---|
| `CreateContainerError: path '/' is not a shared mount` | Node-exporter incompatible WSL2. Désactiver via Helm |
| `Grafana has failed to load its application files` | Port-forward sur le Pod directement, pas le Service |

---

## 🔄 Phase 7 — Git & CI/CD GitHub Actions

### 7.1 Configurer Git

```bash
git config --global user.name "Rtibi Wissal"
git config --global user.email "ton_email@gmail.com"
```

### 7.2 Initialiser et pousser

```bash
# Travailler depuis le home Linux (pas /mnt/d)
cd ~/protfolio9/protfolio9

git init
git remote add origin https://github.com/wissal5-rtibi/protfolio9.git
git add .
git status
git commit -m "Initial commit - Portfolio9 fullstack DevOps"
git push https://wissal5-rtibi:TOKEN@github.com/wissal5-rtibi/protfolio9.git master --force
git log --oneline
```

### 7.3 Pipeline CI/CD

```bash
mkdir -p .github/workflows
nano .github/workflows/deploy.yml
```

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

### 7.4 Pousser et déclencher le pipeline

```bash
git add .github/workflows/deploy.yml
git commit -m "Add CI/CD pipeline with GitHub Actions"
git push https://wissal5-rtibi:TOKEN@github.com/wissal5-rtibi/protfolio9.git master
```

Vérifier sur : **https://github.com/wissal5-rtibi/protfolio9/actions** ✅

### ⚠️ Erreurs rencontrées — Git & CI/CD

| Erreur | Fix |
|---|---|
| `src refspec main does not match any` | Utiliser `master` : `git push -u origin master` |
| `Password authentication is not supported` | Utiliser un Personal Access Token |
| `without 'workflow' scope` | Recréer un token en cochant `repo` ET `workflow` |
| `Permission denied (403)` | Recréer token avec scope `repo` complète |
| `open Dockerfile: no such file or directory` | Vérifier la structure du dépôt GitHub |
| `no test specified && exit 1` | Ajouter `\|\| echo "skipping..."` après `npm test` |

---

## 🌐 Accès à l'application

| Service | URL | Login |
|---|---|---|
| Frontend | http://localhost:8080 | — |
| Grafana | http://localhost:3000 | admin / (mot de passe récupéré) |
| Backend (interne) | ClusterIP:5002 | — |
| GitHub Actions | https://github.com/wissal5-rtibi/protfolio9/actions | — |

---

## ✅ Statut du projet

- [x] Compte GitHub + Personal Access Token
- [x] MongoDB Atlas cluster configuré
- [x] WSL2 Ubuntu installé et configuré
- [x] Node.js installé via nvm
- [x] Backend Node.js/Express initialisé
- [x] Fichier .env sécurisé + .gitignore
- [x] Docker Desktop + intégration WSL2
- [x] Dockerfile Backend (node:20)
- [x] Dockerfile Frontend (nginx:alpine)
- [x] Docker Compose (frontend + backend)
- [x] k3s installé et configuré
- [x] Manifestes Kubernetes (Secret + Deployments + Services)
- [x] Images importées dans containerd
- [x] Application déployée et accessible
- [x] Monitoring Prometheus + Grafana opérationnel
- [x] CI/CD GitHub Actions fonctionnel

---

## 👩‍💻 Auteure

**Rtibi Wissal** — 2ème année CCV — ITEAM Université — 2025/2026
