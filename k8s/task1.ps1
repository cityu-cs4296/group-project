# This script will create a pod in Kubernetes and measure the time it takes to start up

# Pre-pull the image to avoid network latency
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Pre-pulling the image..."
kubectl run nginx-kube --image=nginx --restart=Never
kubectl delete pod nginx-kube

# Measure the time it takes to start up the pod
Write-Output ""
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Measuring the time it takes to start up the pod..."

Write-Output ""
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Creating the 1 pod..."
$start = Get-Date
kubectl apply -f task1-1.yaml
# Wait for the deployment to be ready
kubectl wait --for=condition=available deployment/task1-nginx-deployment --timeout=60s
$end = Get-Date
$elapsedTime = $end - $start
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Kubernetes startup time: $($elapsedTime.TotalSeconds) seconds (Via bash script)"

# Get the actual start time
$kubeResult = kubectl get deployment task1-nginx-deployment -o json | ConvertFrom-Json
$creationTime = Get-Date -Date $kubeResult.metadata.creationTimestamp
# Find the time the container available lastTransitionTime
# Loop through the status.conditions array and find the lastTransitionTime that has the type "Available"
$lastTransitionTime = $kubeResult.status.conditions | Where-Object { $_.type -eq "Available" } | Select-Object -ExpandProperty lastTransitionTime
$actualStartTime = $lastTransitionTime - $creationTime
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Actual startup time: $($actualStartTime.TotalSeconds) seconds (Via analyzing Kubernetes events)"
# Remove the deployment
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Cleaning up deployment..."
kubectl delete deployment task1-nginx-deployment

Write-Output ""
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Creating the 5 pod..."
$start = Get-Date
kubectl apply -f task1-5.yaml
# Wait for the deployment to be ready
kubectl wait --for=condition=available deployment/task1-nginx-deployment --timeout=60s
$end = Get-Date
$elapsedTime = $end - $start
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Kubernetes startup time: $($elapsedTime.TotalSeconds) seconds (Via bash script)"

# Get the actual start time
$kubeResult = kubectl get deployment task1-nginx-deployment -o json | ConvertFrom-Json
$creationTime = Get-Date -Date $kubeResult.metadata.creationTimestamp
# Find the time the container available lastTransitionTime
# Loop through the status.conditions array and find the lastTransitionTime that has the type "Available"
$lastTransitionTime = $kubeResult.status.conditions | Where-Object { $_.type -eq "Available" } | Select-Object -ExpandProperty lastTransitionTime
$actualStartTime = $lastTransitionTime - $creationTime
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Actual startup time: $($actualStartTime.TotalSeconds) seconds (Via analyzing Kubernetes events)"
# Remove the deployment
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Cleaning up deployment..."
kubectl delete deployment task1-nginx-deployment


Write-Output ""
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Creating the 10 pod..."
$start = Get-Date
kubectl apply -f task1-10.yaml
# Wait for the deployment to be ready
kubectl wait --for=condition=available deployment/task1-nginx-deployment --timeout=60s
$end = Get-Date
$elapsedTime = $end - $start
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Kubernetes startup time: $($elapsedTime.TotalSeconds) seconds (Via bash script)"

# Get the actual start time
$kubeResult = kubectl get deployment task1-nginx-deployment -o json | ConvertFrom-Json
$creationTime = Get-Date -Date $kubeResult.metadata.creationTimestamp
# Find the time the container available lastTransitionTime
# Loop through the status.conditions array and find the lastTransitionTime that has the type "Available"
$lastTransitionTime = $kubeResult.status.conditions | Where-Object { $_.type -eq "Available" } | Select-Object -ExpandProperty lastTransitionTime
$actualStartTime = $lastTransitionTime - $creationTime
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Actual startup time: $($actualStartTime.TotalSeconds) seconds (Via analyzing Kubernetes events)"
# Remove the deployment
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Cleaning up deployment..."
kubectl delete deployment task1-nginx-deployment
