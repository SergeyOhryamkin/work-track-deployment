# Multi-Repository Deployment Setup

This deployment repository manages the deployment of Work Track application which consists of separate frontend and backend repositories.

## Repository Structure

Three separate root-level repositories:

```
your-projects-folder/
├── backend/                    (work-track-backend repo)
│   ├── cmd/
│   ├── internal/
│   ├── Dockerfile
│   └── ...
├── frontend/                   (work-track-frontend repo)
│   ├── src/
│   ├── Dockerfile.prod
│   ├── nginx.prod.conf
│   └── ...
└── deployment/                 (work-track-deployment repo)
    ├── nginx/
    ├── docker-compose.yml
    ├── .env.example
    └── deploy.sh
```

## Repositories

- **Backend**: `work-track-backend` (separate repo at `../backend`)
- **Frontend**: `work-track-frontend` (separate repo at `../frontend`)
- **Deployment**: `work-track-deployment` (this repo)

## Setup - Three Separate Repositories

All three repositories are cloned as siblings in the same parent directory.

### Initial Setup on Server

```bash
# Create parent directory
mkdir ~/work-track
cd ~/work-track

# Clone all three repositories
git clone https://github.com/YOUR_USERNAME/work-track-backend.git backend
git clone https://github.com/YOUR_USERNAME/work-track-frontend.git frontend
git clone https://github.com/YOUR_USERNAME/work-track-deployment.git deployment

# Your directory structure should now be:
# ~/work-track/
# ├── backend/
# ├── frontend/
# └── deployment/

# Configure and deploy
cd deployment
cp .env.example .env
nano .env  # Edit with your values
bash deploy.sh
```

### Updating Application

```bash
cd ~/work-track

# Update backend
cd backend
git pull origin master
cd ..

# Update frontend
cd frontend
git pull origin master
cd ..

# Update deployment configs
cd deployment
git pull origin master

# Rebuild and restart
docker-compose up -d --build
```

## Deployment Repository Contents

The `work-track-deployment` repository should contain:

```
work-track-deployment/
├── .gitmodules              # Submodule configuration (if using submodules)
├── docker-compose.yml       # Docker Compose configuration
├── docker-compose.dev.yml   # Development override
├── .env.example             # Environment variables template
├── .gitignore               # Git ignore rules
├── README.md                # Project overview
├── DEPLOYMENT.md            # Deployment guide
├── DEPLOYMENT_CHECKLIST.md  # Deployment checklist
├── MULTI_REPO_SETUP.md      # This file
├── deploy.sh                # Deployment script
├── nginx/
│   ├── nginx.conf           # Main nginx config
│   └── conf.d/
│       └── worktrack.conf   # Site configuration
└── scripts/
    └── generate-secrets.sh  # Secret generation script
```

## What Goes in Each Repository

### work-track-backend
- Go source code
- Dockerfile
- go.mod, go.sum
- Database migrations
- Backend-specific documentation

### work-track-frontend
- Vue.js source code
- Dockerfile.prod
- nginx.prod.conf
- package.json, package-lock.json
- Frontend-specific documentation

### work-track-deployment
- docker-compose.yml
- Nginx reverse proxy configuration
- Environment configuration
- Deployment scripts
- Deployment documentation

## Recommended Workflow

### Development

1. Work in individual repos (backend/frontend)
2. Test locally
3. Commit and push to respective repos
4. Update deployment repo submodules if needed

### Deployment

1. SSH to server
2. Navigate to deployment directory
3. Update submodules (or pull individual repos)
4. Run deployment script

```bash
cd ~/work-track-deployment

# If using submodules
git pull
git submodule update --remote

# If using manual clones
git pull
cd work-track-backend && git pull && cd ..
cd work-track-frontend && git pull && cd ..

# Deploy
bash deploy.sh
```

## Updated deploy.sh for Multi-Repo

The `deploy.sh` script has been updated to work with both submodules and manual clones.

## Advantages of This Approach

### Separation of Concerns
- Backend and frontend can be developed independently
- Different teams can work on different repos
- Easier to manage permissions

### Flexible Deployment
- Can deploy different versions of frontend/backend
- Easy to rollback individual components
- Submodules track specific commits

### Clean History
- Each repo has its own git history
- Deployment configs separate from application code
- Easier to track changes

## Migration from Monorepo

If you currently have everything in one repo:

```bash
# 1. Create new repositories on GitHub
#    - work-track-backend
#    - work-track-frontend
#    - work-track-deployment

# 2. Move backend code
cd /path/to/work_track/backend
git init
git add .
git commit -m "Initial backend commit"
git remote add origin https://github.com/YOUR_USERNAME/work-track-backend.git
git push -u origin master

# 3. Move frontend code
cd /path/to/work_track/frontend
git init
git add .
git commit -m "Initial frontend commit"
git remote add origin https://github.com/YOUR_USERNAME/work-track-frontend.git
git push -u origin master

# 4. Create deployment repo
mkdir work-track-deployment
cd work-track-deployment
git init

# Copy deployment files (nginx, docker-compose.yml, etc.)
# Add submodules
git submodule add https://github.com/YOUR_USERNAME/work-track-backend.git
git submodule add https://github.com/YOUR_USERNAME/work-track-frontend.git

git add .
git commit -m "Initial deployment setup"
git remote add origin https://github.com/YOUR_USERNAME/work-track-deployment.git
git push -u origin master
```

## Troubleshooting

### Submodule not updating
```bash
git submodule update --init --recursive --remote
```

### Submodule detached HEAD
```bash
cd work-track-backend
git checkout main
git pull
cd ..
git add work-track-backend
git commit -m "Update backend submodule"
```

### Clone without submodules by mistake
```bash
git submodule init
git submodule update
```

## Best Practices

1. **Pin submodule versions** for production deployments
2. **Test before updating** submodules in production
3. **Document dependencies** between frontend and backend versions
4. **Use tags** for releases in backend/frontend repos
5. **Keep deployment configs** in sync with application requirements

## Example: Deploying Specific Versions

```bash
# Deploy specific backend version
cd work-track-backend
git checkout v1.2.3
cd ..

# Deploy specific frontend version
cd work-track-frontend
git checkout v2.0.1
cd ..

# Update submodule references
git add work-track-backend work-track-frontend
git commit -m "Deploy backend v1.2.3 and frontend v2.0.1"

# Deploy
docker-compose up -d --build
```
