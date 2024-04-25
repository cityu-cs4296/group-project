#!/bin/bash

# Create configmap for nginx configuration. SKip if already exists
kubectl create configmap nginx-config --from-file=../common/nginx.conf --dry-run=client -o yaml | kubectl apply -f -

# Create nginx deployment
kubectl apply -f task3.yaml

# Start the locust load generator
locust --headless -t 60 -u 100 -r 100 -f ../common/locust_file.py -H http://$(kubectl get svc nginx-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}') --only-summary --csv=./logs/task3

# Keep monitoring the nodes and pods resources utilization
# Stop when the locust test is done
i = 0
while [ $i -lt 50 ]; do
    kubectl top nodes
    kubectl top pods
    sleep 5
    i=$((i+5))
done