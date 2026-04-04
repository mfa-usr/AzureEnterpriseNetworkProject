$ErrorActionPreference = "Stop"
. "$PSScriptRoot\..\..\variables.ps1"

$roles = @("pbx","sbc","vyos","splunk","k3s","idsips","firewall")

foreach ($role in $roles) {
    $path = Join-Path $keyBase $role
    New-Item -ItemType Directory -Force -Path $path | Out-Null

    $privateKey = Join-Path $path "$role-key"
    $publicKey  = "$privateKey.pub"

    if ((Test-Path $privateKey) -and (Test-Path $publicKey)) {
        Write-Host "Key already exists for $role, skipping..."
        continue
    }

    if (Test-Path $privateKey) {
        Remove-Item $privateKey -Force
    }

    if (Test-Path $publicKey) {
        Remove-Item $publicKey -Force
    }

    Write-Host "Generating key for $role..."

    $argString = "-t rsa -b 4096 -f `"$privateKey`" -N `"`""

    $proc = Start-Process `
        -FilePath "ssh-keygen" `
        -ArgumentList $argString `
        -NoNewWindow `
        -Wait `
        -PassThru

    if ($proc.ExitCode -ne 0) {
        throw "ssh-keygen failed for $role with exit code $($proc.ExitCode)"
    }

    if (-not ((Test-Path $privateKey) -and (Test-Path $publicKey))) {
        throw "ssh-keygen reported success for $role but key files were not created"
    }
}