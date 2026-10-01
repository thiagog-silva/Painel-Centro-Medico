# Hospital São Nicolau — Painel de Automação

**Versão 1.0.0** (build 2026-10-01). Pasta independente: funciona sem o Claude e sem depender de nenhum outro painel.
Só a fonte IBM Plex vem do Google Fonts; sem internet o painel usa a fonte padrão do sistema e funciona normalmente.

## Como abrir

**Recomendado — atalho que sobe um servidor local só para esta pasta:**

- **Windows:** duplo-clique em `iniciar_painel.bat` (precisa de Python instalado). Deixe a janela aberta enquanto usa o painel. Em alguns computadores de empresa scripts `.bat` são bloqueados; nesse caso use o `painel-sao-nicolau.html` direto.
- **Mac:** duplo-clique em `iniciar_painel.command` (na primeira vez: botão direito → Abrir → Abrir mesmo assim).

**Alternativa:** duplo-clique em `painel-sao-nicolau.html`. Funciona, com uma diferença: o botão de tema do painel não consegue mudar o tema das ferramentas já abertas (elas continuam seguindo o tema do sistema). Com o atalho acima, o tema é repassado normalmente.

## O que tem aqui dentro

- `painel-sao-nicolau.html` — o painel (menu lateral, cards, adicionar/remover ferramentas).
- `index.html` — só redireciona para `painel-sao-nicolau.html`. Serve para o GitHub Pages (e qualquer hospedagem) achar a página principal; não edite nem apague.
- `tools/` — um arquivo `.html` por ferramenta fixa.
- `iniciar_painel.bat` / `iniciar_painel.command` — só abrem o servidor local (porta 8791).

Ferramentas já instaladas:

- **Extrair Dados da Folha** (`tools/extrair-dados-folha.html`, categoria *Folha de Pagamento*) — lê o PDF da Relação de Cálculo, cruza férias e rescisões com os CSVs do banco e gera o layout para colar na planilha. Usa pdf.js via internet (cdnjs), então precisa de conexão na primeira abertura.
- **Faturamento Mensal Tasy** (`tools/faturamento-mensal-tasy.html`, categoria *Faturamento*) — gera os lançamentos de faturamento bruto (particular, convênio e SUS) e o TXT de importação do Tasy a partir da Relação de Serviços e Deduções Federais. Usa ExcelJS via internet (cdnjs).
- **Extratos Bancários Tasy** (`tools/extratos-bancarios-tasy.html`, categoria *Conciliação*) — transforma os extratos do mês (CSV/XLSX) em lançamentos TXT para importar no Tasy, validando débito = crédito, contas e CR. Não depende de internet (biblioteca embutida) e guarda neste navegador o plano de contas, as regras e os bancos que você atualizar.
- **Resumo de Estoque** (`tools/resumo-estoque-balancete.html`, categoria *Conciliação*) — lê o PDF do relatório Saldo de Estoque do Tasy e monta o resumo e os lançamentos de estoque conferidos com o Balancete. Não depende de internet (bibliotecas embutidas) e guarda neste navegador as contas dos movimentos.
- **Zerar CR** (`tools/zerar-cr.html`, categoria *Folha de Pagamento*) — corrige o TXT de lançamentos do Tasy: zera o CR de lançamentos sem contrapartida em Ativo/Passivo, ajusta débito = crédito, remove duplicatas e aplica o fato contábil. Não depende de internet.

As próximas serão adicionadas depois, como descrito abaixo.

## Adicionar uma ferramenta

**1. Fixa (definitiva, vale para todos que usarem esta pasta)**

1. Salve o `.html` dentro de `tools/` (ex.: `tools/conciliacao.html`).
2. Abra `painel-sao-nicolau.html` num editor de texto e, no array `TOOLS` (perto do topo do `<script>`), copie o modelo comentado e preencha `id`, `nome`, `descricao`, `icone`, `categoria` e `arquivo` (`tools/conciliacao.html`).
3. Salve e recarregue o painel.

**2. Pela interface (rápido, fica só neste navegador)**

Menu lateral → **Adicionar nova ferramenta** → escolha o `.html` → confira nome, categoria, ícone e descrição → **Adicionar ferramenta**. Para tirar, use a lixeira do card. Ferramentas fixas não têm lixeira (para removê-las, apague a entrada do `TOOLS`).

As ferramentas devem seguir o `prompt-padrao-nova-ferramenta.md` (paleta São Nicolau, tema claro/escuro, ponte de downloads).

## Downloads

Dentro do painel, a ferramenta pede o download ao painel (ponte do padrão) e o navegador salva o arquivo. Aberta sozinha, usa o download nativo.

## Isolamento e segurança

Com o servidor local, cada ferramenta abre num quadro isolado (sandbox). As ferramentas fixas (pasta `tools/`) mantêm o armazenamento do navegador para guardar preferências; as adicionadas pela tela ficam totalmente isoladas e não guardam preferências entre aberturas. erro numa ferramenta aparece como aviso e não derruba o painel. Ao abrir `painel-sao-nicolau.html` direto (sem servidor), o navegador não deixa o painel ler os arquivos de `tools/`, então a ferramenta abre num quadro comum (sem sandbox) — continua funcionando e isolada por ser outro documento, mas sem aviso automático de erro nem repasse do botão de tema.

## Limites

8 MB por ferramenta adicionada pela interface; 80 ferramentas adicionadas pela interface.


## Publicar no GitHub Pages

Suba a pasta inteira (com `tools/`, `index.html` e `.nojekyll`) na raiz do repositório e ative Settings > Pages > Deploy from a branch > main / (root). O endereço abre direto o painel. O painel e a pasta `tools/` precisam ficar juntos.