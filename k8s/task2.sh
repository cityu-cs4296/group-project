#!/bin/bash

echo "[$(date +"%Y-%m-%d %H:%M:%S")] Cleaning up deployment..."
kubectl delete deployment task1-nginx-deployment

echo ""
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Creating the 1 pod..."
kubectl apply -f task1-1.yaml
kubectl wait --for=condition=available deployment/task1-nginx-deployment --timeout=60s

echo ""
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Sleep for 1 minute..."
sleep 60
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Checking the resource usage of the 1 pod..."
kubectl top pods --all-namespaces
kubectl top nodes

echo ""
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Scaling the deployment to 5 replicas..."
kubectl apply -f task1-5.yaml
kubectl wait --for=condition=available deployment/task1-nginx-deployment --timeout=60s

echo ""
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Sleep for 1 minute..."
sleep 60
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Checking the resource usage of the 5 pods..."
kubectl top pods --all-namespaces
kubectl top nodes

echo ""
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Scaling the deployment to 10 replicas..."
kubectl apply -f task1-10.yaml
kubectl wait --for=condition=available deployment/task1-nginx-deployment --timeout=60s

echo ""
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Sleep for 1 minute..."
sleep 60
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Checking the resource usage of the 10 pod..."
kubectl top pods --all-namespaces
kubectl top nodes

echo ""
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Cleaning up deployment..."
kubectl delete deployment task1-nginx-deployment