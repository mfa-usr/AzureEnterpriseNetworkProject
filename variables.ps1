$resourceGroup = "rg-homelab"
$location = "westus2"
$zone = "2"

$vnetName = "vnet-homelab"
$vnetPrefix = "10.0.0.0/16"

$subnetEdge = "subnet-edge"
$subnetEdgePrefix = "10.0.0.0/24"

$subnetVoice = "subnet-voice"
$subnetVoicePrefix = "10.0.1.0/24"

$subnetCore = "subnet-core"
$subnetCorePrefix = "10.0.2.0/24"

$subnetApp = "subnet-app"
$subnetAppPrefix = "10.0.3.0/24"

$adminUser = "azureuser"
$keyBase = "$env:USERPROFILE\OneDrive\AzureEnterpriseNetworkProject\keys"

$ubuntuImage = "Ubuntu2204"

# VM names / IPs
$vmMap = @{
    "sbc-01"      = @{ subnet = $subnetVoice; ip = "10.0.1.10"; size = "Standard_B2ats_v2"; keyRole = "sbc" }
    "pbx-01"      = @{ subnet = $subnetVoice; ip = "10.0.1.20"; size = "Standard_B2ats_v2"; keyRole = "pbx" }
    "vyos-01"     = @{ subnet = $subnetCore;  ip = "10.0.2.10"; size = "Standard_B2ats_v2"; keyRole = "vyos" }
    "splunk-01"   = @{ subnet = $subnetApp;   ip = "10.0.3.10"; size = "Standard_B2ats_v2"; keyRole = "splunk" }
    "k3s-01"      = @{ subnet = $subnetApp;   ip = "10.0.3.20"; size = "Standard_B2ats_v2"; keyRole = "k3s" }
    "idsips-01"   = @{ subnet = $subnetEdge;  ip = "10.0.0.20"; size = "Standard_B2ats_v2"; keyRole = "idsips" }
}