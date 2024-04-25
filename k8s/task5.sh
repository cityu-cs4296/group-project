#!/bin/bash

create_deployment() {
  podCount=$1
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] Creating the deployment (Pod Count: $podCount)..."
  sed s/%POD_COUNT%/$podCount/g ./configs/deployment.yaml.tmpl | kubectl apply -f -
  kubectl wait --for=condition=available deployment/nginx-deployment -n cs4296-project --timeout=60s
}

kubectl delete hpa nginx-deployment-hpa -n cs4296-project
kubectl delete deployment nginx-deployment -n cs4296-project
kubectl apply -f ./configs/services.yaml
kubectl apply -f ./configs/ingress.yaml

# Wait until the load balancer is ready
serviceHostname=$(kubectl get svc nginx-service -n cs4296-project -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
while [ -z "$serviceHostname" ]; do
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] Waiting for the load balancer to be ready..."
    sleep 5
    serviceHostname=$(kubectl get svc nginx-service -n cs4296-project -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
done

calculate_actual_startup_time() {
    # Loop all the pods and get the creation time, available time
    pods=$(kubectl get pods -n cs4296-project -o jsonpath='{.items[*].metadata.name}')
    # Split the pods into an array
    podsArray=($pods)
    # Get the number of pods
    podCount=${#podsArray[@]}
    totalTimeTaken=0
    for pod in $pods; do
        kubeResult=$(kubectl get pod -n cs4296-project $pod -o json)
        creationTime=$(date -d $(echo $kubeResult | jq -r '.metadata.creationTimestamp') +%s)
        lastTransitionTime=$(echo $kubeResult | jq -r '.status.conditions[] | select(.type=="Ready") | .lastTransitionTime')
        lastTransitionTime=$(date -d $lastTransitionTime +%s)
        actualStartTime=$((lastTransitionTime - creationTime))
        totalTimeTaken=$((totalTimeTaken + actualStartTime))
        echo "[$(date +"%Y-%m-%d %H:%M:%S")] Actual startup time: $actualStartTime seconds (Via analyzing Kubernetes events)"
    done
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] Total time taken: $totalTimeTaken seconds (Via analyzing Kubernetes events)"
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] Average time taken: $((totalTimeTaken / podCount)) seconds (Via analyzing Kubernetes events)"
}

# Manually stop the pod
interrupt_pod() {
    podCount=$1
    create_deployment $podCount
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] Total number of pods: $podCount"

    # Delete all the pods
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] Deleting all the pods under cs4296-project namespace..."
    kubectl delete pods -n cs4296-project --all

    # Wait for the deployment to be available
    start=$(date +%s)
    kubectl wait --for=condition=available deployment/nginx-deployment -n cs4296-project --timeout=60s
    end=$(date +%s)
    elapsedTime=$((end - start))
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] Kubernetes startup time: $elapsedTime seconds (Via bash script)"
    calculate_actual_startup_time
    # Cleaning up
    kubectl delete deployment nginx-deployment -n cs4296-project
}

./init.sh
echo ""

# Create nginx deployment
interrupt_pod 1
echo ""
interrupt_pod 5
echo ""
interrupt_pod 10
