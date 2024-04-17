# This script will create a pod in Kubernetes and measure the time it takes to start up

# Pre-pull the image to avoid network latency
Write-Output "Pre-pulling the image..."
kubectl run nginx-kube --image=nginx --restart=Never
kubectl delete pod nginx-kube

# Measure the time it takes to start up the pod
Write-Output ""
Write-Output "Measuring the time it takes to start up the pod..."
$start = Get-Date
kubectl run nginx-kube --image=nginx
kubectl wait --for=condition=ready pod -l run=nginx-kube
$end = Get-Date
$elapsedTime = $end - $start
Write-Output "Kubernetes startup time: $($elapsedTime.TotalSeconds) seconds (Via bash script)"

# Get the actual start time
$kubeResult = kubectl get pod nginx-kube -o json | ConvertFrom-Json
$creationTime = Get-Date -Date $kubeResult.metadata.creationTimestamp
$containerRunningTime = Get-Date -Date $kubeResult.status.containerStatuses[0].state.running.startedAt
$actualStartTime = $containerRunningTime - $creationTime
Write-Output "Actual startup time: $($actualStartTime.TotalSeconds) seconds (Via analyzing Kubernetes events)"

# Kill the pod after the test is done
Write-Output ""
Write-Output "Cleaning up..."
kubectl delete pod nginx-kube