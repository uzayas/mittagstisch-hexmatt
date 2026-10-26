-- ============================================================
--  Rollen zuweisen
--  ZUERST die Benutzer anlegen: Authentication → Users → «Add user»
--  (E-Mail + Passwort, «Auto Confirm User» anhaken).
--  Danach hier die E-Mail-Adressen anpassen und ausführen.
-- ============================================================

-- Schule / Lerninsel
insert into public.profiles (id, role, display_name)
select id, 'schule', 'Schule / Lerninsel'
from auth.users
where email = 'lerninsel@example.ch'          -- ← anpassen
on conflict (id) do update set role = excluded.role, display_name = excluded.display_name;

-- Es Tischli für Alli
insert into public.profiles (id, role, display_name)
select id, 'tischli', 'Es Tischli für Alli'
from auth.users
where email = 'tischli@example.ch'            -- ← anpassen
on conflict (id) do update set role = excluded.role, display_name = excluded.display_name;

-- Weitere Personen: Block kopieren und E-Mail / Rolle anpassen.

-- Kontrolle:
select u.email, p.role, p.display_name
from public.profiles p join auth.users u on u.id = p.id
order by p.role, u.email;
