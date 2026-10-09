# OUSY Intelligence | Inteligência de Mercado Imobiliário

Plataforma de monitoramento e inteligência competitiva para os empreendimentos da [Ousy](https://ousyinc.com.br/):
**The One Saúde**, **The One Tucuruvi** e **Ousy VM (Vila Mariana)**, com seus 17 concorrentes diretos.

## Como usar

Abra `index.html` no navegador (duplo clique). Não é preciso servidor nem instalação.

- Na primeira abertura, a base inicial do briefing (ref. **08/10/2026**) é gravada no **IndexedDB** do navegador.
  Todos esses registros entram como *Briefing* + *Pendente de validação*.
- Os dados ficam no navegador/computador onde foram cadastrados. Use **Dados e integrações → Exportar JSON**
  para fazer backup ou levar a base para outra máquina.
- Bibliotecas externas (Chart.js, Leaflet, Motion, jsPDF) vêm de CDN. Sem internet, a plataforma continua
  funcionando, mas sem gráficos, mapa, animações e PDF (a impressão do navegador substitui o PDF).

## Módulos

| # | Módulo | Destaques |
|---|--------|-----------|
| — | Início | Hero com radar animado, cartões Ousy com status do site, cards de serviços com *fade-in* + *slide-up* (Motion) ao rolar |
| — | Radar competitivo | Varredura contínua com "ping" a cada contato; raio = distância ao metrô, preço "a partir de" ou prazo de entrega; ✕ = 100% vendido, anel tracejado = últimas unidades; candidatos opcionais |
| 01 | Dashboard executivo | KPIs com data de referência e nº de registros; gráficos de preço, estágio, entregas e evolução |
| 02 | Empreendimentos | Abas por empreendimento Ousy, cartões/tabela, ficha com fonte de cada dado; filtros por grupo, bairro, incorporadora, preço, metragem, estágio, entrega, status de venda e situação no painel; candidatos a substituto |
| 03 | Comparativo | 2 a 5 projetos lado a lado; indica comparação direta × não direta e o motivo |
| 04 | Preços | Histórico por série, variações %, R$/m² só com metragem vinculada, promoções e campanhas |
| 05 | Localização | Mapa Leaflet/OSM; geocodificação Nominatim sob demanda + validação manual |
| 06 | Sites e SEO | Páginas, auditorias on-page, matriz de presença e matriz de comunicação |
| 07 | Anúncios | Biblioteca visual, tabela, comparativo de mensagens, links para Meta Ad Library / Google Transparency |
| 08 | Redes sociais | Perfis, publicações por tema, tendências e hipóteses de oportunidade |
| 09 | Histórico e alertas | Linha do tempo de alterações (valor anterior → novo), alertas e pendências de verificação |
| 10 | Relatórios | Fatos / interpretações / hipóteses / lacunas, com confiança; exporta PDF, HTML e Markdown |

## Verificação de out/2026 (atualização de dados aplicada)

O relatório "Concorrentes Ousy: verificação de 100% vendido e substitutos" foi incorporado como atualização
versionada (aplicada automaticamente uma vez, também em bases já existentes, com tudo registrado no histórico):

- **Free Home / Free Praça da Árvore**: 100% vendido (site Inovcorp), nº 580, 150 m do metrô Praça da Árvore,
  entrega abr/2022 segundo a Ópera Gestora (o briefing dizia dez/2025). Marcado como divergente.
- **The Collection Vila Mariana**: últimas unidades; entrega jul/2028 (briefing: mai/2028); nova coleta de preço
  no hotsite, a partir de R$ 354.900 (briefing: R$ 413.059), o que gera alerta de variação de −14,1%.
- **Nurban, Metrocasa Prime, myID, Multi, Viva Benx, Influencer**: status de venda, estágio, número do endereço
  e distâncias oficiais. Quando o site oficial diverge do briefing, a ficha fica como "Divergente entre fontes";
  leituras parciais (Viva Benx, Influencer) não sobrescrevem o briefing e ficam registradas em observação.
- **Candidatos a substituto** (fora dos indicadores até você decidir): The Rose Vila Mariana (Ousy VM, para o
  Collection), Free Concept (The One Saúde, para o Free Praça da Árvore), Residencial Verbena e Spazio
  Tucuruvi (The One Tucuruvi). Nenhum tem preço publicado em fonte oficial, por isso o campo fica vazio.
- Status dos empreendimentos Ousy conforme o site: Breve Lançamento, Em Obras e Futuro Lançamento.

Na ficha de um candidato, ou na aba do empreendimento, **Incluir no painel**, **Substituir [concorrente]** e
**Arquivar** alteram a situação de monitoramento. O concorrente substituído é arquivado, nunca excluído, e pode ser
restaurado.

## Regras de dados aplicadas

- Informação ausente aparece como **Não informado** — nunca é preenchida por suposição.
- Preço **"a partir de"** não é preço médio e só gera R$/m² quando a fonte o vincula a uma metragem.
- Preço anunciado ≠ preço negociado.
- Nenhuma coordenada é inventada. O Ousy VM fica sem localização exata até a divulgação do endereço.
- Investimento em mídia, impressões, leads e tráfego não são exibidos sem fonte confiável.
- Público-alvo inferido de anúncios é sempre marcado como **hipótese**.
- Automações que dependem de backend aparecem como **integrações futuras**.

## Identidade visual (Design System Ousy Inc.)

A interface segue o design system levantado do CSS publicado em ousyinc.com.br (08/10/2026):

- **Tokens oficiais** (seção "1a" do CSS em `index.html`): `ink` #261F1F como cor estrutural, `orange` #F77E0B como
  único acento, `graphite`, `stone`, `apricot`, `mist`, `silver` etc. A seção "1b" só cria aliases semânticos
  derivados deles; para ajustar a identidade, altere apenas a "1a".
- **Didact Gothic** em toda a interface (pesos 400, 500 e 600); o botão CTA usa `--font-button` (Neulis Alt, com
  Didact Gothic como alternativa enquanto a fonte própria não estiver disponível).
- **Cantos retos** em tudo; sombra apenas em painéis (`--shadow-panel`).
- Texto sobre laranja é sempre `ink`; laranja como texto só sobre `ink`.
- Componentes do site: etiqueta de status (`ousy-badge`: Breve Lançamento, Em Obras, Futuro Lançamento),
  cartão de empreendimento (`ousy-card`, botão CONHEÇA), faixa de contato (`ousy-band`, um CTA) e painel sobre scrim.
- O ícone oficial é carregado de ousyinc.com.br; offline, permanece o nome em texto.
- Aviso HIS/HMP no Início, remetendo a ousyinc.com.br/decreto-prefeitura/.
- Tema claro (padrão) e escuro, com superfícies derivadas de `ink`.

Valores provisórios, pois o CSS do site não os define: padding de botões (12px 24px), texto branco no botão
primário e `orange-deep` no hover do CTA. Confirme-os com o time de design da Ousy.

## Animações

As animações de entrada dos cards de serviços usam **Motion** (`motion@11`), a biblioteca JavaScript do
Framer Motion (o pacote `framer-motion` em si é exclusivo para React). `inView` dispara quando o card entra na
tela e `animate` executa `opacity 0→1` + `translateY 28px→0` em cascata. Sem a biblioteca, um
`IntersectionObserver` faz o mesmo efeito com CSS. A mesma entrada é aplicada aos cartões dos empreendimentos Ousy e à faixa de chamada. Com *reduzir movimento* ativo no sistema, nada é animado.

## Estrutura

```
index.html              Aplicação completa (CSS + dados iniciais + JS), ~3.800 linhas comentadas
docs/ARQUITETURA.md     Modelo de dados, governança e plano de evolução (Supabase, auth, coletas)
supabase/schema.sql     Esquema PostgreSQL de referência para a fase 2
```
