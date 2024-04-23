#!/bin/bash

# This script will create a deployment in Kubernetes and measure the time it takes to start up

# Function to calculate actual startup time
calculate_actual_startup_time() {
  kubeResult=$(kubectl get deployment task1-nginx-deployment -o json)
  creationTime=$(date -d $(echo $kubeResult | jq -r '.metadata.creationTimestamp') +%s)
  lastTransitionTime=$(echo $kubeResult | jq -r '.status.conditions[] | select(.type=="Available") | .lastTransitionTime')
  lastTransitionTime=$(date -d $lastTransitionTime +%s)
  actualStartTime=$((lastTransitionTime - creationTime))
  echo "Actual startup time: $actualStartTime seconds (Via analyzing Kubernetes events)"
}

# Function to create deployment and measure startup time
create_deployment() {
  yamlFile=$1
  echo "Creating the deployment from $yamlFile..."
  start=$(date +%s)
  kubectl apply -f $yamlFile
  kubectl wait --for=condition=available deployment/task1-nginx-deployment --timeout=60s
  end=$(date +%s)
  elapsedTime=$((end - start))
  echo "Kubernetes startup time: $elapsedTime seconds (Via bash script)"
  calculate_actual_startup_time
  echo "Cleaning up deployment..."
  kubectl delete deployment task1-nginx-deployment
}

# Create deployments and measure startup times
create_deployment task1-1.yaml
create_deployment task1-5.yaml
create_deployment task1-10.yaml