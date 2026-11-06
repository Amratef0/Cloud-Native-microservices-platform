param(
    [Parameter(Mandatory=$true, HelpMessage="Enter your Docker Hub username")]
    [string]$DockerUser,
    
    [string]$Tag = "latest"
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Building & Pushing Microservices to Docker Hub" -ForegroundColor Cyan
Write-Host "  Target User: $DockerUser | Tag: $Tag" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Login to Docker Hub
Write-Host "`n--> Checking Docker login..." -ForegroundColor Yellow
docker login

$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Write-Host "Project root: $ProjectRoot"

# Define the 6 services to build
$services = @(
    @{ Name = "rowad-auth-user-service"; Path = "backend/auth-user-service" },
    @{ Name = "rowad-product-search-service"; Path = "backend/product-search-service" },
    @{ Name = "rowad-payment-service"; Path = "backend/payment-service" },
    @{ Name = "rowad-cart-service"; Path = "backend/cart-service" },
    @{ Name = "rowad-order-service"; Path = "backend/order-service" },
    @{ Name = "rowad-frontend"; Path = "frontend" }
)

foreach ($svc in $services) {
    $fullImage = "${DockerUser}/$($svc.Name):${Tag}"
    $contextPath = Join-Path $ProjectRoot $svc.Path
    
    Write-Host "`n----------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "--> Building: $fullImage" -ForegroundColor Green
    Write-Host "    Context:  $contextPath" -ForegroundColor Gray
    Write-Host "----------------------------------------------------------" -ForegroundColor Cyan
    
    docker build -t $fullImage $contextPath
    
    Write-Host "--> Pushing: $fullImage to Docker Hub..." -ForegroundColor Yellow
    docker push $fullImage
}

# 2. Update Kubernetes manifests to use the new Docker Hub username
Write-Host "`n--> Updating Kubernetes manifests with new username: $DockerUser..." -ForegroundColor Yellow

$k8sDir = Join-Path $ProjectRoot "k8s"
$k8sFiles = Get-ChildItem -Path $k8sDir -Filter "*.yaml"

foreach ($file in $k8sFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    if ($content -match "judyassem0/") {
        $updated = $content -replace "judyassem0/", "${DockerUser}/"
        Set-Content -Path $file.FullName -Value $updated -NoNewline
        Write-Host "    Updated image references in $($file.Name)" -ForegroundColor Green
    }
}

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "  SUCCESS! All 6 images built, pushed, and manifests updated!" -ForegroundColor Green
Write-Host "  Now you can deploy by running:" -ForegroundColor Cyan
Write-Host "    kubectl apply -k k8s/" -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Green
