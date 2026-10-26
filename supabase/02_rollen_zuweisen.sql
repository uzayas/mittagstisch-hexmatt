-- ============================================================
--  Registrierungscodes festlegen
--  Codes anpassen (mind. 8 Zeichen, nicht erratbar) und im SQL Editor ausführen.
--  Den Schul-Code nur an die Schule/Lerninsel, den Tischli-Code nur an
--  «Es Tischli für Alli» weitergeben. Wer den Code hat, kann sich registrieren.
-- ============================================================

insert into public.registration_codes (role, code) values
  ('schule',  'Lerninsel-AF9X-7C8K-XVHR'),    -- ← anpassen
  ('tischli', 'Tischli-R48N-QXXP-R7NE')       -- ← anpassen
on conflict (role) do update set code = excluded.code, updated_at = now();


-- ============================================================
--  Nützliche Abfragen für die Verwaltung
--  (einzeln markieren und ausführen)
-- ============================================================

-- Alle registrierten Personen mit Stelle anzeigen
select u.email, p.display_name, p.role, u.created_at, u.last_sign_in_at
from auth.users u
left join public.profiles p on p.id = u.id
order by p.role nulls first, u.email;

-- Code ändern (z.B. wenn er weitergegeben wurde) – bestehende Konten bleiben gültig
-- update public.registration_codes set code = 'Neuer-Code-123', updated_at = now() where role = 'schule';

-- Stelle einer Person ändern
-- update public.profiles set role = 'tischli'
-- where id = (select id from auth.users where email = 'person@example.ch');

-- Einer Person ohne Stelle (z.B. im Dashboard angelegt) eine Stelle geben
-- insert into public.profiles (id, role, display_name)
-- select id, 'schule', 'Vorname Nachname' from auth.users where email = 'person@example.ch'
-- on conflict (id) do update set role = excluded.role;

-- Zugang entziehen: In Supabase unter Authentication → Users die Person löschen
-- (oder nur die Stelle entfernen:)
-- delete from public.profiles where id = (select id from auth.users where email = 'person@example.ch');
