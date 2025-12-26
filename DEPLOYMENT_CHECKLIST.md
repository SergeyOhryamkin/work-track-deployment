# Deployment Checklist

Use this checklist to ensure a smooth deployment.

## Pre-Deployment (Local)

- [ ] All code changes committed to git
- [ ] `.env.example` file updated with all required variables
- [ ] Docker configurations tested locally
- [ ] Frontend builds successfully (`npm run build`)
- [ ] Backend compiles successfully (`go build`)
- [ ] All tests passing
- [ ] Push all changes to git repository

## Server Setup

- [ ] VPS purchased and accessible via SSH
- [ ] Ubuntu 24.04 LTS installed
- [ ] System updated (`sudo apt update && sudo apt upgrade -y`)
- [ ] Docker installed
- [ ] Docker Compose installed
- [ ] Firewall configured (UFW)
  - [ ] Port 22 (SSH) allowed
  - [ ] Port 80 (HTTP) allowed
  - [ ] Port 443 (HTTPS) allowed
- [ ] Swap configured (for 4-6 GB RAM servers)
- [ ] Certbot installed

## DNS Configuration

- [ ] Domain/subdomain registered (work-dent.mooo.com)
- [ ] DNS AAAA record points to server IPv6 address
- [ ] DNS propagated (test with `nslookup work-dent.mooo.com`)

## Application Setup

- [ ] Repository cloned to server
- [ ] `.env` file created from `.env.example`
- [ ] JWT_SECRET generated and added to `.env`
- [ ] Yandex Object Storage configured
  - [ ] Bucket created
  - [ ] Access keys generated
  - [ ] Credentials added to `.env`
- [ ] SSL certificate obtained
  ```bash
  sudo certbot certonly --standalone -d work-dent.mooo.com
  ```
- [ ] Certificate verified at `/etc/letsencrypt/live/work-dent.mooo.com/`

## Deployment

- [ ] Build and start containers
  ```bash
  docker-compose up -d --build
  ```
- [ ] All containers running (`docker-compose ps`)
- [ ] No errors in logs (`docker-compose logs`)
- [ ] Backend accessible internally
- [ ] Frontend accessible internally
- [ ] Nginx proxy working

## Testing

- [ ] Website accessible via HTTPS
- [ ] SSL certificate valid (no browser warnings)
- [ ] Frontend loads correctly
- [ ] API endpoints responding
- [ ] User registration works
- [ ] User login works
- [ ] Avatar upload works (Yandex S3)
- [ ] Database writes working (SQLite)

## Post-Deployment

- [ ] SSL auto-renewal configured
- [ ] Backup strategy implemented
- [ ] Monitoring set up (optional)
- [ ] Documentation updated
- [ ] Team notified of deployment

## Security Checklist

- [ ] Strong JWT_SECRET set
- [ ] Firewall properly configured
- [ ] SSH key-based authentication enabled
- [ ] Root login disabled
- [ ] All default passwords changed
- [ ] HTTPS enforced (HTTP redirects to HTTPS)
- [ ] Security headers configured in Nginx
- [ ] Database file permissions correct
- [ ] `.env` file not committed to git
- [ ] Sensitive data not in logs

## Rollback Plan

If deployment fails:

1. Check logs: `docker-compose logs -f`
2. Stop containers: `docker-compose down`
3. Revert to previous version: `git checkout <previous-commit>`
4. Rebuild: `docker-compose up -d --build`
5. If database issues, restore from backup

## Useful Commands Reference

```bash
# View logs
docker-compose logs -f

# Restart services
docker-compose restart

# Stop services
docker-compose down

# Update application
git pull && docker-compose up -d --build

# Backup database
docker cp worktrack-backend:/data/worktrack.db ~/backup-$(date +%Y%m%d).db

# Check resource usage
docker stats

# Check SSL certificate
sudo certbot certificates

# Renew SSL certificate
sudo certbot renew
```

## Troubleshooting

### Containers won't start
- Check logs: `docker-compose logs`
- Verify `.env` file exists and is correct
- Check disk space: `df -h`
- Check memory: `free -h`

### SSL certificate errors
- Verify domain points to server: `nslookup work-dent.mooo.com`
- Check certificate exists: `sudo ls /etc/letsencrypt/live/work-dent.mooo.com/`
- Renew certificate: `sudo certbot renew`

### Database errors
- Check SQLite file exists: `docker-compose exec backend ls -la /data/`
- Check permissions
- Restart backend: `docker-compose restart backend`

### Out of memory
- Check swap: `free -h`
- Restart services: `docker-compose restart`
- Consider upgrading server

## Success Criteria

Deployment is successful when:
- ✅ Website loads at https://work-dent.mooo.com
- ✅ SSL certificate is valid
- ✅ Users can register and login
- ✅ All features working as expected
- ✅ No errors in logs
- ✅ Resource usage is acceptable
