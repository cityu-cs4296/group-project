# Create configmap
kubectl create configmap nginx-config --from-file=../common/nginx.conf --dry-run=client -o yaml | kubectl apply -f -

# Create nginx deployment
kubectl apply -f task4.yaml

# Start the locust load generator
locust --headless -t 60 -u 100 -r 100 -f ../common/locust_file.py -H http://$(kubectl get svc nginx-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}') --only-summary --csv=./logs/task4

# Keep Monitoring the HPA to check when it scales the pods
# Stop when the locust test is done
i = 0
while [ $i -lt 60 ]; do
    kubectl get hpa task4-nginx-deployment-hpa
    sleep 5
    i=$((i+5))
done
kubectl describe hpa task4-nginx-deployment-hpa