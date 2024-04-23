Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Cleaning up deployment..."
kubectl delete deployment task1-nginx-deployment

Write-Output ""
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Creating the 1 pod..."
kubectl apply -f task1-1.yaml
kubectl wait --for=condition=available deployment/task1-nginx-deployment --timeout=60s

Write-Output ""
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Sleep for 1 minute..."
Start-Sleep -Seconds 60
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Checking the resource usage of the 1 pod..."
kubectl top pods --all-namespaces
kubectl top nodes

Write-Output ""
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Scaling the deployment to 5 replicas..."
kubectl apply -f task1-5.yaml
kubectl wait --for=condition=available deployment/task1-nginx-deployment --timeout=60s

Write-Output ""
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Sleep for 1 minute..."
Start-Sleep -Seconds 60

Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Checking the resource usage of the 5 pods..."
kubectl top pods --all-namespaces
kubectl top nodes

Write-Output ""
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Scaling the deployment to 10 replicas..."
kubectl apply -f task1-10.yaml
kubectl wait --for=condition=available deployment/task1-nginx-deployment --timeout=60s

Write-Output ""
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Sleep for 1 minute..."
Start-Sleep -Seconds 60
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Checking the resource usage of the 10 pod..."
kubectl top pods --all-namespaces
kubectl top nodes

Write-Output ""
Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Cleaning up deployment..."
kubectl delete deployment task1-nginx-deployment