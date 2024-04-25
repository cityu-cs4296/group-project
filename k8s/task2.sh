#!/bin/bash

function scale_and_check() {
  replicas=$1

  echo ""
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] Scaling the deployment to $replicas replicas..."
  sed s/%POD_COUNT%/$replicas/g ./configs/deployment.yaml.tmpl | kubectl apply -f -
  kubectl wait --for=condition=available deployment/nginx-deployment -n cs4296-project --timeout=60s

  echo ""
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] Sleep for 1 minute..."
  sleep 60
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] Checking the resource usage of the $replicas pods..."
  kubectl top pods -n cs4296-project
  kubectl top nodes
}

./init.sh

echo "[$(date +"%Y-%m-%d %H:%M:%S")] Cleaning up deployment..."
kubectl delete deployment nginx-deployment -n cs4296-project

scale_and_check 1
scale_and_check 5
scale_and_check 10

echo ""
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Cleaning up deployment..."
kubectl delete deployment nginx-deployment -n cs4296-project
