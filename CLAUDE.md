# minha-maquina

> **Este ficheiro tem de ser mantido atualizado**, tal como o `README.md`, a cada alteracao ao projeto.

Automatizacao do setup de uma maquina Windows de desenvolvimento. Entregue a novos developers da equipa.

## Estrutura

- `apps-windows.json`: lista unica de pacotes winget (formato schema 2.0 do `winget import`).
- `setup.ps1`: ponto de entrada. Verifica WSL, instala/atualiza pacotes, corre os scripts de cada ferramenta.
- `start-tools.ps1`: arranque diario dos servicos (VM do Podman, SQL Server) com verificacao de que respondem. Cada servico novo entra aqui com um `[OK]`.
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
- O `setup.ps1` pergunta por cada pacote, com prefixo claro: `[NOVA INSTALACAO]` (Enter instala) ou `[ATUALIZACAO]` (Enter mantem).
- Operacoes destrutivas (remover VM, WSL, pacotes) pedem sempre confirmacao.

## Contexto da maquina

- Maquina corporativa com Zscaler (inspecao TLS): a VM do Podman precisa do certificado raiz Zscaler (`scripts/podman-certs.ps1`).
- Elevacao via Admin By Request. O `setup.ps1` so precisa de administrador para instalar o WSL.
- Podman corre sobre WSL2.
- SQL Server em contentor (`scripts/sqlserver-init.ps1`): imagem oficial MCR com a versao definida no topo do script, volume `sqlserver-data`, porta so em 127.0.0.1 (ligar sempre a `127.0.0.1,1433`, nao a `localhost`, que pode resolver para IPv6). A password do `sa` e pedida na criacao e nunca gravada no repositorio. O SSMS corre no Windows.
- `sqlserver-uninstall.ps1` pede confirmacao, exceto com `-Force` (usado pelo `uninstall.ps1`, que ja confirma).

## Como trabalhar com o utilizador

- Passos curtos e KISS. Um passo de cada vez, esperar pela indicacao antes do seguinte.
- Nao alterar ficheiros nem correr comandos sem o utilizador pedir.
- O utilizador executa os comandos git (add, commit, push).
- Nao afirmar que algo funciona sem o ter testado; dizer quando nao foi testado.
