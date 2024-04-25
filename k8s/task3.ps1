# Create configmap for nginx configuration. Skip if already exists
kubectl create configmap nginx-config --from-file=../common/nginx.conf --dry-run=client -o yaml | kubectl apply -f -

# Create nginx deployment
kubectl apply -f task3.yaml

# Start the locust load generator
$serviceHostname = kubectl get svc nginx-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
Start-Process -NoNewWindow -FilePath "locust" -ArgumentList "--headless -t 60 -u 100 -r 100 -f ../common/locust_file.py -H http://$serviceHostname --only-summary --csv=./logs/task3"

# Keep monitoring the nodes and pods resources utilization
# Stop when the locust test is done
for ($i=0; $i -lt 50; $i += 5) {
    kubectl top nodes
    kubectl top pods
    Start-Sleep -Seconds 5
}