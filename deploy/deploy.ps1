# ──────────────────────────────────────────────────────────────────────
# Azure Deployment Script — Gym App
# Creates ACR, builds/pushes images, deploys via Bicep to ACI
# ──────────────────────────────────────────────────────────────────────

param(
    [string]$ResourceGroup = "gym-app-rg",
    [string]$Location = "eastus",
    [string]$AcrName = "gymappacr$(Get-Random -Minimum 1000 -Maximum 9999)",
    [string]$ContainerGroupName = "gym-app-containers",
    [string]$ImageTag = "latest"
)

$ErrorActionPreference = "Stop"

Write-Host "`n🏋️  GYM APP — AZURE DEPLOYMENT" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# ── Step 1: Login to Azure ────────────────────────────────────────────
Write-Host "📌 Step 1: Checking Azure login..." -ForegroundColor Yellow
$account = az account show 2>$null | ConvertFrom-Json
if (-not $account) {
    Write-Host "   Logging in to Azure..." 
    az login
}
Write-Host "   ✅ Logged in as: $($account.user.name)" -ForegroundColor Green

# ── Step 2: Create Resource Group ─────────────────────────────────────
Write-Host "`n📌 Step 2: Creating resource group '$ResourceGroup'..." -ForegroundColor Yellow
az group create --name $ResourceGroup --location $Location --output none
Write-Host "   ✅ Resource group ready" -ForegroundColor Green

# ── Step 3: Create Azure Container Registry ──────────────────────────
Write-Host "`n📌 Step 3: Creating container registry '$AcrName'..." -ForegroundColor Yellow
az acr create --resource-group $ResourceGroup --name $AcrName --sku Basic --admin-enabled true --output none
$acrLoginServer = az acr show --name $AcrName --query loginServer --output tsv
$acrUsername = az acr credential show --name $AcrName --query username --output tsv
$acrPassword = az acr credential show --name $AcrName --query "passwords[0].value" --output tsv
Write-Host "   ✅ ACR created: $acrLoginServer" -ForegroundColor Green

# ── Step 4: Build & Push Docker Images ────────────────────────────────
Write-Host "`n📌 Step 4: Building and pushing Docker images..." -ForegroundColor Yellow

$services = @("gym-notifier", "gym-booking", "gym-membership", "gym-frontend")
$rootDir = Split-Path -Parent $PSScriptRoot

foreach ($service in $services) {
    Write-Host "   🔨 Building $service..." -ForegroundColor White
    $imageName = "$acrLoginServer/${service}:${ImageTag}"
    docker build -t $imageName "$rootDir\$service"
    
    Write-Host "   📤 Pushing $service..." -ForegroundColor White
    docker login $acrLoginServer -u $acrUsername -p $acrPassword 2>$null
    docker push $imageName
    Write-Host "   ✅ $service pushed" -ForegroundColor Green
}

# ── Step 5: Update Nginx config for ACI ───────────────────────────────
# In ACI Container Groups, containers share localhost
Write-Host "`n📌 Step 5: Rebuilding frontend with ACI nginx config..." -ForegroundColor Yellow

$aciNginxConf = @"
server {
    listen 3000;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files `$uri `$uri/ /index.html;
    }

    location /api/classes  { proxy_pass http://localhost:4001; }
    location /api/bookings { proxy_pass http://localhost:4001; }
    location /api/plans    { proxy_pass http://localhost:4002; }
    location /api/members  { proxy_pass http://localhost:4002; }
    location /api/stats    { proxy_pass http://localhost:4002; }
    location /api/notifications { proxy_pass http://localhost:4003; }
    location /api/notify   { proxy_pass http://localhost:4003; }

    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml;
}
"@

# Temporarily swap nginx.conf for ACI build
$nginxPath = "$rootDir\gym-frontend\nginx.conf"
$originalNginx = Get-Content $nginxPath -Raw
$aciNginxConf | Set-Content $nginxPath

$imageName = "$acrLoginServer/gym-frontend:${ImageTag}"
docker build -t $imageName "$rootDir\gym-frontend"
docker push $imageName

# Restore original nginx.conf
$originalNginx | Set-Content $nginxPath
Write-Host "   ✅ Frontend rebuilt for ACI" -ForegroundColor Green

# ── Step 6: Deploy with Bicep ─────────────────────────────────────────
Write-Host "`n📌 Step 6: Deploying to Azure Container Instances..." -ForegroundColor Yellow

$deployment = az deployment group create `
    --resource-group $ResourceGroup `
    --template-file "$PSScriptRoot\main.bicep" `
    --parameters `
        containerGroupName=$ContainerGroupName `
        acrLoginServer=$acrLoginServer `
        acrUsername=$acrUsername `
        acrPassword=$acrPassword `
        imageTag=$ImageTag `
    --output json | ConvertFrom-Json

$fqdn = $deployment.properties.outputs.containerGroupFqdn.value
$ip = $deployment.properties.outputs.containerGroupIp.value

Write-Host "`n" -NoNewline
Write-Host "================================================================" -ForegroundColor Green
Write-Host "  🎉 DEPLOYMENT SUCCESSFUL!" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  🌐 URL:  http://${fqdn}:3000" -ForegroundColor Cyan
Write-Host "  📍 IP:   http://${ip}:3000" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Resource Group:  $ResourceGroup" -ForegroundColor White
Write-Host "  Container Group: $ContainerGroupName" -ForegroundColor White
Write-Host "  Registry:        $acrLoginServer" -ForegroundColor White
Write-Host ""
Write-Host "  To view logs:    az container logs -g $ResourceGroup -n $ContainerGroupName --container-name gym-frontend" -ForegroundColor DarkGray
Write-Host "  To delete:       az group delete -n $ResourceGroup --yes --no-wait" -ForegroundColor DarkGray
Write-Host "================================================================`n" -ForegroundColor Green
