#!/bin/bash

echo "[$(date +"%Y-%m-%d %H:%M:%S")] Initializing environment..."

# Install kubectl if not already installed
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Checking if kubectl is installed..."
if ! command -v kubectl &> /dev/null
then
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] kubectl not found. Installing kubectl..."
  sudo yum install -y kubectl
fi

# Install pip if not already installed
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Checking if pip is installed..."
if ! command -v pip &> /dev/null
then
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] pip not found. Installing pip..."
  sudo yum install python-pip -y
fi

# Install locust if not already installed
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Checking if locust is installed..."
if ! command -v locust &> /dev/null
then
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] locust not found. Installing locust..."
  pip install locust
fi

echo "[$(date +"%Y-%m-%d %H:%M:%S")] Creating namespace cs4296-project..."
kubectl create namespace cs4296-project

# Pre-pull the nginx image
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Pre-pulling the nginx image..."
kubectl run nginx-kube --image=nginx --restart=Never -n cs4296-project
kubectl delete pod nginx-kube -n cs4296-project

echo "[$(date +"%Y-%m-%d %H:%M:%S")] Creating configmap for nginx configuration..."
kubectl create configmap nginx-config -n cs4296-project --from-file=../common/nginx.conf --dry-run=client -o yaml | kubectl apply -f -

echo "[$(date +"%Y-%m-%d %H:%M:%S")] Initializing environment... Done!"