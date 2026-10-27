$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

New-Item -ItemType Directory -Path "$root\logs" -Force | Out-Null
Start-Transcript -Path "$root\logs\setup-$(Get-Date -Format 'yyyyMMdd-HHmmss').log" | Out-Null

# 1. Pre-requisitos
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget nao encontrado. Instale o 'App Installer' da Microsoft Store."
}

$ErrorActionPreference = "Continue"
wsl --status *> $null
$wslInstalled = ($LASTEXITCODE -eq 0)
$ErrorActionPreference = "Stop"
if (-not $wslInstalled) {
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        throw "WSL nao esta instalado. Execute este script numa consola PowerShell como administrador."
    }
    Write-Host "A instalar o WSL..."
    wsl --install --no-distribution
    Write-Warning "WSL instalado. Reinicie o PC e volte a executar este script."
    exit 0
}

# 2. Aplicacoes
$apps = Get-Content "$root\apps-windows.json" -Raw | ConvertFrom-Json
foreach ($source in $apps.Sources) {
    foreach ($package in $source.Packages) {
        $id = $package.PackageIdentifier

        winget list --id $id --exact --accept-source-agreements *> $null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "A instalar $id..."
            winget install --id $id --exact --accept-package-agreements --accept-source-agreements
            if ($LASTEXITCODE -ne 0) { throw "Falha ao instalar $id." }
        } elseif ((Read-Host "$id ja esta instalado. Procurar e instalar nova versao, se existir? (s/N)") -eq "s") {
            Write-Host "A procurar nova versao de $id..."
            winget upgrade --id $id --exact --accept-package-agreements --accept-source-agreements
        } else {
            Write-Host "$id mantido."
        }
    }
}

# 3. Configuracao de cada ferramenta
& "$root\scripts\podman-init.ps1"
& "$root\scripts\podman-certs.ps1"

Write-Host "Setup concluido."
Stop-Transcript | Out-Null
