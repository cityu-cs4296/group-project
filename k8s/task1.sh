#!/bin/bash

# This script will create a deployment in Kubernetes and measure the time it takes to start up

# Function to calculate actual startup time
calculate_actual_startup_time() {
  kubeResult=$(kubectl get deployment -n cs4296-project nginx-deployment -o json)
  creationTime=$(date -d $(echo $kubeResult | jq -r '.metadata.creationTimestamp') +%s)
  lastTransitionTime=$(echo $kubeResult | jq -r '.status.conditions[] | select(.type=="Available") | .lastTransitionTime')
  lastTransitionTime=$(date -d $lastTransitionTime +%s)
  actualStartTime=$((lastTransitionTime - creationTime))
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] Actual startup time: $actualStartTime seconds (Via analyzing Kubernetes events)"
}

# Function to create deployment and measure startup time
create_deployment() {
  podCount=$1
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] Creating the deployment (Pod Count: $podCount)..."
  start=$(date +%s)
  sed s/%POD_COUNT%/$podCount/g ./configs/deployment.yaml.tmpl | kubectl apply -f -
  kubectl wait --for=condition=available deployment/nginx-deployment -n cs4296-project --timeout=60s
  end=$(date +%s)
  elapsedTime=$((end - start))
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] Kubernetes startup time: $elapsedTime seconds (Via bash script)"
  calculate_actual_startup_time
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] Cleaning up deployment..."
  kubectl delete deployment nginx-deployment -n cs4296-project
}

./init.sh
# Create deployments and measure startup times
create_deployment 1
echo ""
create_deployment 5
echo ""
create_deployment 10