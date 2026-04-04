$ErrorActionPreference = "Stop"
. "$PSScriptRoot\..\..\variables.ps1"

function Test-ResourceGroupExists {
    param([string]$Name)
    $exists = az group exists --name $Name 2>$null
    return ($exists -eq "true")
}

function Test-VmExists {
    param(
        [string]$ResourceGroup,
        [string]$VmName
    )

    $result = az vm list `
        --resource-group $ResourceGroup `
        --query "[?name=='$VmName'].name" `
        -o tsv 2>$null

    return -not [string]::IsNullOrWhiteSpace($result)
}

Write-Host "Starting lab teardown for resource group: $resourceGroup"

if (-not (Test-ResourceGroupExists -Name $resourceGroup)) {
    Write-Host "Resource group $resourceGroup does not exist. Nothing to delete."
    exit 0
}

Write-Host "`nResources currently in ${resourceGroup}:"
az resource list --resource-group $resourceGroup -o table

Write-Host "`nChecking for VMs to deallocate..."
foreach ($vmName in $vmMap.Keys) {
    if (Test-VmExists -ResourceGroup $resourceGroup -VmName $vmName) {
        Write-Host "Deallocating $vmName..."
        az vm deallocate `
          --resource-group $resourceGroup `
          --name $vmName `
          --no-wait `
          --only-show-errors | Out-Null
    }
    else {
        Write-Host "$vmName does not exist, skipping deallocate."
    }
}

Write-Host "`nWaiting briefly for deallocation requests to register..."
Start-Sleep -Seconds 15

Write-Host "`nChecking for VMs to delete..."
foreach ($vmName in $vmMap.Keys) {
    if (Test-VmExists -ResourceGroup $resourceGroup -VmName $vmName) {
        Write-Host "Deleting VM $vmName..."
        az vm delete `
          --resource-group $resourceGroup `
          --name $vmName `
          --yes `
          --force-deletion yes `
          --only-show-errors | Out-Null
    }
    else {
        Write-Host "$vmName does not exist, skipping VM delete."
    }
}

Write-Host "`nDeleting entire resource group $resourceGroup..."
az group delete `
  --name $resourceGroup `
  --yes `
  --no-wait

Write-Host "`nTeardown submitted."
Write-Host "Local keys under $keyBase are not touched."