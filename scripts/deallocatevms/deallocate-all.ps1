. "$PSScriptRoot\..\..\variables.ps1"

$vmNames = @(
    "pbx-01",
    "sbc-01",
    "splunk-01",
    "k3s-01",
    "idsips-01"
)

foreach ($vm in $vmNames) {
    az vm deallocate --resource-group $resourceGroup --name $vm
}