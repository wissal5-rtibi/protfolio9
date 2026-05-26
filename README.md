# 🐳 Guide Complet — Dockerisation du Projet Portfolio

> Enchaînement logique complet : GitHub → MongoDB Atlas → Node.js → Docker → GitHub

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)

---

## 📋 Enchaînement des étapes

| # | Phase | Description |
|---|---|---|
| 1 | GitHub | Créer un compte et un dépôt |
| 2 | MongoDB Atlas | Créer un cluster et récupérer l'URI |
| 3 | Node.js | Installer Node.js sur WSL2 |
| 4 | Backend | Initialiser le projet Express |
| 5 | .env | Configurer la connexion MongoDB |
| 6 | Docker | Installer Docker Desktop |
| 7 | Dockerfile Backend | Conteneuriser le backend |
| 8 | Dockerfile Frontend | Conteneuriser le frontend |
| 9 | Docker Compose | Orchestrer les services |
| 10 | Git & GitHub | Versionner et pousser le code |

---

## 🐙 Étape 1 — Créer un compte GitHub

1. Aller sur [https://github.com](https://github.com)
2. Cliquer sur **Sign up**
3. Remplir : email, mot de passe, nom d'utilisateur
4. Valider l'email de confirmation
5. Créer un dépôt : **New repository** → Nom : `protfolio9` → Public → **Create**

### Créer un Personal Access Token

1. Photo de profil → **Settings**
2. **Developer settings** (tout en bas)
3. **Personal access tokens** → **Tokens (classic)**
4. **Generate new token (classic)**
5. Cocher : `repo` ✅ et `workflow` ✅
6. **Generate token** → Copier immédiatement ⚠️

> ⚠️ Le token ne s'affiche qu'une seule fois !

---

## 🍃 Étape 2 — Créer un compte MongoDB Atlas

1. Aller sur [https://www.mongodb.com/atlas](https://www.mongodb.com/atlas)
2. **Try Free** → Créer un compte
3. Choisir le plan **gratuit (Free/Shared)**
4. Provider : AWS → Région proche → **Create Cluster**

### Configurer l'accès

1. **Database Access** → Add New Database User
   - Username : `portfolioStudent`
   - Password : (noter le mot de passe)
   - Rôle : **Atlas admin**
2. **Network Access** → Add IP Address → **Allow Access from Anywhere** (`0.0.0.0/0`)

### Récupérer l'URI

1. **Clusters** → **Connect** → **Connect your application**
2. Driver : Node.js → Copier l'URI

```
mongodb+srv://portfolioStudent:PASSWORD@cluster0.xxxxx.mongodb.net/portfolio
```

---

## 🟢 Étape 3 — Installation de Node.js (WSL2)

```bash
# Ouvrir Ubuntu depuis PowerShell
wsl -d Ubuntu

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

---

## 📦 Étape 4 — Initialisation du Backend

```bash
# Créer le dossier backend
mkdir backend && cd backend

# Initialiser le projet Node.js
npm init -y

# Installer les dépendances
npm install express
npm install mongoose
npm install dotenv
npm install cors

# Vérifier les modules installés
npm list --depth=0
cat package.json

# Tester sans Docker
node server.js
curl http://localhost:5000
```

---

## 🔐 Étape 5 — Fichier .env

```bash
# Créer le fichier .env dans le dossier backend
touch .env
nano .env
```

Contenu du fichier `.env` :

```env
MONGO_URI=mongodb+srv://portfolioStudent:PASSWORD@cluster0.xxxxx.mongodb.net/portfolio
PORT=5000
```

```bash
# Protéger .env avec .gitignore
echo '.env' >> .gitignore
echo 'node_modules/' >> .gitignore
```

> ⚠️ Ne jamais pousser `.env` sur GitHub !

---

## 🐳 Étape 6 — Installation de Docker

1. Télécharger **Docker Desktop** sur [https://www.docker.com](https://www.docker.com)
2. Installer et redémarrer Windows si demandé
3. Docker Desktop → **Settings** → **Resources** → **WSL Integration** → Activer **Ubuntu** ✅ → **Apply & Restart**

```bash
# Vérifier Docker dans WSL2
docker -v
docker ps
docker images

# Fix permissions si nécessaire
sudo chmod 666 /var/run/docker.sock
```

---

## ⚙️ Étape 7 — Dockerfile Backend

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

| Instruction | Description |
|---|---|
| `FROM node:20` | Image de base Node.js 20 |
| `WORKDIR /app` | Dossier de travail dans le conteneur |
| `COPY package*.json ./` | Copie les dépendances (optimisation cache) |
| `RUN npm install` | Installe les dépendances |
| `COPY . .` | Copie le code source |
| `EXPOSE 5001` | Port exposé par le conteneur |
| `CMD ["node", "server.js"]` | Commande de démarrage |

```bash
# Builder l'image backend
docker build -t contact-backend .
docker build -t protfolio9-backend:latest .

# Lancer le conteneur backend
docker run -p 5001:5000 --env-file .env contact-backend

# Vérifier
docker images
docker ps
```

---

## 🌐 Étape 8 — Dockerfile Frontend

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
# Builder l'image frontend
docker build -t portfolio-frontend .
docker build -t protfolio9-frontend:latest .

# Lancer le conteneur frontend
docker run -p 8080:80 portfolio-frontend

# Accéder sur http://localhost:8080
```

---

## 🔀 Étape 9 — Docker Compose

Créer `docker-compose.yml` à la racine du projet :

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
# Lancer tous les services
docker compose up --build

# En arrière-plan
docker compose up -d

# Voir l'état
docker compose ps

# Voir les logs
docker compose logs
docker compose logs backend

# Arrêter
docker compose down

# Redémarrer
docker compose restart
```

> ✅ Frontend accessible sur **http://localhost:8080**
> ✅ Backend accessible sur **http://localhost:5002**

---

## 📤 Étape 10 — Git & GitHub

```bash
# Configurer Git (première fois)
git config --global user.name "Rtibi Wissal"
git config --global user.email "ton_email@gmail.com"

# Initialiser Git
cd ~/protfolio9
git init
git remote add origin https://github.com/wissal5-rtibi/protfolio9.git

# Premier commit
git add .
git status
git commit -m "Initial commit - Portfolio9 fullstack DevOps"

# Pousser sur GitHub
git push https://wissal5-rtibi:TOKEN@github.com/wissal5-rtibi/protfolio9.git master

# Vérifier
git log --oneline
```

---

## 📋 Récapitulatif des commandes

| Phase | Commande | Rôle |
|---|---|---|
| Node.js | `nvm install 20` | Installer Node.js |
| Node.js | `npm init -y` | Initialiser le projet |
| Node.js | `npm install express mongoose dotenv cors` | Dépendances |
| Node.js | `npm list --depth=0` | Vérifier les modules |
| Node.js | `node server.js` | Tester sans Docker |
| Docker | `docker -v` | Vérifier Docker |
| Docker | `docker build -t IMAGE .` | Builder une image |
| Docker | `docker run -p 8080:80 IMAGE` | Lancer un conteneur |
| Docker | `docker images` | Lister les images |
| Docker | `docker ps` | Conteneurs actifs |
| Compose | `docker compose up --build` | Lancer tous les services |
| Compose | `docker compose ps` | État des conteneurs |
| Compose | `docker compose down` | Arrêter les services |
| Git | `git add . && git commit -m 'msg'` | Commiter |
| Git | `git push https://USER:TOKEN@github.com/...` | Pousser |

---

## 👩‍💻 Auteure

**Rtibi Wissal** — 2ème année CCV — ITEAM Université — 2025/2026
