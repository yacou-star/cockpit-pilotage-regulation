-- ============================================================
-- Cockpit Pilotage & Régulation — schéma Supabase AVEC COMPTES
-- Chaque utilisateur a son compte et ses données isolées.
-- Les ADMINISTRATEURS sont désignés PAR E-MAIL dans ce script
-- (ligne marquée "← ADMIN" dans handle_new_user ci-dessous).
--
-- À exécuter UNE FOIS dans Supabase > SQL Editor > New query
-- (remplace l'ancienne version sans comptes : les tables
--  cockpit_state au format partagé seront recréées vides)
-- ============================================================

-- 1. Profils utilisateurs (rattachés aux comptes d'authentification)
create table if not exists public.profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  email      text,
  role       text not null default 'user' check (role in ('user','admin')),
  created_at timestamptz not null default now()
);

-- 2. Données du cockpit : une ligne par utilisateur
drop table if exists public.cockpit_state;
create table public.cockpit_state (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb not null,
  updated_at timestamptz not null default now()
);

-- 3. Helper : l'utilisateur courant est-il admin ?
--    (security definer pour éviter la récursion RLS sur profiles)
create or replace function public.is_admin()
returns boolean
language sql stable
security definer set search_path = public
as $$
  select coalesce((select role = 'admin' from public.profiles where id = auth.uid()), false);
$$;

-- 4. À l'inscription : création automatique du profil.
--    Rôle admin attribué selon la liste d'e-mails ci-dessous.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, role)
  values (
    new.id,
    new.email,
    case
      when lower(new.email) = any (array['vous@exemple.fr']) then 'admin'  -- ← ADMIN : mettez ici le(s) e-mail(s) admin, ex. array['a@x.fr','b@x.fr']
      else 'user'
    end
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 5. Sécurité (RLS)
alter table public.profiles      enable row level security;
alter table public.cockpit_state enable row level security;

-- Profils : lisibles par tous les connectés (nécessaire au panneau admin
-- et à l'affichage du rôle), modifiables par soi-même ou par un admin.
drop policy if exists "profiles read"   on public.profiles;
drop policy if exists "profiles insert" on public.profiles;
drop policy if exists "profiles update" on public.profiles;

create policy "profiles read"   on public.profiles
  for select to authenticated using (true);
create policy "profiles insert" on public.profiles
  for insert to authenticated with check (auth.uid() = id);
create policy "profiles update" on public.profiles
  for update to authenticated
  using (auth.uid() = id or public.is_admin())
  with check (auth.uid() = id or public.is_admin());

-- Données du cockpit : chacun accède aux siennes ; l'admin a accès à tout.
drop policy if exists "state select" on public.cockpit_state;
drop policy if exists "state insert" on public.cockpit_state;
drop policy if exists "state update" on public.cockpit_state;
drop policy if exists "state delete" on public.cockpit_state;

create policy "state select" on public.cockpit_state
  for select to authenticated
  using (auth.uid() = user_id or public.is_admin());
create policy "state insert" on public.cockpit_state
  for insert to authenticated
  with check (auth.uid() = user_id or public.is_admin());
create policy "state update" on public.cockpit_state
  for update to authenticated
  using (auth.uid() = user_id or public.is_admin())
  with check (auth.uid() = user_id or public.is_admin());
create policy "state delete" on public.cockpit_state
  for delete to authenticated
  using (auth.uid() = user_id or public.is_admin());

-- ------------------------------------------------------------
-- Pour promouvoir admin un compte DÉJÀ créé (au besoin, SQL Editor) :
-- update public.profiles set role = 'admin' where email = 'quelqu_un@exemple.fr';
-- ------------------------------------------------------------
