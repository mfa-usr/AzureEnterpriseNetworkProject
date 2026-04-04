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

# ------------------------------------------------------------------
# EDIT THIS SECTION
# Add the SSH source IPs / CIDRs you want to allow.
# Priority must be unique per NSG. Lower number = evaluated first.
# ------------------------------------------------------------------
$AllowedSshRules = @(
    # @{
    #    Name     = "allow-ssh-home"
    #    Source   = "0.0.0.0/32"
    #    Priority = 1001
    # }
    # @{
    #     Name     = "allow-ssh-vpn"
    #     Source   = "0.0.0.0/24"
    #     Priority = 1002
    # }
)

# Optional: remove these extra SSH rule names too if they exist
$RulesToRemove = @(
    "default-allow-ssh"
)

if (-not (Test-ResourceGroupExists -Name $resourceGroup)) {
    Write-Host "Resource group $resourceGroup does not exist."
    exit 0
}

foreach ($vmName in $vmMap.Keys) {
    if (-not (Test-VmExists -ResourceGroup $resourceGroup -VmName $vmName)) {
        Write-Host "$vmName does not exist, skipping..."
        continue
    }

    Write-Host "`nProcessing VM: $vmName"

    $nicId = az vm show `
        --resource-group $resourceGroup `
        --name $vmName `
        --query "networkProfile.networkInterfaces[0].id" `
        -o tsv

    if ([string]::IsNullOrWhiteSpace($nicId)) {
        Write-Host "No NIC found for $vmName, skipping..."
        continue
    }

    $nicName = ($nicId -split "/")[-1]

    $nsgId = az network nic show `
        --resource-group $resourceGroup `
        --name $nicName `
        --query "networkSecurityGroup.id" `
        -o tsv

    if ([string]::IsNullOrWhiteSpace($nsgId)) {
        Write-Host "No NSG attached to NIC $nicName for $vmName, skipping..."
        continue
    }

    $nsgName = ($nsgId -split "/")[-1]

    Write-Host "NIC: $nicName"
    Write-Host "NSG: $nsgName"

    foreach ($ruleName in $RulesToRemove) {
        $existingRule = az network nsg rule list `
            --resource-group $resourceGroup `
            --nsg-name $nsgName `
            --query "[?name=='$ruleName'].name" `
            -o tsv 2>$null

        if (-not [string]::IsNullOrWhiteSpace($existingRule)) {
            Write-Host "Removing NSG rule $ruleName from $nsgName..."
            az network nsg rule delete `
              --resource-group $resourceGroup `
              --nsg-name $nsgName `
              --name $ruleName `
              --only-show-errors | Out-Null
        }
        else {
            Write-Host "Rule $ruleName not present on $nsgName, skipping..."
        }
    }

    foreach ($rule in $AllowedSshRules) {
        $ruleName = $rule.Name
        $source   = $rule.Source
        $priority = $rule.Priority

        $existingRule = az network nsg rule list `
            --resource-group $resourceGroup `
            --nsg-name $nsgName `
            --query "[?name=='$ruleName'].name" `
            -o tsv 2>$null

        if (-not [string]::IsNullOrWhiteSpace($existingRule)) {
            Write-Host "Rule $ruleName already exists on $nsgName, skipping..."
            continue
        }

        Write-Host "Creating SSH allow rule $ruleName on $nsgName for source $source..."
        az network nsg rule create `
          --resource-group $resourceGroup `
          --nsg-name $nsgName `
          --name $ruleName `
          --priority $priority `
          --direction Inbound `
          --access Allow `
          --protocol Tcp `
          --source-address-prefixes $source `
          --source-port-ranges "*" `
          --destination-address-prefixes "*" `
          --destination-port-ranges 22 `
          --only-show-errors | Out-Null
    }
}

Write-Host "`nSSH NSG hardening complete."