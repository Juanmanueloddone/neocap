-- Extensión
create extension if not exists "pgcrypto";

-- Tipos
create type public.pillar as enum ('educacion','economia','politica','alimentacion');
create type public.age_band as enum ('16_34','35_52','53_plus');

-- Perfiles (extiende auth.users)
create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  birthdate date,
  role text check (role in ('individual','adulto','nino','docente')) default 'individual',
  created_at timestamptz default now()
);
alter table public.profiles enable row level security;
create policy "me_veo"   on public.profiles for select using (auth.uid() = user_id);
create policy "me_edito" on public.profiles for update using (auth.uid() = user_id);

-- Playbook Neo (doctrina versionada)
create table if not exists public.playbook_entries (
  id uuid primary key default gen_random_uuid(),
  pillar public.pillar not null,
  slug text not null,
  version int not null default 1,
  title text not null,
  body_markdown text not null,
  capsule_short text,
  created_at timestamptz default now(),
  unique (pillar, slug, version)
);

-- Eventos (noticias normalizadas)
create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  source_url text,
  title text not null,
  summary text not null,
  pillar public.pillar not null,
  topic text,
  opens_at timestamptz default now(),
  closes_at timestamptz,
  status text not null check (status in ('open','closed')) default 'open',
  created_at timestamptz default now()
);

-- Propuestas (incluye Propuesta Neo)
create table if not exists public.proposals (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  kind text not null check (kind in ('neo','si','no','alternativa')),
  title text not null,
  body text,
  author_user_id uuid references auth.users(id),
  created_at timestamptz default now()
);

-- Votos (1 por usuario por evento) + rango etario
create table if not exists public.votes (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  proposal_id uuid not null references public.proposals(id) on delete cascade,
  voter_user_id uuid not null references auth.users(id) on delete cascade,
  age_band public.age_band not null,
  created_at timestamptz default now(),
  unique (event_id, voter_user_id)
);
alter table public.votes enable row level security;
create policy "yo_voto"       on public.votes for insert with check (auth.uid() = voter_user_id);
create policy "veo_mis_votos" on public.votes for select using    (auth.uid() = voter_user_id);

-- Snapshots de indicadores
create table if not exists public.indicator_snapshots (
  id bigserial primary key,
  at_time timestamptz not null default now(),
  agua numeric not null default 0,
  aire numeric not null default 0,
  salud numeric not null default 0,
  comunidad numeric not null default 0,
  paz numeric not null default 0,
  indice_neo numeric not null default 0
);

-- Ledger NEOC (emisión por jugar)
create table if not exists public.neoc_ledger (
  id bigserial primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  delta numeric(18,6) not null,
  reason text not null,                 -- 'vote','module','sanction', etc.
  event_id uuid references public.events(id),
  meta jsonb,
  created_at timestamptz default now()
);
alter table public.neoc_ledger enable row level security;
create policy "veo_mi_ledger" on public.neoc_ledger for select using (auth.uid() = user_id);

-- Anclado/auditoría
create table if not exists public.merkle_batches (
  id bigserial primary key,
  batch_start timestamptz not null default now(),
  batch_end timestamptz,
  root_hash text not null,
  published_tx text
);
