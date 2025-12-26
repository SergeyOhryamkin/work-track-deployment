# Development Environment Setup

This document explains how the development environment works.

## Overview

- **Production**: `work-dent.absl.ro` (deployed from `master` branch)
- **Development**: `dev.work-dent.absl.ro` (deployed from `dev` branch)

## Deployment Architecture

### Production
- Containers: `worktrack-backend`, `worktrack-frontend`, `worktrack-nginx`
- Database: `sqlite-data` volume
- Config: `docker-compose.yml`

### Development
- Containers: `worktrack-backend-dev`, `worktrack-frontend-dev`
- Database: `sqlite-dev-data` volume
- Config: `docker-compose.dev.yml`
- Uses same nginx with separate server block

## Environment Variables

Development uses `.env.dev` with:
- `ALLOWED_ORIGINS=https://dev.work-dent.absl.ro`
- `VITE_API_URL=https://dev.work-dent.absl.ro/api`

## CI/CD

- Push to `dev` branch → Auto-deploys to dev environment
- Push to `master` branch → Auto-deploys to production

## Manual Deployment

```bash
# Deploy dev environment
cd ~/work-track/deployment
docker-compose -f docker-compose.dev.yml up -d --build

# Deploy production
docker-compose up -d --build
```

## Database

Dev and prod use separate SQLite databases to avoid conflicts.
