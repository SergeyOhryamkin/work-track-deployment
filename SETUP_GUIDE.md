# Three-Repository Setup Guide

## Overview

The Work Track application is split into three separate Git repositories:

1. **work-track-backend** - Go API backend
2. **work-track-frontend** - Vue.js frontend
3. **work-track-deployment** - Deployment configuration (this repo)

## Local Development Setup

### Your Local Machine Structure

```
~/Projects/work_track/
├── backend/              # git: work-track-backend
├── frontend/             # git: work-track-frontend
└── deployment/           # git: work-track-deployment
```

### Setting Up Locally

```bash
# Navigate to your projects folder
cd ~/Documents/Projects/work_track

# Your backend and frontend folders already exist with their own git repos
# Just create the deployment folder and initialize it

cd deployment
git init
git add .
git commit -m "Initial deployment configuration"

# Create remote repository on GitHub: work-track-deployment
git remote add origin https://github.com/YOUR_USERNAME/work-track-deployment.git
git push -u origin main
```

## Server Deployment Setup

### Directory Structure on Server

```
~/work-track/
├── backend/              # Cloned from work-track-backend
├── frontend/             # Cloned from work-track-frontend
└── deployment/           # Cloned from work-track-deployment
```

### Deployment Steps

1. **Clone all repositories**:
```bash
mkdir ~/work-track
cd ~/work-track

git clone https://github.com/YOUR_USERNAME/work-track-backend.git backend
git clone https://github.com/YOUR_USERNAME/work-track-frontend.git frontend
git clone https://github.com/YOUR_USERNAME/work-track-deployment.git deployment
```

2. **Configure environment**:
```bash
cd deployment
cp .env.example .env
nano .env  # Add your secrets
```

3. **Get SSL certificate**:
```bash
sudo certbot certonly --standalone \
  -d work-dent.mooo.com \
  --agree-tos \
  --email your@email.com
```

4. **Deploy**:
```bash
bash deploy.sh
```

## How Docker Compose Finds the Code

The `docker-compose.yml` uses relative paths:

```yaml
backend:
  build:
    context: ../backend    # Points to sibling backend folder
    
frontend:
  build:
    context: ../frontend   # Points to sibling frontend folder
```

This works because:
- Docker Compose runs from `~/work-track/deployment/`
- `../backend` resolves to `~/work-track/backend/`
- `../frontend` resolves to `~/work-track/frontend/`

## Updating the Application

### Update Backend Code

```bash
cd ~/work-track/backend
git pull origin main
cd ../deployment
docker-compose up -d --build backend
```

### Update Frontend Code

```bash
cd ~/work-track/frontend
git pull origin main
cd ../deployment
docker-compose up -d --build frontend
```

### Update Deployment Configuration

```bash
cd ~/work-track/deployment
git pull origin main
docker-compose up -d --build
```

### Update Everything

```bash
cd ~/work-track

# Pull all repos
cd backend && git pull && cd ..
cd frontend && git pull && cd ..
cd deployment && git pull

# Rebuild all containers
docker-compose up -d --build
```

## Development Workflow

### Working on Backend

```bash
cd ~/Documents/Projects/work_track/backend
# Make changes
git add .
git commit -m "Your changes"
git push origin main

# On server
cd ~/work-track/backend
git pull
cd ../deployment
docker-compose up -d --build backend
```

### Working on Frontend

```bash
cd ~/Documents/Projects/work_track/frontend
# Make changes
git add .
git commit -m "Your changes"
git push origin main

# On server
cd ~/work-track/frontend
git pull
cd ../deployment
docker-compose up -d --build frontend
```

### Working on Deployment Config

```bash
cd ~/Documents/Projects/work_track/deployment
# Make changes to nginx, docker-compose.yml, etc.
git add .
git commit -m "Your changes"
git push origin main

# On server
cd ~/work-track/deployment
git pull
docker-compose up -d --build
```

## Repository Responsibilities

### work-track-backend
- Go source code
- Backend Dockerfile
- Database migrations
- API documentation
- Backend tests

### work-track-frontend
- Vue.js source code
- Frontend Dockerfile.prod
- Frontend nginx.prod.conf
- UI components
- Frontend tests

### work-track-deployment
- docker-compose.yml
- Nginx reverse proxy config
- Environment templates
- Deployment scripts
- Deployment documentation
- SSL configuration

## Benefits of This Structure

1. **Separation of Concerns**: Each repo has a single responsibility
2. **Independent Development**: Teams can work on different repos
3. **Flexible Deployment**: Deploy different versions independently
4. **Clean History**: Each repo has its own git history
5. **Easy Rollback**: Rollback individual components
6. **Better Permissions**: Different access levels per repo

## Common Tasks

### Check Running Containers

```bash
cd ~/work-track/deployment
docker-compose ps
```

### View Logs

```bash
cd ~/work-track/deployment
docker-compose logs -f
docker-compose logs -f backend
docker-compose logs -f frontend
```

### Restart Services

```bash
cd ~/work-track/deployment
docker-compose restart
docker-compose restart backend
docker-compose restart frontend
```

### Stop Everything

```bash
cd ~/work-track/deployment
docker-compose down
```

### Backup Database

```bash
cd ~/work-track/deployment
docker cp worktrack-backend:/data/worktrack.db ~/backups/worktrack-$(date +%Y%m%d).db
```

## Troubleshooting

### "Cannot find ../backend" error

Make sure all three repos are cloned as siblings:
```bash
ls ~/work-track/
# Should show: backend  frontend  deployment
```

### Containers won't build

Check that Dockerfiles exist:
```bash
ls ~/work-track/backend/Dockerfile
ls ~/work-track/frontend/Dockerfile.prod
```

### Git conflicts

Each repo is independent, so conflicts only affect one repo at a time.

## Next Steps

1. Initialize deployment repo locally
2. Push to GitHub
3. Clone all three repos on server
4. Follow deployment checklist
5. Deploy!
