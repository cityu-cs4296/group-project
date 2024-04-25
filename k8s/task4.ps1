# Create configmap
kubectl create configmap nginx-config --from-file=../common/nginx.conf --dry-run=client -o yaml | kubectl apply -f -

# Create nginx deployment
kubectl apply -f task4.yaml

# Wait until the deployment is ready
kubectl wait --for=condition=available deployment/task4-nginx-deployment --timeout=120s

# Wait until the HPA is ready
while ($true) {
    $hpaStatus = kubectl get hpa task4-nginx-deployment-hpa -o=jsonpath='{.status.currentMetrics[0].resource.current}'
    if ($hpaStatus) {
        Write-Output "HPA can now read the metrics."
        break
    }
    Write-Output "Waiting for HPA to be able to read metrics..."
    Start-Sleep -Seconds 5
}

# Start the locust load generator
$serviceHostname = kubectl get svc nginx-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
Start-Process -NoNewWindow -FilePath "locust" -ArgumentList "--headless -t 60 -u 100 -r 100 -f ../common/locust_file.py -H http://$serviceHostname --only-summary --csv=./logs/task4"

# Keep Monitoring the HPA to check when it scales the pods
# Stop when the locust test is done
$i = 0
while ($i -lt 60) {
    Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff")] Monitoring HPA..."
    kubectl get hpa task4-nginx-deployment-hpa
    Start-Sleep -Seconds 2
    $i = $i + 2
}

Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff")] List of pods:"
kubectl get pods

$scaledOutPods = kubectl get pods -o jsonpath='{.items[*].metadata.name}'
$scaledOutPodsArray = $scaledOutPods -split " "
$scaledOutPodsCount = $scaledOutPodsArray.Length
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff")] Initial number of pods: 1"
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff")] Scaled-out number of pods: $scaledOutPodsCount"
# Loop through the pods and find out when the new pods are created
$totalTImeTaken = 0
foreach ($pod in $scaledOutPodsArray) {
    Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff")] Describing pod: $pod"
    # Get the creation time of the pod
    $podCreationTime = kubectl get pod $pod -o jsonpath='{.metadata.creationTimestamp}'
    # Get the status.conditions[*] with status.conditions[*].type = PodReadyToStartContainers
    $podReadyTime = kubectl get pod $pod -o jsonpath='{.status.conditions[?(@.type=="PodReadyToStartContainers")].lastTransitionTime}'

    Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff")] Pod creation time: $podCreationTime"
    Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff")] Pod ready time: $podReadyTime"

    # Calculate the time taken for the pod to be ready
    $podCreationTime = [datetime]::Parse($podCreationTime)
    $podReadyTime = [datetime]::Parse($podReadyTime)

    $timeTaken = $podReadyTime - $podCreationTime
    Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff")] Time taken for pod to be ready: $timeTaken"
    $totalTImeTaken += $timeTaken.TotalSeconds
}

Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff")] Total time taken for all pods to be ready: $totalTImeTaken seconds"

# Describe the HPA
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff")] Describing HPA..."
kubectl describe hpa task4-nginx-deployment-hpa
