$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

Write-Warning "Isto remove a VM do Podman (com todos os contentores e imagens) e desinstala as aplicacoes de apps-windows.json."
if ((Read-Host "Continuar? (s/N)") -ne "s") {
    Write-Host "Cancelado."
    exit 0
}

# 1. Configuracao de cada ferramenta (ordem inversa do setup)
& "$root\scripts\podman-uninstall.ps1"

# 2. Aplicacoes
$apps = Get-Content "$root\apps-windows.json" -Raw | ConvertFrom-Json
foreach ($source in $apps.Sources) {
    foreach ($package in $source.Packages) {
        Write-Host "A desinstalar $($package.PackageIdentifier)..."
        winget uninstall --id $package.PackageIdentifier --exact --silent
    }
}

# 3. WSL (opcional)
Write-Warning "ATENCAO: o WSL pode ser usado por outras ferramentas (Docker Desktop, distros Linux). Ao remove-lo, todas as distros e dados WSL sao apagados."
if ((Read-Host "Desinstalar o WSL? (s/N)") -eq "s") {
    wsl --uninstall
    if ($LASTEXITCODE -ne 0) { throw "wsl --uninstall falhou." }
    Write-Host "WSL desinstalado."
} else {
    Write-Host "WSL mantido."
}

Write-Host "Uninstall concluido."
