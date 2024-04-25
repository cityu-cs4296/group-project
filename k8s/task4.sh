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
serviceHostname=$(kubectl get svc nginx-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
locust --headless -t 60 -u 100 -r 100 -f ../common/locust_file.py -H http://$serviceHostname --only-summary --csv=./logs/task4 &

# Keep Monitoring the HPA to check when it scales the pods
# Stop when the locust test is done
i=0
while (( i < 60 )); do
    echo "[$(date +'%Y-%m-%d %H:%M:%S.%3N')] Monitoring HPA..."
    kubectl get hpa task4-nginx-deployment-hpa
    sleep 2
    ((i+=2))
done

echo "[$(date +'%Y-%m-%d %H:%M:%S.%3N')] List of pods:"
kubectl get pods

scaledOutPods=$(kubectl get pods -o jsonpath='{.items[*].metadata.name}')
scaledOutPodsArray=($scaledOutPods)
scaledOutPodsCount=${#scaledOutPodsArray[@]}
echo "[$(date +'%Y-%m-%d %H:%M:%S.%3N')] Initial number of pods: 1"
echo "[$(date +'%Y-%m-%d %H:%M:%S.%3N')] Scaled-out number of pods: $scaledOutPodsCount"

# Loop through the pods and find out when the new pods are created
totalTimeTaken=0
for pod in "${scaledOutPodsArray[@]}"; do
    echo "[$(date +'%Y-%m-%d %H:%M:%S.%3N')] Describing pod: $pod"
    # Get the creation time of the pod
    podCreationTime=$(kubectl get pod $pod -o jsonpath='{.metadata.creationTimestamp}')
    # Get the status.conditions[*] with status.conditions[*].type = Ready
    podReadyTime=$(kubectl get pod $pod -o jsonpath='{.status.conditions[?(@.type=="Ready")].lastTransitionTime}')

    echo "[$(date +'%Y-%m-%d %H:%M:%S.%3N')] Pod creation time: $podCreationTime"
    echo "[$(date +'%Y-%m-%d %H:%M:%S.%3N')] Pod ready time: $podReadyTime"

    # Calculate the time taken for the pod to be ready
    podCreationTime=$(date -d"$podCreationTime" +%s)
    podReadyTime=$(date -d"$podReadyTime" +%s)

    timeTaken=$((podReadyTime-podCreationTime))
    echo "[$(date +'%Y-%m-%d %H:%M:%S.%3N')] Time taken for pod to be ready: $timeTaken seconds"
    totalTimeTaken=$((totalTimeTaken+timeTaken))
done

echo "[$(date +'%Y-%m-%d %H:%M:%S.%3N')] Total time taken for all pods to be ready: $totalTimeTaken seconds"

# Describe the HPA
echo "[$(date +'%Y-%m-%d %H:%M:%S.%3N')] Describing HPA..."
kubectl describe hpa task4-nginx-deployment-hpa