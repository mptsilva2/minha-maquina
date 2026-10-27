# minha-maquina

Setup automatico de uma maquina Windows para desenvolvimento.

## O que instala

Ver [apps-windows.json](apps-windows.json): Podman, VS Code, Insomnia, Node.js LTS, Bun e Git.
Instala tambem o WSL2 (necessario para o Podman) e cria a VM do Podman.

## Pre-requisitos

- Windows 10/11 com `winget` (App Installer).
- Virtualizacao ativa e permitida pela empresa.
- Consola PowerShell **como administrador** na primeira execucao (instalacao do WSL).

## Instalar

```powershell
.\setup.ps1
```

1. Se o WSL nao estiver instalado, o script instala-o e pede para **reiniciar o PC**. Depois de reiniciar, execute `.\setup.ps1` outra vez.
2. Para cada pacote ja instalado, pergunta se quer procurar nova versao.
3. Cria e arranca a VM do Podman e instala o certificado Zscaler na VM (se existir na maquina).

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

## Desinstalar

```powershell
.\uninstall.ps1
```

Remove a VM do Podman (e os contentores e imagens), desinstala os pacotes de `apps-windows.json` e pergunta se quer remover o WSL. Pede confirmacao antes de apagar.

## Problemas conhecidos

- **`x509: certificate signed by unknown authority` no Podman:** o Zscaler re-assina o trafego HTTPS. O `scripts/podman-certs.ps1` instala o certificado na VM.
- **`git` nao reconhecido apos o setup:** abra um terminal novo.

## Adicionar uma ferramenta

1. Acrescentar o `PackageIdentifier` a `apps-windows.json` (`winget search <nome>` para o descobrir).
2. Se precisar de configuracao, criar `scripts/<nome>-init.ps1` e `scripts/<nome>-uninstall.ps1` e chama-los em `setup.ps1` e `uninstall.ps1`.
