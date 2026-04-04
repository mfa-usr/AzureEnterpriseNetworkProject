$ErrorActionPreference = "Stop"
. "$PSScriptRoot\..\..\variables.ps1"
. "$PSScriptRoot\..\helpers.ps1"

if (-not (Test-ResourceGroupExists -Name $resourceGroup)) {
    Write-Host "Creating resource group $resourceGroup..."
    az group create --name $resourceGroup --location $location | Out-Null
}
else {
    Write-Host "Resource group $resourceGroup already exists, skipping..."
}

if (-not (Test-VnetExists -ResourceGroup $resourceGroup -VnetName $vnetName)) {
    Write-Host "Creating VNet $vnetName..."
    az network vnet create `
      --resource-group $resourceGroup `
      --name $vnetName `
      --location $location `
      --address-prefixes $vnetPrefix | Out-Null
}
else {
    Write-Host "VNet $vnetName already exists, skipping..."
}

if (-not (Test-SubnetExists -ResourceGroup $resourceGroup -VnetName $vnetName -SubnetName $subnetEdge)) {
    Write-Host "Creating subnet $subnetEdge..."
    az network vnet subnet create `
      --resource-group $resourceGroup `
      --vnet-name $vnetName `
      --name $subnetEdge `
      --address-prefixes $subnetEdgePrefix | Out-Null
}
else {
    Write-Host "Subnet $subnetEdge already exists, skipping..."
}

if (-not (Test-SubnetExists -ResourceGroup $resourceGroup -VnetName $vnetName -SubnetName $subnetVoice)) {
    Write-Host "Creating subnet $subnetVoice..."
    az network vnet subnet create `
      --resource-group $resourceGroup `
      --vnet-name $vnetName `
      --name $subnetVoice `
      --address-prefixes $subnetVoicePrefix | Out-Null
}
else {
    Write-Host "Subnet $subnetVoice already exists, skipping..."
}

if (-not (Test-SubnetExists -ResourceGroup $resourceGroup -VnetName $vnetName -SubnetName $subnetCore)) {
    Write-Host "Creating subnet $subnetCore..."
    az network vnet subnet create `
      --resource-group $resourceGroup `
      --vnet-name $vnetName `
      --name $subnetCore `
      --address-prefixes $subnetCorePrefix | Out-Null
}
else {
    Write-Host "Subnet $subnetCore already exists, skipping..."
}

if (-not (Test-SubnetExists -ResourceGroup $resourceGroup -VnetName $vnetName -SubnetName $subnetApp)) {
    Write-Host "Creating subnet $subnetApp..."
    az network vnet subnet create `
      --resource-group $resourceGroup `
      --vnet-name $vnetName `
      --name $subnetApp `
      --address-prefixes $subnetAppPrefix | Out-Null
}
else {
    Write-Host "Subnet $subnetApp already exists, skipping..."
}