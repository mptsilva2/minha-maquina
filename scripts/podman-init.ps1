$ErrorActionPreference = "Stop"

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    # Recarrega o PATH, porque o winget acabou de instalar o podman nesta sessao
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [Environment]::GetEnvironmentVariable("Path", "User")
}

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    throw "Podman nao encontrado. Abra um terminal novo e volte a executar o setup."
}

$machines = podman machine list --format json | ConvertFrom-Json

if (-not $machines) {
    Write-Host "A criar a VM do Podman..."
    podman machine init
    if ($LASTEXITCODE -ne 0) { throw "podman machine init falhou." }
    $machines = podman machine list --format json | ConvertFrom-Json
}

$machine = $machines | Select-Object -First 1

if (-not $machine) {
    throw "Nao existe nenhuma VM do Podman."
}

if ($machine.Running) {
    Write-Host "A VM do Podman ja esta a correr."
} else {
    Write-Host "A iniciar a VM do Podman..."
    podman machine start
    if ($LASTEXITCODE -ne 0) { throw "podman machine start falhou." }
}

podman --version
