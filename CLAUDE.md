# minha-maquina

Automatizacao do setup de uma maquina Windows de desenvolvimento. Entregue a novos developers da equipa.

## Estrutura

- `apps-windows.json`: lista unica de pacotes winget (formato schema 2.0 do `winget import`).
- `setup.ps1`: ponto de entrada. Verifica WSL, instala/atualiza pacotes, corre os scripts de cada ferramenta.
- `uninstall.ps1`: caminho inverso, com confirmacoes.
- `scripts/<ferramenta>-init.ps1` e `scripts/<ferramenta>-uninstall.ps1`: configuracao e remocao de cada ferramenta.

## Convencoes

- Idioma: portugues (sem acentos nos scripts) nas mensagens e documentacao.
- Scripts idempotentes: repetir a execucao nao duplica nem estraga nada.
- Verificar `$LASTEXITCODE` apos comandos nativos (`podman`, `winget`, `wsl`). O `$ErrorActionPreference = "Stop"` nao os apanha.
- Todo o pacote novo entra em `apps-windows.json`; o uninstall percorre esse ficheiro.
- Ferramenta com configuracao propria: criar `-init.ps1` e `-uninstall.ps1` e chama-los em `setup.ps1` e `uninstall.ps1`.
- Manter `README.md` e este `CLAUDE.md` sempre atualizados: qualquer alteracao a scripts, pacotes ou comportamento inclui a atualizacao dos ficheiros MD.
- `setup.ps1` e `uninstall.ps1` gravam logs em `logs/` (Start-Transcript); a pasta esta no `.gitignore`.
- Operacoes destrutivas (remover VM, WSL, pacotes) pedem sempre confirmacao.

## Contexto da maquina

- Maquina corporativa com Zscaler (inspecao TLS): a VM do Podman precisa do certificado raiz Zscaler (`scripts/podman-certs.ps1`).
- Elevacao via Admin By Request. O `setup.ps1` so precisa de administrador para instalar o WSL.
- Podman corre sobre WSL2.

## Como trabalhar com o utilizador

- Passos curtos e KISS. Um passo de cada vez, esperar pela indicacao antes do seguinte.
- Nao alterar ficheiros nem correr comandos sem o utilizador pedir.
- O utilizador executa os comandos git (add, commit, push).
- Nao afirmar que algo funciona sem o ter testado; dizer quando nao foi testado.
