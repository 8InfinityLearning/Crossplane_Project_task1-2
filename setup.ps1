Write-Host " Applying Custom Resource Definition..." -ForegroundColor Yellow
kubectl apply -f xrd.yaml --server-side

Write-Host " Applying Composition Engine Blueprint..." -ForegroundColor Yellow
kubectl apply -f composition.yaml

Write-Host " Deploying Claim/Instance Request..." -ForegroundColor Yellow
kubectl apply -f claim.yaml

Write-Host " Deployment initiated! Use 'kubectl get storagebuckets' to check status." -ForegroundColor Green