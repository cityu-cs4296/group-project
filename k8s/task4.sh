#!/bin/bash

# Create configmap
./init.sh

# Create nginx deployment
sed 's/%POD_COUNT%/1/g' ./configs/deployment.yaml.tmpl | kubectl apply -f -
kubectl apply -f ./configs/services.yaml
kubectl apply -f ./configs/ingress.yaml
kubectl apply -f ./configs/hpa.yaml

# Wait until the deployment is ready
kubectl wait --for=condition=available deployment/nginx-deployment -n cs4296-project --timeout=120s

# Wait until the HPA is ready
while true; do
    hpaStatus=$(kubectl get hpa nginx-deployment-hpa -n cs4296-project -o=jsonpath='{.status.currentMetrics[0].resource.current}')
    if [[ -n "$hpaStatus" ]]; then
        echo "HPA can now read the metrics."
        break
    fi
    echo "Waiting for HPA to be able to read metrics..."
    sleep 5
done

# Start the locust load generator
serviceHostname=$(kubectl get svc nginx-service -n cs4296-project -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
while [ -z "$serviceHostname" ]; do
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] Waiting for the load balancer to be ready..."
  sleep 5
  serviceHostname=$(kubectl get svc nginx-service -n cs4296-project -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
done
locust --headless -t 60 -u 100 -r 100 -f ../common/locust_file.py -H http://$serviceHostname --only-summary --csv=./logs/task4 &
locustStartTime=$(date +'%Y-%m-%d %H:%M:%S.%3N')

# Keep Monitoring the HPA to check when it scales the pods
# Stop when the locust test is done
i=0
while (( i < 60 )); do
    echo "[$(date +'%Y-%m-%d %H:%M:%S.%3N')] Monitoring HPA..."
    kubectl get hpa nginx-deployment-hpa -n cs4296-project
    sleep 2
    ((i+=2))
done

echo "[$(date +'%Y-%m-%d %H:%M:%S.%3N')] List of pods:"
kubectl get pods -n cs4296-project

scaledOutPods=$(kubectl get pods -n cs4296-project -o jsonpath='{.items[*].metadata.name}')
scaledOutPodsArray=($scaledOutPods)
scaledOutPodsCount=${#scaledOutPodsArray[@]}
echo "[$(date +'%Y-%m-%d %H:%M:%S.%3N')] Initial number of pods: 1"
echo "[$(date +'%Y-%m-%d %H:%M:%S.%3N')] Scaled-out number of pods: $scaledOutPodsCount"

# Loop through the pods and find out when the new pods are created
totalTimeTaken=0
podCreationTimeList=()
for pod in "${scaledOutPodsArray[@]}"; do
    echo "[$(date +'%Y-%m-%d %H:%M:%S.%3N')] Describing pod: $pod"
    # Get the creation time of the pod
    podCreationTime=$(kubectl get pod -n cs4296-project $pod -o jsonpath='{.metadata.creationTimestamp}')
    # Get the status.conditions[*] with status.conditions[*].type = Ready
    podReadyTime=$(kubectl get pod -n cs4296-project $pod -o jsonpath='{.status.conditions[?(@.type=="Ready")].lastTransitionTime}')

    echo "[$(date +'%Y-%m-%d %H:%M:%S.%3N')] Pod creation time: $podCreationTime"
    echo "[$(date +'%Y-%m-%d %H:%M:%S.%3N')] Pod ready time: $podReadyTime"

    # Calculate the time taken for the pod to be ready
    podCreationTime=$(date -d"$podCreationTime" +%s)
    podReadyTime=$(date -d"$podReadyTime" +%s)

    timeTaken=$((podReadyTime-podCreationTime))
    echo "[$(date +'%Y-%m-%d %H:%M:%S.%3N')] Time taken for pod to be ready: $timeTaken seconds"
    totalTimeTaken=$((totalTimeTaken+timeTaken))
    # Store the YYYY-MM-DDTHH:MM:SS.3N time format
    podCreationTimeList+=( "$(date -d@$podCreationTime +'%Y-%m-%d %H:%M:%S.%3N')" )
done

echo "[$(date +'%Y-%m-%d %H:%M:%S.%3N')] Total time taken for all pods to be ready: $totalTimeTaken seconds"

# Calculate the average time taken for the pods to be ready
averageTimeTaken=$((totalTimeTaken/scaledOutPodsCount))
echo "[$(date +'%Y-%m-%d %H:%M:%S.%3N')] Average time taken for pods to be ready: $averageTimeTaken seconds"

# List out the pod creation times
# List out the time that each pod was created
echo "[$(date +'%Y-%m-%d %H:%M:%S.%3N')] Load generator test started at: $locustStartTime"
for podCreationTime in "${podCreationTimeList[@]}"; do
    echo "[$(date +'%Y-%m-%d %H:%M:%S.%3N')] HPA Scaled Pod creation time: $podCreationTime"
done

# Describe the HPA
echo "[$(date +'%Y-%m-%d %H:%M:%S.%3N')] Describing HPA..."
kubectl describe hpa nginx-deployment-hpa -n cs4296-project