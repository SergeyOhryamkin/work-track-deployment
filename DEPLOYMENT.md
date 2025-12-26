# Deployment Guide

This guide covers deploying the Work Track application to a VPS with Docker Compose.

## Server Requirements

- **CPU**: 4 vCPU
- **RAM**: 6-8 GB
- **Storage**: 80-100 GB SSD
- **OS**: Ubuntu 24.04 LTS
- **Network**: IPv6 support

## Prerequisites

1. VPS with Ubuntu 24.04 LTS
2. Domain name (e.g., work-dent.mooo.com)
3. Yandex Object Storage account (for avatars)

## Initial Server Setup

### 1. Update System

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git vim htop unzip
```

### 2. Install Docker

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Log out and back in for group changes to take effect
```

### 3. Install Docker Compose

```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

### 4. Configure Firewall

```bash
sudo apt install -y ufw
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable
sudo ufw status
```

### 5. Configure Swap (for 4-6 GB RAM servers)

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
free -h
```

### 6. Install Certbot

```bash
sudo apt install -y certbot
```

## Application Deployment

### 1. Clone Repository

```bash
cd ~
git clone <your-repository-url> work-track
cd work-track
```

### 2. Configure Environment Variables

```bash
# Copy example environment file
cp .env.example .env

# Edit .env file
nano .env
```

**Required variables**:
- `JWT_SECRET`: Generate with `openssl rand -base64 32`
- `S3_ENDPOINT`: Your Yandex Object Storage endpoint
- `S3_ACCESS_KEY`: Yandex access key
- `S3_SECRET_KEY`: Yandex secret key
- `S3_BUCKET`: Your bucket name

### 3. Get SSL Certificate

**Important**: Do this BEFORE starting Docker containers.

```bash
# Stop any service on port 80
sudo systemctl stop nginx 2>/dev/null || true

# Get certificate
sudo certbot certonly --standalone \
  -d work-dent.mooo.com \
  --agree-tos \
  --email your@email.com \
  --non-interactive

# Verify certificate was created
sudo ls -la /etc/letsencrypt/live/work-dent.mooo.com/
```

### 4. Build and Start Services

```bash
# Build and start all services
docker-compose up -d --build

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

### 5. Verify Deployment

```bash
# Check if containers are running
docker-compose ps

# Check nginx logs
docker-compose logs nginx

# Check backend logs
docker-compose logs backend

# Check frontend logs
docker-compose logs frontend

# Test from browser
# Visit: https://work-dent.mooo.com
```

## SSL Certificate Auto-Renewal

Set up automatic certificate renewal:

```bash
# Create renewal script
sudo tee /usr/local/bin/renew-cert.sh > /dev/null <<'EOF'
#!/bin/bash
docker-compose -f /root/work-track/docker-compose.yml stop nginx
certbot renew --quiet
docker-compose -f /root/work-track/docker-compose.yml start nginx
EOF

# Make executable
sudo chmod +x /usr/local/bin/renew-cert.sh

# Add to crontab (runs twice daily)
echo "0 0,12 * * * root /usr/local/bin/renew-cert.sh" | sudo tee -a /etc/crontab
```

## Updating the Application

```bash
cd ~/work-track

# Pull latest changes
git pull origin master

# Rebuild and restart services
docker-compose up -d --build

# View logs to ensure everything started correctly
docker-compose logs -f
```

## Useful Commands

### Docker Compose

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# Restart services
docker-compose restart

# View logs
docker-compose logs -f

# View logs for specific service
docker-compose logs -f backend

# Rebuild and restart
docker-compose up -d --build

# Remove all containers and volumes
docker-compose down -v
```

### Database Backup (SQLite)

```bash
# Backup SQLite database
docker-compose exec backend cp /data/worktrack.db /data/worktrack-backup-$(date +%Y%m%d).db

# Copy backup to host
docker cp worktrack-backend:/data/worktrack-backup-$(date +%Y%m%d).db ~/backups/

# Restore from backup
docker cp ~/backups/worktrack-backup-20241225.db worktrack-backend:/data/worktrack.db
docker-compose restart backend
```

### Monitoring

```bash
# Check resource usage
docker stats

# Check disk usage
df -h

# Check memory usage
free -h

# Check running processes
htop
```

## Troubleshooting

### Containers won't start

```bash
# Check logs
docker-compose logs

# Check specific service
docker-compose logs backend

# Rebuild from scratch
docker-compose down
docker-compose up -d --build
```

### SSL Certificate Issues

```bash
# Check certificate
sudo certbot certificates

# Renew manually
sudo certbot renew

# Test renewal
sudo certbot renew --dry-run
```

### Port Already in Use

```bash
# Find what's using port 80
sudo lsof -i :80

# Find what's using port 443
sudo lsof -i :443

# Kill process if needed
sudo kill <PID>
```

### Out of Memory

```bash
# Check memory usage
free -h

# Check swap
sudo swapon --show

# Restart services to free memory
docker-compose restart
```

### Database Locked

```bash
# Restart backend
docker-compose restart backend

# If persistent, check for zombie processes
docker-compose exec backend ps aux
```

## Security Recommendations

1. **Change default passwords**: Update JWT_SECRET and all credentials
2. **Keep system updated**: Run `sudo apt update && sudo apt upgrade` regularly
3. **Monitor logs**: Check `docker-compose logs` for suspicious activity
4. **Backup database**: Set up automated SQLite backups
5. **Firewall**: Only allow necessary ports (22, 80, 443)
6. **SSH**: Use SSH keys instead of passwords
7. **Fail2ban**: Consider installing fail2ban for SSH protection

## Performance Optimization

### For 4 GB RAM servers:

1. **Limit container memory** (already configured in docker-compose.yml)
2. **Use swap** (configured in setup)
3. **Monitor resources**: `docker stats`
4. **Restart periodically**: Set up weekly restart if needed

### Database Optimization:

```bash
# SQLite vacuum (optimize database)
docker-compose exec backend sqlite3 /data/worktrack.db "VACUUM;"
```

## Support

For issues or questions:
- Check logs: `docker-compose logs -f`
- Review this documentation
- Check Docker and Nginx configurations
