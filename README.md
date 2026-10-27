# Lasso-Studios (Roblox, Luau + Rojo)

Ver `README-SETUP.md` para instalar as ferramentas e `CLAUDE.md` para as regras do projeto.

## Fluxo de trabalho (Git)

- **Uma branch por funcionalidade**, a partir de `main`: `feature/nome-curto` (ou `fix/...`).
- **Nunca** fazer commit direto em `main`.
- Antes de cada commit: `selene src` e `stylua src` (o hook faz a verificação).
- Abrir **Pull Request** para `main`, com descrição curta e screenshot/teste feito no Studio.
- **O Diogo faz o merge.** Ninguém mais faz merge em `main`.
- Depois do merge, apagar a branch.

```
git switch main && git pull
git switch -c feature/nome-curto
# ... trabalhar, testar ...
git add -A && git commit -m "feat: descrição"
git push -u origin feature/nome-curto
# abrir o PR no GitHub
```
