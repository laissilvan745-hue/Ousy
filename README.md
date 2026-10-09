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
| — | Início | Hero com radar animado e cards de serviços com *fade-in* + *slide-up* (Motion) ao rolar |
| — | Radar competitivo | Varredura contínua dos concorrentes; raio = distância ao metrô, preço "a partir de" ou prazo de entrega |
| 01 | Dashboard executivo | KPIs com data de referência e nº de registros; gráficos de preço, estágio, entregas e evolução |
| 02 | Empreendimentos | Abas por empreendimento Ousy, cartões/tabela, ficha detalhada com fonte de cada dado |
| 03 | Comparativo | 2 a 5 projetos lado a lado; indica comparação direta × não direta e o motivo |
| 04 | Preços | Histórico por série, variações %, R$/m² só com metragem vinculada, promoções e campanhas |
| 05 | Localização | Mapa Leaflet/OSM; geocodificação Nominatim sob demanda + validação manual |
| 06 | Sites e SEO | Páginas, auditorias on-page, matriz de presença e matriz de comunicação |
| 07 | Anúncios | Biblioteca visual, tabela, comparativo de mensagens, links para Meta Ad Library / Google Transparency |
| 08 | Redes sociais | Perfis, publicações por tema, tendências e hipóteses de oportunidade |
| 09 | Histórico e alertas | Linha do tempo de alterações (valor anterior → novo), alertas e pendências de verificação |
| 10 | Relatórios | Fatos / interpretações / hipóteses / lacunas, com confiança; exporta PDF, HTML e Markdown |

## Regras de dados aplicadas

- Informação ausente aparece como **Não informado** — nunca é preenchida por suposição.
- Preço **"a partir de"** não é preço médio e só gera R$/m² quando a fonte o vincula a uma metragem.
- Preço anunciado ≠ preço negociado.
- Nenhuma coordenada é inventada. O Ousy VM fica sem localização exata até a divulgação do endereço.
- Investimento em mídia, impressões, leads e tráfego não são exibidos sem fonte confiável.
- Público-alvo inferido de anúncios é sempre marcado como **hipótese**.
- Automações que dependem de backend aparecem como **integrações futuras**.

## Identidade visual

Cores, tipografia, espaçamentos, bordas e sombras estão centralizados em *design tokens* (variáveis CSS no
início de `index.html`, seção "1. DESIGN TOKENS"). Para aplicar o Design System oficial da Ousy, substitua
apenas esses valores. Há tema claro e escuro.

## Animações

As animações de entrada dos cards de serviços usam **Motion** (`motion@11`), a biblioteca JavaScript do
Framer Motion (o pacote `framer-motion` em si é exclusivo para React). `inView` dispara quando o card entra na
tela e `animate` executa `opacity 0→1` + `translateY 28px→0` em cascata. Sem a biblioteca, um
`IntersectionObserver` faz o mesmo efeito com CSS. Com *reduzir movimento* ativo no sistema, nada é animado.

## Estrutura

```
index.html              Aplicação completa (CSS + dados iniciais + JS), ~3.800 linhas comentadas
docs/ARQUITETURA.md     Modelo de dados, governança e plano de evolução (Supabase, auth, coletas)
supabase/schema.sql     Esquema PostgreSQL de referência para a fase 2
```
