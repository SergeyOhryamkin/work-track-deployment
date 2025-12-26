# Work Track Deployment

Deployment configuration for the Work Track application - a work tracking system with Vue.js frontend and Go backend.

## Repository Structure

This is one of three repositories:

```
~/work-track/
├── backend/              # work-track-backend repo
├── frontend/             # work-track-frontend repo  
└── deployment/           # work-track-deployment repo (this one)
```

## What's in This Repository

Deployment configuration and orchestration:

- **docker-compose.yml** - Container orchestration
- **nginx/** - Reverse proxy configuration
- **.env.example** - Environment variables template
- **deploy.sh** - Automated deployment script
- **DEPLOYMENT.md** - Complete deployment guide
- **DEPLOYMENT_CHECKLIST.md** - Step-by-step checklist

## Quick Start

### On Your Server

```bash
# Create parent directory
mkdir ~/work-track
cd ~/work-track

# Clone all three repositories
git clone https://github.com/YOUR_USERNAME/work-track-backend.git backend
git clone https://github.com/YOUR_USERNAME/work-track-frontend.git frontend
git clone https://github.com/YOUR_USERNAME/work-track-deployment.git deployment

# Configure
cd deployment
cp .env.example .env
nano .env  # Add your secrets

# Get SSL certificate
sudo certbot certonly --standalone -d work-dent.mooo.com --agree-tos --email your@email.com

# Deploy
bash deploy.sh
```

## Directory Structure After Setup

```
~/work-track/
├── backend/                    # Backend repository
│   ├── cmd/
│   ├── internal/
│   ├── Dockerfile
│   └── ...
├── frontend/                   # Frontend repository
│   ├── src/
│   ├── Dockerfile.prod
│   ├── nginx.prod.conf
│   └── ...
└── deployment/                 # This repository
    ├── nginx/
    │   ├── nginx.conf
    │   └── conf.d/
    │       └── worktrack.conf
    ├── scripts/
    │   └── generate-secrets.sh
    ├── docker-compose.yml
    ├── .env.example
    └── deploy.sh
```

## Features

- User authentication (JWT)
- Work shift tracking
- Time logging
- Avatar uploads (Yandex S3)
- Responsive UI
- RESTful API

## Technology Stack

### Backend
- Go 1.21+
- SQLite with WAL mode
- JWT authentication
- S3-compatible storage

### Frontend
- Vue.js 3
- Vite
- PrimeVue UI components
- Vue Router
- Axios

### Infrastructure
- Docker & Docker Compose
- Nginx (reverse proxy + SSL termination)
- Let's Encrypt SSL
- Yandex Object Storage

## Resource Optimization

This application is optimized for low-resource VPS hosting:

- **SQLite** instead of PostgreSQL (saves 2-4 GB RAM)
- **No Harbor registry** (saves 4-6 GB RAM)
- **External S3 storage** instead of MinIO (saves 2-4 GB RAM)
- **Client-side image processing** (no media converter needed)
- **Docker Compose** instead of Kubernetes (saves 1.5-3 GB RAM)

Total resource savings: ~70-80% compared to traditional stack.

## Development

### Backend Development
```bash
cd backend
go mod tidy
go run cmd/api/main.go
```

### Frontend Development
```bash
cd frontend
npm install
npm run dev
```

### Build for Production
```bash
# Backend
cd backend
docker build -t worktrack-backend .

# Frontend
cd frontend
docker build -f Dockerfile.prod -t worktrack-frontend .
```

## Environment Variables

See `.env.example` for all required environment variables.

Key variables:
- `JWT_SECRET`: JWT signing key
- `S3_ENDPOINT`: Yandex Object Storage endpoint
- `S3_ACCESS_KEY`: S3 access key
- `S3_SECRET_KEY`: S3 secret key
- `S3_BUCKET`: S3 bucket name

## Monitoring

```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f backend

# Check resource usage
docker stats

# Check container status
docker-compose ps
```

## Backup

### SQLite Database
```bash
# Create backup
docker-compose exec backend cp /data/worktrack.db /data/backup-$(date +%Y%m%d).db

# Copy to host
docker cp worktrack-backend:/data/backup-$(date +%Y%m%d).db ~/backups/
```

## License

[Your License Here]

## Support

For deployment issues, see [DEPLOYMENT.md](./DEPLOYMENT.md).
