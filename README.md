# Mittagstisch Sekundarschule Pratteln

Webapp im Kalenderprinzip für den Mittagstisch. Zwei Stellen arbeiten gemeinsam darin:

| Stelle | Kürzel im Kalender | Darf |
|---|---|---|
| **Schule / Lerninsel** | **S** (blau) | Schüler/innen verwalten, eigene Abmeldungen erfassen/aufheben, Tage schliessen |
| **Es Tischli für Alli** | **T** (orange) | Schüler/innen verwalten, eigene Abmeldungen erfassen/aufheben, Tage schliessen |

Beide sehen alle Abmeldungen, aber jede Stelle kann **nur ihre eigenen** Abmeldungen ändern (in der Datenbank per Row Level Security abgesichert).

## Funktionen

- **Wochenkalender** (Mo–Fr) mit allen Schüler/innen, gruppiert nach Klasse, Wochenwechsel und Datumssprung
- **Schüler/innen hinzufügen / bearbeiten / entfernen** – Entfernte landen im Archiv (wiederherstellen oder endgültig löschen)
- **Anmeldetage pro Schüler/in** (z.B. nur Mo, Di, Do)
- **Abmelden durch Schule/Lerninsel** und **durch Es Tischli für Alli** – getrennt, je mit Grund, auch für mehrere Tage am Stück
- **Ganze Klasse abmelden** (Exkursion, Lager, Projekttage)
- **Bemerkungsspalte** (vegan, vegetarisch, ohne Schweinefleisch …) mit Schnellauswahl
- **Tageszählung**: Anzahl Essen pro Tag inkl. Aufschlüsselung (z.B. «3 vegetarisch · 1 vegan»)
- **Tagesliste drucken** für die Küche (mit Abhakspalte und Liste der Abgemeldeten)
- **Tage ohne Mittagstisch** markieren (Ferien, Feiertage)
- **Live-Aktualisierung**: Änderungen der anderen Stelle erscheinen automatisch

## Dateien

```
index.html          Seite
styles.css          Gestaltung
config.js           ← Supabase-Zugang eintragen
store.js            Datenzugriff (Supabase oder Demo)
app.js              App-Logik
supabase/
  01_schema.sql              Tabellen, Berechtigungen, Selbstregistrierung
  02_registrierungscodes.sql Codes festlegen + Verwaltungs-Abfragen
```

---

## 0. Zuerst ausprobieren (Demo-Modus)

Ohne Einrichtung lauffähig: `index.html` im Browser öffnen (Doppelklick) oder in VS Code mit «Live Server».
Solange in `config.js` keine Supabase-Daten stehen, läuft die App im **Demo-Modus** mit Beispieldaten,
gespeichert nur im eigenen Browser. Beim Start wählt man die Rolle per Knopf.

---

## Schritt-für-Schritt: Echtbetrieb einrichten

### 1. Supabase-Projekt erstellen
1. Auf <https://supabase.com> anmelden → **New project**.
2. Name z.B. `mittagstisch-pratteln`, sicheres Datenbank-Passwort, **Region in Europa** wählen (z.B. Frankfurt; Zürich, falls angeboten).
3. Warten, bis das Projekt bereit ist.

### 2. Datenbank anlegen
1. Links **SQL Editor** → **New query**.
2. Inhalt von `supabase/01_schema.sql` einfügen → **Run**.
3. Unter **Table Editor** sollten nun `profiles`, `students`, `absences`, `closed_days` erscheinen.

### 3. Registrierungscodes festlegen
Alle registrieren sich selbst. Damit nicht jede beliebige Person Zugriff erhält, braucht es bei der Registrierung einen **Registrierungscode** – einen für die Schule/Lerninsel, einen für Es Tischli für Alli. Der Code bestimmt automatisch die Stelle.

1. `supabase/02_registrierungscodes.sql` öffnen und die beiden Codes ändern (mind. 8 Zeichen, nicht erratbar, z.B. `Lerninsel-Herbst26-7Q4`).
2. Im **SQL Editor** ausführen.
3. Den Schul-Code nur intern an der Schule/Lerninsel weitergeben, den Tischli-Code nur an Es Tischli für Alli.

Mit falschem Code wird **kein Konto** angelegt (das prüft die Datenbank selbst).

### 4. Registrierung in Supabase einschalten
**Authentication → Sign In / Providers** (bzw. *Settings*):
- **«Allow new users to sign up»** → **eingeschaltet**
- **Email** als Provider aktiv lassen
- **«Confirm email»** → **ausschalten** (empfohlen)

> **Warum «Confirm email» ausschalten?** Der eingebaute E-Mail-Versand von Supabase ist im Gratis-Plan stark eingeschränkt (nur sehr wenige E-Mails pro Stunde, teils nur an Mitglieder des Supabase-Teams). Bestätigungs-E-Mails kommen deshalb oft nicht an. Der Registrierungscode schützt den Zugang bereits.
> Wer die E-Mail-Bestätigung trotzdem möchte: unter **Project Settings → Authentication → SMTP Settings** einen eigenen E-Mail-Server (z.B. Microsoft 365 oder Brevo) eintragen. Die App zeigt nach der Registrierung dann automatisch den Hinweis «Bitte E-Mail bestätigen».

### 5. Passwort-Regeln (optional)
**Authentication → Sign In / Providers → Email → Minimum password length** auf **8** setzen (die App verlangt bereits 8 Zeichen).

### 6. App mit Supabase verbinden
1. **Project Settings → API** (bzw. *Data API* / *API Keys*).
2. **Project URL** und den **anon / publishable key** kopieren.
3. In `config.js` eintragen:
   ```js
   SUPABASE_URL: "https://xxxxxxxx.supabase.co",
   SUPABASE_ANON_KEY: "eyJhbGciOi...",
   ```
   ⚠️ Niemals den **service_role / secret key** eintragen – der anon-Key ist für den Browser gedacht und durch Login + RLS geschützt.

### 7. Lokal testen
1. `index.html` öffnen → Reiter **«Registrieren»** → Name, E-Mail, Passwort und den **Schul-Code** eingeben → «Konto erstellen».
2. Im zweiten Browser (oder privatem Fenster) ein Konto mit dem **Tischli-Code** registrieren.
3. Prüfen: Oben steht die richtige Stelle, und Abmeldungen der einen Stelle erscheinen live bei der anderen.
4. Zur Kontrolle einmal mit einem **falschen Code** registrieren → es muss «Der Registrierungscode ist ungültig» erscheinen.

### 8. Auf GitHub Pages veröffentlichen
1. Auf GitHub ein **neues Repository** erstellen, z.B. `mittagstisch-pratteln`.
2. **Add file → Upload files** → alle Dateien und den Ordner `supabase` hochladen → **Commit changes**.
   (Oder per VS Code / Git: `git init`, `git add .`, `git commit -m "Mittagstisch"`, `git push`.)
3. Im Repository: **Settings → Pages** → *Source*: **Deploy from a branch** → Branch **main**, Ordner **/ (root)** → **Save**.
4. Nach 1–2 Minuten ist die App erreichbar unter
   `https://<github-benutzername>.github.io/mittagstisch-pratteln/`

### 9. Supabase-Adresse eintragen (empfohlen)
**Authentication → URL Configuration → Site URL** auf die GitHub-Pages-Adresse setzen.

---

## Bedienung

| Aktion | So geht's |
|---|---|
| Schüler/in abmelden | Grünen Punkt im Kalender anklicken → Grund (optional) → «Abmelden». Mit «Bis und mit» für mehrere Tage. |
| Wieder anmelden | Feld mit eigenem Kürzel (S oder T, umrandet) anklicken → «Wieder anmelden» |
| Schüler/in bearbeiten / entfernen | Auf den Namen klicken |
| Ganze Klasse abmelden | Knopf «Klasse abmelden» |
| Tagesliste drucken | Auf den Tag im Kopf der Tabelle klicken → «Tagesliste drucken» |
| Ferien / kein Mittagstisch | Auf den Tag klicken → Grund → «Tag schliessen» |

Ein Schüler zählt an einem Tag als «isst mit», wenn der Tag ein Anmeldetag ist, der Tag nicht geschlossen ist und **keine** der beiden Stellen abgemeldet hat.

## Anpassen

In `config.js`:
- `DAYS` – welche Wochentage im Kalender angezeigt werden
- `DEFAULT_DAYS` – vorausgewählte Anmeldetage für neue Schüler/innen
- `REMARK_PRESETS` – Schnellauswahl der Bemerkungen (werden auch in der Tageszählung ausgewertet)

## Wichtige Hinweise

- **Datenschutz:** Es werden Personendaten von Schüler/innen gespeichert. Den Einsatz vorgängig mit der Schulleitung bzw. der zuständigen Stelle für Datenschutz abklären. Nur nötige Angaben in die Bemerkung schreiben. Im GitHub-Repository liegen **keine** Schülerdaten – diese sind nur in Supabase.
- **Gratis-Plan von Supabase:** Projekte werden nach ca. 7 Tagen ohne Aktivität pausiert (z.B. in den Ferien). Dann im Supabase-Dashboard auf **Restore** klicken – die Daten bleiben erhalten.
- **Passwort vergessen:** In Supabase unter **Authentication → Users** bei der Person ein neues Passwort setzen.
- **Code weitergegeben / Person verlässt die Stelle:** Code in `02_registrierungscodes.sql` ändern und neu ausführen (bestehende Konten bleiben gültig). Einzelne Personen unter **Authentication → Users** löschen. Weitere Verwaltungs-Abfragen stehen in derselben Datei.
- **Konto ohne Stelle:** Wird ein Benutzer direkt im Supabase-Dashboard (ohne Code) angelegt, sieht er keine Daten, bis ihm eine Stelle zugewiesen wird (Abfrage in `02_registrierungscodes.sql`).
