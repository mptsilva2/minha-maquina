$ErrorActionPreference = "Stop"

$anchor = "/etc/pki/ca-trust/source/anchors/zscaler-root.crt"

$cert = Get-ChildItem Cert:\LocalMachine\Root |
    Where-Object { $_.Subject -match "Zscaler Root CA" } |
    Select-Object -First 1

if (-not $cert) {
    Write-Host "Certificado Zscaler nao encontrado, nada a instalar na VM."
    return
}

podman machine ssh "test -f $anchor"
if ($LASTEXITCODE -eq 0) {
    Write-Host "Certificado Zscaler ja esta instalado na VM."
    return
}

Write-Host "A instalar o certificado Zscaler na VM do Podman..."
$pem = "-----BEGIN CERTIFICATE-----`n" +
       [Convert]::ToBase64String($cert.RawData, 'InsertLineBreaks') +
       "`n-----END CERTIFICATE-----"

$pem | podman machine ssh "sudo tee $anchor > /dev/null"
if ($LASTEXITCODE -ne 0) { throw "Falha ao copiar o certificado para a VM." }

podman machine ssh "sudo update-ca-trust"
if ($LASTEXITCODE -ne 0) { throw "update-ca-trust falhou." }

podman machine stop
podman machine start
if ($LASTEXITCODE -ne 0) { throw "podman machine start falhou." }
