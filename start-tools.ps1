$ErrorActionPreference = "Stop"

function Wait-Port($address, $port, $seconds) {
    $limit = (Get-Date).AddSeconds($seconds)
    while ((Get-Date) -lt $limit) {
        $client = [System.Net.Sockets.TcpClient]::new()
        try {
            $client.Connect($address, $port)
            return $true
        } catch {
            Start-Sleep -Seconds 2
        } finally {
            $client.Dispose()
        }
    }
    return $false
}

# 1. VM do Podman
$machine = podman machine list --format json | ConvertFrom-Json | Select-Object -First 1
if (-not $machine) { throw "Nao existe VM do Podman. Execute primeiro o setup.ps1." }

if (-not $machine.Running) {
    Write-Host "A iniciar a VM do Podman..."
    podman machine start
    if ($LASTEXITCODE -ne 0) { throw "podman machine start falhou." }
}
Write-Host "[OK] VM do Podman a correr."

# 2. SQL Server
podman container exists sqlserver
if ($LASTEXITCODE -ne 0) { throw "Contentor sqlserver nao existe. Execute primeiro o setup.ps1." }

if ((podman inspect --format "{{.State.Running}}" sqlserver) -ne "true") {
    Write-Host "A iniciar o contentor sqlserver..."
    podman start sqlserver
    if ($LASTEXITCODE -ne 0) { throw "podman start sqlserver falhou." }
}

if (Wait-Port "127.0.0.1" 1433 60) {
    Write-Host "[OK] SQL Server a responder em 127.0.0.1,1433."
} else {
    Write-Warning "SQL Server nao respondeu em 60 segundos. Veja: podman logs sqlserver"
    exit 1
}
