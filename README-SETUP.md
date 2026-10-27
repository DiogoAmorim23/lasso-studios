# Setup rápido

1. Instalar ferramentas (ex.: Rokit): `rojo`, `selene`, `stylua`.
2. Descarregar o ProfileStore para `src/server/Lib/ProfileStore.luau`.
3. Ativar o hook: `git config core.hooksPath .githooks`
4. Gerar o `sourcemap.json` se usares luau-lsp: `rojo sourcemap default.project.json -o sourcemap.json`
5. `rojo serve` e ligar o plugin Rojo no Studio.
6. Substituir os ids de produtos em `src/shared/Config.luau`.
