# Create configmap
kubectl create configmap nginx-config --from-file=../common/nginx.conf --dry-run=client -o yaml | kubectl apply -f -

# Create nginx deployment
kubectl apply -f task4.yaml

# Wait until the deployment is ready
kubectl wait --for=condition=available deployment/task4-nginx-deployment --timeout=120s

# Wait until the HPA is ready
while true; do
    hpaStatus=$(kubectl get hpa task4-nginx-deployment-hpa -o=jsonpath='{.status.currentMetrics[0].resource.current}')
    if [[ -n "$hpaStatus" ]]; then
        echo "HPA can now read the metrics."
        break
    fi
    echo "Waiting for HPA to be able to read metrics..."
    sleep 5
done

# Start the locust load generator
locust --headless -t 60 -u 100 -r 100 -f ../common/locust_file.py -H http://$hostname --only-summary --csv=./logs/task4 &

# Keep Monitoring the HPA to check when it scales the pods
# Stop when the locust test is done
i=0
while [ $i -lt 60 ]; do
    kubectl get hpa task4-nginx-deployment-hpa
    sleep 2
    i=$((i+2))
done
kubectl describe hpa task4-nginx-deployment-hpa

kubectl delete deployment task4-nginx-deployment