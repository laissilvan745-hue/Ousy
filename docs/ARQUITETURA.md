# Arquitetura — OUSY Intelligence

## 1. Visão geral da versão 1 (local)

```
index.html
├── Design tokens (CSS custom properties)  → tema substituível
├── <script id="seed-data">                 → base inicial do briefing (JSON, separada da UI)
└── <script> aplicação
    ├── CONFIG / ENUMS        vocabulário controlado (estágio, tipo de preço, proveniência…)
    ├── U (utilitários)       formatação pt-BR, CSV, download, haversine
    ├── DB                    IndexedDB (fallback em memória)
    ├── Store (repositório)   cache + CRUD + histórico automático de alterações
    ├── Seed                  carga única do briefing
    ├── Schemas               definição declarativa dos formulários por entidade
    ├── A (analytics)         funções puras: preço inicial, variações, R$/m², alertas, comparabilidade
    ├── UI                    modal, confirmação, formulário, tabela CRUD, gráficos
    ├── Reveal / Radar        animações de entrada (Motion) e radar em canvas
    ├── Views                 um módulo por rota (#/dashboard, #/precos, …)
    └── Router                roteamento por hash, busca global, inicialização
```

Princípios:
- **Separação dados × interface**: as views só leem via `Store`/`A`; a persistência fica atrás de `DB`.
  Trocar IndexedDB por Supabase significa reimplementar `DB` e `Store.load/_write` — as views não mudam.
- **Histórico automático**: `Store.update` compara o registro campo a campo e grava em `changeLog`
  (valor anterior, novo valor, data, responsável, fonte, observação).
- **Sem simulação**: alertas são calculados dos dados; geocodificação é uma chamada real ao Nominatim,
  sob demanda e sujeita a validação humana; integrações que exigem backend estão rotuladas como futuras.

## 2. Modelo de dados

Todas as coleções têm `id`, `createdAt`, `updatedAt`. Registros factuais também têm os campos de governança
`provenance`, `verification`, `sourceIds[]`, `lastVerifiedAt`, `referenceDate`.

| Coleção | Conteúdo | Relações |
|---|---|---|
| `companies` | Incorporadoras, construtoras, marcas | — |
| `developments` | Empreendimentos (Ousy e concorrentes): endereço, produto, obra, datas, links | `ousyRefId → developments`, `companyIds[] → companies` |
| `stations` | Estações de metrô (coordenada só se validada) | — |
| `proximities` | Distância informada empreendimento → estação, com qualificador | `developmentId`, `stationId` (opcional) |
| `typologies` | Tipologias e faixas de metragem | `developmentId` |
| `prices` | Coletas de preço (valor, tipo, metragem vinculada, data, origem) | `developmentId`, `campaignId` |
| `campaigns` | Campanhas/condições comerciais | `developmentId` |
| `websites` | Sites e landing pages | `developmentId` |
| `seoAudits` | Auditorias on-page com evidências | `developmentId`, `attachmentIds[]` |
| `ads` | Anúncios (Meta, Google…) | `developmentId`, `attachmentIds[]` |
| `socialProfiles` / `socialPosts` | Perfis e publicações | `developmentId`/`companyId`, `profileId` |
| `sources` | Fontes e evidências | referenciadas por `sourceIds[]` |
| `changeLog` | Histórico de alterações | `entity` + `entityId`, `developmentId`, `sourceId` |
| `alertStates` | Alertas dispensados (os alertas são derivados) | chave do alerta |
| `reports` | Relatórios salvos | — |
| `attachments` | Arquivos (data URL) | — |

### Situação no painel e status de venda
`developments.monitorStatus` separa **concorrentes ativos** (entram em indicadores, radar e comparativo padrão),
**candidatos a substituto** (`replacesId` aponta o concorrente que podem substituir) e **arquivados** (saem do painel,
mantêm histórico). `salesStatus` registra o selo observado em fonte (`a_venda`, `sem_selo`, `ultimas_unidades`,
`esgotado`) com a evidência em `salesStatusNote`; "100% vendido" e "últimas unidades" geram alerta.

### Atualizações de dados versionadas
O bloco `<script id="data-updates">` em `index.html` contém lotes de alterações (`upsert`, `patch`, `patchWhere`)
aplicados uma única vez por navegador (controle em `meta/updates`), inclusive em bases já existentes. Cada
alteração passa pelo repositório e entra no histórico com a fonte. Na fase 2, esses lotes viram migrações de dados
ou jobs de coleta.

### Séries de preço
Uma série = empreendimento + tipologia + unidade + metragem vinculada + tipo de preço. Variações são calculadas
entre as duas últimas coletas da mesma série. O "preço inicial divulgado" é o menor valor vigente entre as séries.

## 3. Governança

**Natureza do dado (`provenance`)**
| Valor | Significado |
|---|---|
| `briefing` | Fornecido pela equipe Ousy no briefing (ref. 08/10/2026) |
| `oficial` | Confirmado em fonte da própria incorporadora ou registro oficial |
| `terceiros` | Corretores, portais, imprensa |
| `hipotese` | Interpretação analítica — nunca tratada como fato |
| `interno` | Cadastro operacional da equipe |

**Status de verificação (`verification`)**: `pendente` · `verificado` · `divergente` · `desatualizado`.
Um registro sem verificação há mais de 30 dias (`CONFIG.staleDays`) gera alerta de dado desatualizado.

**Geolocalização (`geo.status`)**: `nao_geocodificado` → `geocodificado_pendente` / `aproximado` (sem número)
→ `validado` (confirmação humana). Só `validado` vira marcador preciso.

**Distância ao metrô (`qualifier`)**: `aprox` (informada) · `exata` (verificada) · `sem_numero` · `referencia`.

## 4. Evolução (fase 2): Supabase / PostgreSQL

1. **Banco** — `supabase/schema.sql` traduz as coleções em tabelas normalizadas com chaves estrangeiras,
   enums e índices. A migração inicial importa o backup JSON exportado pela v1 (os ids são preservados).
2. **Autenticação** — Supabase Auth (e-mail/SSO). Tabela `profiles` com papéis `admin`, `analista`, `leitor`.
   Row Level Security: leitura para usuários autenticados da organização; escrita para analista/admin.
3. **Histórico no servidor** — trigger `log_changes()` grava `change_log` em todo `UPDATE`, com `auth.uid()`
   como responsável — o histórico deixa de depender do cliente.
4. **Camada de acesso** — substituir `DB`/`Store` por um cliente `supabase-js` com cache local
   (IndexedDB continua como cache offline). Realtime para atualizar telas entre usuários.
5. **Coletas agendadas** — Edge Functions + `pg_cron`:
   - verificação periódica das landing pages (status HTTP, title/meta/H1, captura em Storage);
   - PageSpeed Insights API para desempenho;
   - Meta Ad Library API (exige token e verificação; cobertura limitada para anúncios não políticos);
   - toda coleta automática entra como `pendente` até revisão humana.
6. **Alertas e notificações** — view materializada de alertas + Edge Function de envio (e-mail/Slack).
7. **Evidências** — Supabase Storage substitui os anexos em data URL.
8. **Front-end** — o HTML único pode migrar para um projeto Vite mantendo os tokens CSS, `Schemas` e `A`
   (já são módulos independentes de framework).

## 5. Limitações conhecidas da v1

- Dados ficam no navegador; não há sincronização entre usuários (use exportação/importação JSON).
- Anexos grandes aumentam o IndexedDB e o backup JSON.
- Geocodificação depende do serviço público Nominatim (uso moderado, uma consulta por vez).
- Os relatórios são baseados em regras; não usam modelos de linguagem.
