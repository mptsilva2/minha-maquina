# minha-maquina

Setup automatico de uma maquina Windows para desenvolvimento.

> **Este ficheiro tem de ser mantido atualizado.** Qualquer alteracao a scripts, pacotes ou comportamento deve refletir-se aqui e no `CLAUDE.md`.

## O que instala

Ver [apps-windows.json](apps-windows.json): Podman, VS Code, Insomnia, Node.js LTS, Bun, Git e SSMS 22.
Instala tambem o WSL2 (necessario para o Podman), cria a VM do Podman e arranca um SQL Server em contentor (ver abaixo).

## Pre-requisitos

- Windows 10/11 com `winget` (App Installer).
- Virtualizacao ativa e permitida pela empresa.
- Consola PowerShell **como administrador** na primeira execucao (instalacao do WSL).

## Instalar

```powershell
.\setup.ps1
```

1. Se o WSL nao estiver instalado, o script instala-o e pede para **reiniciar o PC**. Depois de reiniciar, execute `.\setup.ps1` outra vez.
2. Para cada pacote pergunta o que fazer:
   - `[NOVA INSTALACAO]`: pacote que falta. Enter instala, `n` ignora.
   - `[ATUALIZACAO]`: pacote ja instalado. `s` procura nova versao, Enter mantem.
3. Cria e arranca a VM do Podman e instala o certificado Zscaler na VM (se existir na maquina).
4. Cria o contentor `sqlserver` (pede a password do `sa` na primeira vez).

Pode repetir o `setup.ps1` as vezes que precisar. No fim, abra um terminal novo para usar as ferramentas.

Se a politica de execucao bloquear scripts:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

## Logs

O `setup.ps1` e o `uninstall.ps1` gravam tudo o que aparece no ecra em `logs/` (por exemplo `logs/setup-20261027-153000.log`). Em caso de problema, envie esse ficheiro. Pode conter caminhos e o nome de utilizador, nao o partilhe publicamente. A pasta nao vai para o git.

## Testar o Podman

```powershell
podman run --rm hello-world
```

## SQL Server

Corre em contentor Podman, a partir da imagem oficial da Microsoft (`mcr.microsoft.com/mssql/server:2025-latest`, edicao Developer, apenas para desenvolvimento e testes). A versao da imagem esta no topo de `scripts/sqlserver-init.ps1`.

- Ligacao: servidor `localhost,1433`, utilizador `sa`, com a password que definiu. No SSMS marque "Trust server certificate".
- Acessivel apenas a partir da propria maquina (`127.0.0.1`).
- Os dados ficam no volume `sqlserver-data`, por isso sobrevivem a reinicios do contentor.
- A password nao e gravada em lado nenhum: guarde-a num gestor de passwords.
- O SSMS 22 instala-se no Windows (esta em `apps-windows.json`).

## Desinstalar

```powershell
.\uninstall.ps1
```

Remove o contentor e o volume do SQL Server (com as bases de dados), a VM do Podman (e os contentores e imagens), desinstala os pacotes de `apps-windows.json` e pergunta se quer remover o WSL. Pede confirmacao antes de apagar.

## Problemas conhecidos

- **`x509: certificate signed by unknown authority` no Podman:** o Zscaler re-assina o trafego HTTPS. O `scripts/podman-certs.ps1` instala o certificado na VM.
- **`git` nao reconhecido apos o setup:** abra um terminal novo.

## Adicionar uma ferramenta

1. Acrescentar o `PackageIdentifier` a `apps-windows.json` (`winget search <nome>` para o descobrir).
2. Se precisar de configuracao, criar `scripts/<nome>-init.ps1` e `scripts/<nome>-uninstall.ps1` e chama-los em `setup.ps1` e `uninstall.ps1`.
