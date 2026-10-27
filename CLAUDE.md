# CLAUDE.md — Jogo Roblox (Luau + Rojo)

## Visão geral
Jogo Roblox escrito em **Luau**, sincronizado com o Studio via **Rojo**.
O disco é a fonte da verdade; o Studio serve apenas para testar.

## Estrutura
```
default.project.json   # mapeamento Rojo
selene.toml            # linter
stylua.toml            # formatador
src/
  server/              # -> ServerScriptService.Server
    Lib/               # libs de terceiros (ProfileStore)
    Services/          # PlayerData, Purchases, ...
    Util/              # RemoteGuard, ...
  client/              # -> StarterPlayer.StarterPlayerScripts.Client
  shared/              # -> ReplicatedStorage.Shared
    Config.luau        # ÚNICO sítio para preços, raridades e economia
```

## Regras (obrigatórias)

### 1. Código só no disco
- Todo o código vive em `src/server`, `src/client` e `src/shared`.
- **Nunca** criar nem editar Scripts/ModuleScripts diretamente no Studio. Alterações feitas no Studio perdem-se na próxima sincronização.

### 2. O servidor é a autoridade
- O cliente **nunca** decide moedas, itens, roubos ou compras.
- O cliente só envia *intenções* ("quero comprar X"); o servidor decide, valida e aplica.
- Nunca confiar em valores enviados pelo cliente (quantidades, preços, IDs de dono, posições).

### 3. RemoteEvents / RemoteFunctions
Todo o handler no servidor tem de validar, **antes de qualquer lógica**:
- **Tipos** (`typeof`, `type`) de todos os argumentos e número de argumentos;
- **Limites** (números finitos, intervalos, comprimento de strings, ids existentes na Config);
- **Distância** entre o jogador e o alvo/objeto, quando aplicável;
- **Frequência** (rate limit por jogador).
Usar sempre `src/server/Util/RemoteGuard`. Em caso de falha: ignorar silenciosamente (e registar), nunca confiar.

### 4. Compras
- Só via `MarketplaceService.ProcessReceipt`, em `src/server/Services/Purchases`.
- **Idempotentes**: guardar o `PurchaseId` em `ProcessedPurchases`; se já existir, devolver `PurchaseGranted` sem conceder de novo.
- Conceder → **gravar** → só depois devolver `Enum.ProductPurchaseDecision.PurchaseGranted`.
- Se a gravação falhar, reverter e devolver `NotProcessedYet`.
- Nunca conceder itens pagos por outro caminho (ex.: RemoteEvent do cliente).

### 5. Dados do jogador
- Só através do módulo `PlayerData` (`src/server/Services/PlayerData`), que usa **ProfileStore**.
- **Nunca** usar `DataStoreService` diretamente.
- Alterações de esquema: adicionar o campo ao template do `PlayerData` (o `Reconcile` preenche os jogadores antigos).

### 6. Config única
- Preços, raridades, probabilidades e toda a economia ficam em `src/shared/Config.luau`.
- Proibido números "mágicos" de economia espalhados pelo código.
- O cliente pode ler a Config para mostrar UI, mas o servidor revalida sempre.

### 7. Antes de cada commit
```
selene src
stylua src
```
(Hook em `.githooks/pre-commit`; ativar com `git config core.hooksPath .githooks`.)
Não fazer commit com erros do selene ou ficheiros por formatar.

### 8. Testar com o Studio MCP
Sequência fixa, sem saltar passos:
1. **Parar** o play.
2. **Esperar** a sincronização do Rojo (confirmar que o `rojo serve` ligou/atualizou).
3. **Iniciar** o play.
4. **Ler a consola** (erros e avisos).
5. **Tirar screenshot** para confirmar o resultado visual.
Se houver erros na consola, corrigir no disco e repetir a sequência.

## Convenções de código
- Ficheiros `.luau`; scripts de servidor `*.server.luau`, de cliente `*.client.luau`; módulos sem sufixo.
- `--!strict` em todos os módulos.
- Tabs/estilo conforme `stylua.toml`.
- Funções que tocam em dados ou dinheiro: pequenas, testáveis e com guardas no início.

## Fluxo de trabalho do Claude
1. Ler esta regra-lista antes de alterar código.
2. Fazer alterações apenas em `src/`.
3. Correr `selene src` e `stylua src`.
4. Testar com a sequência do Studio MCP.
5. Só então propor o commit.
