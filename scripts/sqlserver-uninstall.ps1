param([switch]$Force)

$ErrorActionPreference = "Stop"

$name = "sqlserver"
$volume = "sqlserver-data"

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    Write-Host "Podman nao encontrado, nada a remover."
    return
}

if (-not $Force) {
    Write-Warning "Isto remove o contentor $name e o volume $volume, com todas as bases de dados."
    if ((Read-Host "Continuar? (s/N)") -ne "s") {
        Write-Host "Cancelado."
        return
    }
}

podman container exists $name
if ($LASTEXITCODE -eq 0) {
    Write-Host "A remover o contentor $name..."
    podman rm --force $name
    if ($LASTEXITCODE -ne 0) { throw "podman rm falhou." }
}

podman volume exists $volume
if ($LASTEXITCODE -eq 0) {
    Write-Host "A remover o volume $volume..."
    podman volume rm --force $volume
    if ($LASTEXITCODE -ne 0) { throw "podman volume rm falhou." }
}
