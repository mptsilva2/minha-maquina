$ErrorActionPreference = "Stop"

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    Write-Host "Podman nao encontrado, nada a remover."
    return
}

$machines = podman machine list --format json | ConvertFrom-Json

foreach ($machine in $machines) {
    Write-Host "A remover a VM '$($machine.Name)'..."
    podman machine stop $machine.Name
    podman machine rm --force $machine.Name
}
