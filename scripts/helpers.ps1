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

function Test-VnetExists {
    param(
        [string]$ResourceGroup,
        [string]$VnetName
    )

    $result = az network vnet list `
        --resource-group $ResourceGroup `
        --query "[?name=='$VnetName'].name" `
        -o tsv 2>$null

    return -not [string]::IsNullOrWhiteSpace($result)
}

function Test-SubnetExists {
    param(
        [string]$ResourceGroup,
        [string]$VnetName,
        [string]$SubnetName
    )

    $result = az network vnet subnet list `
        --resource-group $ResourceGroup `
        --vnet-name $VnetName `
        --query "[?name=='$SubnetName'].name" `
        -o tsv 2>$null

    return -not [string]::IsNullOrWhiteSpace($result)
}

function Invoke-Step {
    param(
        [string]$Message,
        [scriptblock]$Action
    )

    Write-Host $Message
    & $Action
    if (-not $?) {
        throw "$Message failed"
    }
}