$ErrorActionPreference = "Stop"

# Imagem oficial da Microsoft (MCR). Para mudar de versao, alterar apenas esta linha.
$image = "mcr.microsoft.com/mssql/server:2025-latest"
$name = "sqlserver"
$volume = "sqlserver-data"

podman container exists $name
if ($LASTEXITCODE -eq 0) {
    $running = podman inspect --format "{{.State.Running}}" $name
    if ($running -eq "true") {
        Write-Host "O contentor $name ja esta a correr."
    } else {
        Write-Host "A iniciar o contentor $name..."
        podman start $name
        if ($LASTEXITCODE -ne 0) { throw "podman start falhou." }
    }
    return
}

Write-Host "A criar o contentor $name ($image)."
Write-Host "Ao continuar aceita a licenca do SQL Server (edicao Developer, apenas para desenvolvimento e testes)."
Write-Host "A password do sa tem de ter 8+ caracteres com maiusculas, minusculas, numeros e simbolos. Guarde-a (nao fica gravada)."
$secure = Read-Host "Password do sa" -AsSecureString
$password = [System.Net.NetworkCredential]::new("", $secure).Password

podman run -d --name $name `
    -e ACCEPT_EULA=Y `
    -e MSSQL_PID=Developer `
    -e "MSSQL_SA_PASSWORD=$password" `
    -p 127.0.0.1:1433:1433 `
    -v "${volume}:/var/opt/mssql" `
    $image
if ($LASTEXITCODE -ne 0) { throw "podman run falhou." }

Write-Host "SQL Server a arrancar. Ligue-se a 127.0.0.1,1433 com o utilizador sa."
Write-Host "Se o contentor parar logo, veja: podman logs $name (normalmente a password nao cumpre os requisitos)."
