#!/bin/bash

# This script will create a pod in Kubernetes and measure the time it takes to start up

# Pre-pull the image to avoid network latency
echo "Pre-pulling the image..."
kubectl run nginx-kube --image=nginx --restart=Never
kubectl delete pod nginx-kube

# Measure the time it takes to start up the pod
echo ""
echo "Measuring the time it takes to start up the pod..."
start=$(date +%s)
kubectl run nginx-kube --image=nginx
kubectl wait --for=condition=ready pod -l run=nginx-kube
end=$(date +%s)
elapsedTime=$((end - start))
echo "Kubernetes startup time: $elapsedTime seconds (Via bash script)"

# Get the actual start time
kubeResult=$(kubectl get pod nginx-kube -o json)
creationTime=$(date -d $(echo $kubeResult | jq -r '.metadata.creationTimestamp') +%s)
containerRunningTime=$(date -d $(echo $kubeResult | jq -r '.status.containerStatuses[0].state.running.startedAt') +%s)
actualStartTime=$((containerRunningTime - creationTime))
echo "Actual startup time: $actualStartTime seconds (Via analyzing Kubernetes events)"

# Kill the pod after the test is done
echo ""
echo "Cleaning up..."
kubectl delete pod nginx-kube