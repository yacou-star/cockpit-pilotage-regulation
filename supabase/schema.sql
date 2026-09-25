-- ============================================================
-- Cockpit Pilotage & Régulation — schéma Supabase
-- À exécuter UNE FOIS dans Supabase > SQL Editor > New query
-- ============================================================

-- 1. Table de stockage : une ligne par espace de travail
create table if not exists public.cockpit_state (
  workspace  text primary key,
  data       jsonb not null,
  updated_at timestamptz not null default now()
);

-- 2. Sécurité : lecture/écriture publique mais limitée à ce contexte applicatif
--    (la clé "anon" est publique par nature, comme l'URL du projet)
alter table public.cockpit_state enable row level security;

drop policy if exists "cockpit anon read"  on public.cockpit_state;
drop policy if exists "cockpit anon write" on public.cockpit_state;

create policy "cockpit anon read"
  on public.cockpit_state for select
  to anon
  using (true);

create policy "cockpit anon write"
  on public.cockpit_state for insert
  to anon
  with check (true);

create policy "cockpit anon update"
  on public.cockpit_state for update
  to anon
  using (true)
  with check (true);
