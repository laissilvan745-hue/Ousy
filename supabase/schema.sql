-- =====================================================================
-- OUSY Intelligence — esquema PostgreSQL / Supabase (fase 2, referência)
-- Espelha as coleções da versão local (index.html). Os ids textuais da v1
-- são preservados para permitir a importação do backup JSON.
-- =====================================================================

create type provenance as enum ('briefing', 'oficial', 'terceiros', 'hipotese', 'interno');
create type verification_status as enum ('pendente', 'verificado', 'divergente', 'desatualizado');
create type construction_stage as enum ('nao_informado', 'pre_lancamento', 'lancamento', 'fundacao', 'em_obras', 'pronto', 'entregue');
create type price_type as enum ('a_partir_de', 'tabela_unidade', 'promocional', 'faixa');
create type geo_status as enum ('nao_geocodificado', 'geocodificado_pendente', 'aproximado', 'validado');
create type user_role as enum ('admin', 'analista', 'leitor');

-- Campos comuns de governança (repetidos por clareza em cada tabela factual)
-- provenance, verification, last_verified_at, reference_date, created_at, updated_at

create table profiles (
  id uuid primary key references auth.users on delete cascade,
  full_name text,
  role user_role not null default 'leitor',
  created_at timestamptz not null default now()
);

create table sources (
  id text primary key,
  title text not null,
  type text not null,
  url text,
  accessed_at date not null,
  reliability text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table companies (
  id text primary key,
  name text not null,
  kind text,
  website text,
  instagram text,
  notes text,
  provenance provenance not null default 'interno',
  verification verification_status not null default 'pendente',
  last_verified_at date,
  reference_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table developments (
  id text primary key,
  name text not null,
  is_ousy boolean not null default false,
  ousy_ref_id text references developments(id),
  display_order int,
  -- localização
  street text, number text, complement text, neighborhood text, region text, city text, uf text, cep text,
  address_status text not null default 'completo',
  address_reference text,
  lat double precision, lng double precision,
  geo_status geo_status not null default 'nao_geocodificado',
  geo_source text, geocoded_at timestamptz, geo_display_name text,
  -- produto
  typologies_text text, area_min numeric, area_max numeric, area_qualifier text default 'faixa', units int,
  target_audience text, positioning text, differentials text, amenities text, availability_note text,
  -- obra e datas ('AAAA-MM' ou 'AAAA', preservando a precisão informada)
  stage construction_stage not null default 'nao_informado', stage_note text,
  launch_date text, delivery_forecast text, delivery_actual text, delivery_note text,
  -- comercial e digital
  commercial_conditions text, housing_program text,
  links jsonb not null default '{}'::jsonb,
  strategic_notes text,
  provenance provenance not null default 'interno',
  verification verification_status not null default 'pendente',
  last_verified_at date,
  reference_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ousy_ref_only_for_competitors check (not (is_ousy and ousy_ref_id is not null))
);
create index on developments (ousy_ref_id);

create table development_companies (
  development_id text references developments(id) on delete cascade,
  company_id text references companies(id) on delete cascade,
  primary key (development_id, company_id)
);

create table stations (
  id text primary key,
  name text not null,
  lines text,
  lat double precision, lng double precision,
  geo_status geo_status not null default 'nao_geocodificado',
  notes text,
  provenance provenance not null default 'interno',
  verification verification_status not null default 'pendente',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table proximities (
  id text primary key,
  development_id text not null references developments(id) on delete cascade,
  station_id text references stations(id),
  distance_m numeric,
  qualifier text not null,           -- aprox | exata | sem_numero | referencia
  text text,
  provenance provenance not null default 'interno',
  verification verification_status not null default 'pendente',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table typologies (
  id text primary key,
  development_id text not null references developments(id) on delete cascade,
  kind text not null, label text, area_min numeric, area_max numeric, units_count int, notes text,
  provenance provenance not null default 'interno',
  verification verification_status not null default 'pendente',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table campaigns (
  id text primary key,
  development_id text not null references developments(id) on delete cascade,
  name text not null, kind text, offer text, start_date date, end_date date, identified_at date not null,
  channels text, notes text,
  provenance provenance not null default 'interno',
  verification verification_status not null default 'pendente',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table prices (
  id text primary key,
  development_id text not null references developments(id) on delete cascade,
  typology_label text not null,
  unit text,
  value numeric(14,2) not null check (value > 0),
  price_type price_type not null,
  -- preenchida SOMENTE quando a fonte vincula o preço à metragem
  area_m2 numeric,
  collected_at date not null,
  is_promo boolean not null default false,
  campaign_id text references campaigns(id),
  conditions text, source_url text, notes text,
  provenance provenance not null default 'interno',
  verification verification_status not null default 'pendente',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index on prices (development_id, collected_at);

-- R$/m² apenas quando verificável
create view price_per_m2 as
  select id, development_id, typology_label, price_type, value, area_m2, value / area_m2 as value_per_m2, collected_at
  from prices where area_m2 is not null and area_m2 > 0;

create table websites (
  id text primary key,
  development_id text not null references developments(id) on delete cascade,
  kind text not null, url text not null, commercial_urls text, notes text,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table seo_audits (
  id text primary key,
  development_id text not null references developments(id) on delete cascade,
  url text not null, analyzed_at date not null, analyst text,
  title_tag text, meta_description text, h1 text, headings text, keywords text,
  structured_data text, performance text, performance_tool text,
  value_prop text, differentials text, commercial_args text, offers text, ctas text,
  whatsapp text, forms text, social_proof text, has_images text, has_video text, mentions_metro text,
  arg_tags text[] not null default '{}', evidence text, opportunities text,
  provenance provenance not null default 'interno',
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table ads (
  id text primary key,
  development_id text not null references developments(id) on delete cascade,
  advertiser text not null, platform text not null, url text, source_name text,
  identified_at date not null, period_start date, period_end date, status text, format text,
  headline text, primary_text text, cta text, offer text, commercial_arg text, funnel text, landing_url text,
  audience_hypothesis text,          -- sempre hipótese
  arg_tags text[] not null default '{}', notes text,
  provenance provenance not null default 'interno',
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table social_profiles (
  id text primary key,
  development_id text references developments(id) on delete set null,
  company_id text references companies(id) on delete set null,
  network text not null, handle text not null, url text,
  followers int, followers_at date, posting_frequency text, formats text[], themes text[],
  tone text, positioning text, sales_args text, ctas text, offers text, engagement_notes text, campaigns text,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table social_posts (
  id text primary key,
  profile_id text not null references social_profiles(id) on delete cascade,
  development_id text references developments(id) on delete set null,
  published_at date not null, type text not null, theme text not null,
  url text, caption text, likes int, comments int, views int,
  arg_tags text[] not null default '{}', notes text,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

-- Vínculo N:N registro ↔ fonte (substitui os arrays sourceIds da v1)
create table record_sources (
  entity text not null, entity_id text not null,
  source_id text not null references sources(id) on delete cascade,
  primary key (entity, entity_id, source_id)
);

-- Evidências em Supabase Storage
create table attachments (
  id text primary key,
  entity text, entity_id text,
  name text not null, mime text, size_bytes int, storage_path text not null,
  created_at timestamptz not null default now()
);

create table change_log (
  id bigserial primary key,
  at timestamptz not null default now(),
  entity text not null, entity_id text not null, development_id text,
  field text not null, old_value jsonb, new_value jsonb,
  user_id uuid references auth.users, source_id text references sources(id), note text
);
create index on change_log (development_id, at desc);

create table reports (
  id text primary key, title text not null, category text, params jsonb, content jsonb not null,
  created_by uuid references auth.users, created_at timestamptz not null default now()
);

-- Histórico automático no servidor -----------------------------------
create or replace function log_changes() returns trigger language plpgsql security definer as $$
declare k text; o jsonb := to_jsonb(old); n jsonb := to_jsonb(new);
begin
  for k in select jsonb_object_keys(n) loop
    if k not in ('updated_at', 'created_at') and (o -> k) is distinct from (n -> k) then
      insert into change_log (entity, entity_id, development_id, field, old_value, new_value, user_id)
      values (tg_table_name, new.id,
              case when tg_table_name = 'developments' then new.id else n ->> 'development_id' end,
              k, o -> k, n -> k, auth.uid());
    end if;
  end loop;
  new.updated_at := now();
  return new;
end $$;

do $$ declare t text; begin
  foreach t in array array['companies','developments','stations','proximities','typologies','prices','campaigns','websites','seo_audits','ads','social_profiles','social_posts'] loop
    execute format('create trigger %I_log before update on %I for each row execute function log_changes()', t, t);
  end loop;
end $$;

-- Row Level Security (exemplo) ----------------------------------------
create or replace function current_role_is(r user_role[]) returns boolean language sql stable as $$
  select exists (select 1 from profiles p where p.id = auth.uid() and p.role = any(r));
$$;

do $$ declare t text; begin
  foreach t in array array['sources','companies','developments','development_companies','stations','proximities','typologies','prices','campaigns','websites','seo_audits','ads','social_profiles','social_posts','record_sources','attachments','change_log','reports'] loop
    execute format('alter table %I enable row level security', t);
    execute format('create policy %I_read on %I for select to authenticated using (true)', t, t);
    execute format('create policy %I_write on %I for all to authenticated using (current_role_is(array[''admin'',''analista'']::user_role[])) with check (current_role_is(array[''admin'',''analista'']::user_role[]))', t, t);
  end loop;
end $$;
