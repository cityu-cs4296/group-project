#!/bin/bash

./init.sh

# Create nginx deployment
sed 's/%POD_COUNT%/10/g' ./configs/deployment.yaml.tmpl | kubectl apply -f -
kubectl apply -f ./configs/services.yaml
kubectl apply -f ./configs/ingress.yaml

# Wait for the deployment to be available
kubectl wait --for=condition=available deployment/nginx-deployment -n cs4296-project --timeout=60s

# Wait until the load balancer is ready
serviceHostname=$(kubectl get svc nginx-service -n cs4296-project -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
while [ -z "$serviceHostname" ]; do
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] Waiting for the load balancer to be ready..."
  sleep 5
  serviceHostname=$(kubectl get svc nginx-service -n cs4296-project -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
done

# Wait until the load balancer is healthy
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Waiting for the load balancer to be healthy..."
sleep 60

# Start the locust load generator
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Starting the locust load generator (100 Users with 100 spwan rate per second)..."
locust --headless -t 60 -u 100 -r 100 -f ../common/locust_file.py -H http://$serviceHostname --only-summary --csv=./logs/task3 &

# Keep monitoring the nodes and pods resources utilization
# Stop when the locust test is done
i=0
while [ $i -lt 50 ]; do
  kubectl top nodes
  kubectl top pods -n cs4296-project
  sleep 5
  i=$((i+5))
done

echo ""
echo "[$(date +"%Y-%m-%d %H:%M:%S")] Cleaning up deployment..."
kubectl delete deployment nginx-deployment -n cs4296-project