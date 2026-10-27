$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

# 1. Pre-requisitos
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget nao encontrado. Instale o 'App Installer' da Microsoft Store."
}

wsl --status *> $null
if ($LASTEXITCODE -ne 0) {
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
Write-Host "A instalar aplicacoes..."
winget import --import-file "$root\apps-windows.json" --accept-package-agreements --accept-source-agreements

# 3. Configuracao de cada ferramenta
& "$root\scripts\podman-init.ps1"

Write-Host "Setup concluido."
