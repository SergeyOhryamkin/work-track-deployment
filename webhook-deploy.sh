#!/bin/bash

# Webhook deployment script
# This script is triggered by GitHub webhooks to auto-deploy

set -e

REPO=$1
LOG_FILE="/var/log/webhook-deploy.log"

echo "$(date): Deployment triggered for $REPO" >> "$LOG_FILE"

case $REPO in
  "backend")
    cd ~/work-track/backend
    git pull origin master >> "$LOG_FILE" 2>&1
    cd ../deployment
    docker network inspect worktrack-network >/dev/null 2>&1 || docker network create worktrack-network
    docker-compose up -d --build backend >> "$LOG_FILE" 2>&1
    ;;
  "frontend")
    cd ~/work-track/frontend
    git pull origin master >> "$LOG_FILE" 2>&1
    cd ../deployment
    docker network inspect worktrack-network >/dev/null 2>&1 || docker network create worktrack-network
    docker-compose up -d --build frontend >> "$LOG_FILE" 2>&1
    ;;
  "deployment")
    cd ~/work-track/deployment
    git pull origin master >> "$LOG_FILE" 2>&1
    docker network inspect worktrack-network >/dev/null 2>&1 || docker network create worktrack-network
    docker-compose up -d nginx >> "$LOG_FILE" 2>&1
    ;;
  *)
    echo "Unknown repository: $REPO" >> "$LOG_FILE"
    exit 1
    ;;
esac

echo "$(date): Deployment completed for $REPO" >> "$LOG_FILE"
docker-compose ps >> "$LOG_FILE" 2>&1
