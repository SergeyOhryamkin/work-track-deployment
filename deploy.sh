#!/bin/bash

# Work Track Deployment Script
# This script helps deploy the application on a fresh VPS

set -e

echo "=== Work Track Deployment Script ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}Please do not run as root${NC}"
    exit 1
fi

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Check if .env file exists
if [ ! -f .env ]; then
    print_error ".env file not found!"
    echo "Please copy .env.example to .env and configure it:"
    echo "  cp .env.example .env"
    echo "  nano .env"
    exit 1
fi

print_success ".env file found"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed"
    echo "Please install Docker first. See DEPLOYMENT.md"
    exit 1
fi

print_success "Docker is installed"

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed"
    echo "Please install Docker Compose first. See DEPLOYMENT.md"
    exit 1
fi

print_success "Docker Compose is installed"

# Check if SSL certificate exists
DOMAIN="work-dent.absl.ro"
if [ ! -d "/etc/letsencrypt/live/$DOMAIN" ]; then
    print_error "SSL certificate not found for $DOMAIN"
    echo ""
    echo "Please obtain SSL certificate first:"
    echo "  sudo certbot certonly --standalone -d $DOMAIN --agree-tos --email your@email.com"
    echo ""
    read -p "Do you want to continue without SSL? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    print_success "SSL certificate found"
fi

# Create necessary directories
print_info "Creating directories..."
mkdir -p data/sqlite
mkdir -p nginx/conf.d
print_success "Directories created"

# Pull latest changes (if git repo)
if [ -d .git ]; then
    print_info "Pulling latest changes from git..."
    git pull origin main || git pull origin master || print_info "Could not pull from git"
fi

# Build and start services
print_info "Building and starting Docker containers..."
docker-compose down 2>/dev/null || true
docker-compose up -d --build

# Wait for services to start
print_info "Waiting for services to start..."
sleep 10

# Check if containers are running
if docker-compose ps | grep -q "Up"; then
    print_success "Containers are running"
else
    print_error "Some containers failed to start"
    echo "Check logs with: docker-compose logs"
    exit 1
fi

# Show status
echo ""
echo "=== Deployment Status ==="
docker-compose ps

echo ""
echo "=== Useful Commands ==="
echo "View logs:           docker-compose logs -f"
echo "Restart services:    docker-compose restart"
echo "Stop services:       docker-compose down"
echo "Update application:  git pull && docker-compose up -d --build"
echo ""

print_success "Deployment complete!"
echo ""
echo "Your application should be available at: https://$DOMAIN"
