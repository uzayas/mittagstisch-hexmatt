-- ============================================================
--  Mittagstisch Sekundarschule Pratteln – Supabase-Schema
--  Im Supabase-Dashboard unter «SQL Editor» komplett ausführen.
--  Das Skript kann mehrfach ausgeführt werden.
-- ============================================================

-- ---------- Tabellen ----------

-- Rolle pro Login: 'schule' (Schule/Lerninsel) oder 'tischli' (Es Tischli für Alli)
create table if not exists public.profiles (
  id           uuid primary key references auth.users (id) on delete cascade,
  role         text not null check (role in ('schule', 'tischli')),
  display_name text,
  created_at   timestamptz not null default now()
);

-- Schüler/innen am Mittagstisch
create table if not exists public.students (
  id          uuid primary key default gen_random_uuid(),
  first_name  text not null,
  last_name   text not null,
  class_name  text,
  remark      text,                                    -- Bemerkung: vegan, vegetarisch, …
  weekdays    smallint[] not null default '{1,2,4,5}', -- Anmeldetage: 1 = Mo … 5 = Fr
  active      boolean not null default true,           -- false = entfernt (Archiv)
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Abmeldungen pro Tag – getrennt nach Stelle (source)
create table if not exists public.absences (
  id          uuid primary key default gen_random_uuid(),
  student_id  uuid not null references public.students (id) on delete cascade,
  day         date not null,
  source      text not null check (source in ('schule', 'tischli')),
  reason      text,
  created_by  uuid default auth.uid() references auth.users (id) on delete set null,
  created_at  timestamptz not null default now(),
  unique (student_id, day, source)
);
create index if not exists absences_day_idx on public.absences (day);

-- Tage ohne Mittagstisch (Ferien, Feiertage, …)
create table if not exists public.closed_days (
  day         date primary key,
  note        text,
  created_by  uuid default auth.uid() references auth.users (id) on delete set null,
  created_at  timestamptz not null default now()
);

-- ---------- updated_at automatisch setzen ----------
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists students_set_updated_at on public.students;
create trigger students_set_updated_at
  before update on public.students
  for each row execute function public.set_updated_at();

-- ---------- Rolle des eingeloggten Benutzers ----------
create or replace function public.my_role()
returns text
language sql stable security definer
set search_path = public
as $$
  select role from public.profiles where id = auth.uid()
$$;

revoke all on function public.my_role() from public, anon;
grant execute on function public.my_role() to authenticated;

-- ---------- Row Level Security ----------
alter table public.profiles    enable row level security;
alter table public.students    enable row level security;
alter table public.absences    enable row level security;
alter table public.closed_days enable row level security;

-- profiles: jede/r sieht nur das eigene Profil (Rollen werden nur im Dashboard vergeben)
drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own on public.profiles
  for select to authenticated using (id = auth.uid());

-- students: beide Stellen dürfen lesen, hinzufügen, bearbeiten, entfernen
drop policy if exists students_select on public.students;
drop policy if exists students_insert on public.students;
drop policy if exists students_update on public.students;
drop policy if exists students_delete on public.students;
create policy students_select on public.students for select to authenticated using (public.my_role() is not null);
create policy students_insert on public.students for insert to authenticated with check (public.my_role() is not null);
create policy students_update on public.students for update to authenticated using (public.my_role() is not null) with check (public.my_role() is not null);
create policy students_delete on public.students for delete to authenticated using (public.my_role() is not null);

-- absences: beide sehen alles, aber jede Stelle bearbeitet NUR ihre eigenen Abmeldungen
drop policy if exists absences_select on public.absences;
drop policy if exists absences_insert on public.absences;
drop policy if exists absences_update on public.absences;
drop policy if exists absences_delete on public.absences;
create policy absences_select on public.absences for select to authenticated using (public.my_role() is not null);
create policy absences_insert on public.absences for insert to authenticated with check (source = public.my_role());
create policy absences_update on public.absences for update to authenticated using (source = public.my_role()) with check (source = public.my_role());
create policy absences_delete on public.absences for delete to authenticated using (source = public.my_role());

-- closed_days: beide Stellen dürfen Tage schliessen / öffnen
drop policy if exists closed_select on public.closed_days;
drop policy if exists closed_insert on public.closed_days;
drop policy if exists closed_update on public.closed_days;
drop policy if exists closed_delete on public.closed_days;
create policy closed_select on public.closed_days for select to authenticated using (public.my_role() is not null);
create policy closed_insert on public.closed_days for insert to authenticated with check (public.my_role() is not null);
create policy closed_update on public.closed_days for update to authenticated using (public.my_role() is not null) with check (public.my_role() is not null);
create policy closed_delete on public.closed_days for delete to authenticated using (public.my_role() is not null);

-- Nicht eingeloggte Besucher erhalten keinerlei Zugriff
revoke all on public.profiles, public.students, public.absences, public.closed_days from anon;

-- ---------- Live-Aktualisierung (Realtime) ----------
do $$
declare t text;
begin
  foreach t in array array['students', 'absences', 'closed_days'] loop
    begin
      execute format('alter publication supabase_realtime add table public.%I', t);
    exception when duplicate_object then null;
    end;
  end loop;
end $$;
