$ErrorActionPreference = "Stop"
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

. "$scriptRoot\scripts\helpers.ps1"

Invoke-Step "Generating keys..." { & "$scriptRoot\scripts\allocatevms\keys.ps1" }
Invoke-Step "Creating network..." { & "$scriptRoot\scripts\allocatevms\network.ps1" }
Invoke-Step "Creating PBX..." { & "$scriptRoot\scripts\allocatevms\pbx.ps1" }
Invoke-Step "Creating LibreSBC..." { & "$scriptRoot\scripts\allocatevms\sbc.ps1" }
Invoke-Step "Creating Splunk..." { & "$scriptRoot\scripts\allocatevms\splunk.ps1" }
Invoke-Step "Creating k3s..." { & "$scriptRoot\scripts\allocatevms\k3s.ps1" }
Invoke-Step "Creating IDS/IPS..." { & "$scriptRoot\scripts\allocatevms\idsips.ps1" }
Invoke-Step "Applying SSH NSG rules..." { & "$scriptRoot\scripts\allocatevms\nsg.ps1" }

Write-Host "`nAll steps completed."