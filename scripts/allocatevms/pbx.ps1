$ErrorActionPreference = "Stop"
. "$PSScriptRoot\..\..\variables.ps1"
. "$PSScriptRoot\..\helpers.ps1"

$vmName = "pbx-01"

if (Test-VmExists -ResourceGroup $resourceGroup -VmName $vmName) {
    Write-Host "$vmName already exists, skipping..."
    exit 0
}

$pubKey = Join-Path $keyBase "pbx\pbx-key.pub"

Write-Host "Creating $vmName..."
az vm create `
  --resource-group $resourceGroup `
  --name $vmName `
  --location $location `
  --image $ubuntuImage `
  --size $vmMap[$vmName].size `
  --vnet-name $vnetName `
  --subnet $vmMap[$vmName].subnet `
  --private-ip-address $vmMap[$vmName].ip `
  --admin-username $adminUser `
  --ssh-key-values $pubKey `
  --custom-data "$PSScriptRoot\..\..\cloud-init\pbx.yml" `
  --public-ip-address '""' | Out-Null