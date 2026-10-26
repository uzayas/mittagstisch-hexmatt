// ============================================================
//  Konfiguration – Mittagstisch Sekundarschule Pratteln
// ============================================================
//  Leer gelassen (SUPABASE_URL = "") läuft die App im DEMO-MODUS:
//  Daten werden nur im eigenen Browser gespeichert (zum Ausprobieren).
//
//  Für den echten Betrieb: Werte aus Supabase eintragen
//  (Project Settings → API → Project URL und anon / publishable key).
//  Der anon-Key darf öffentlich sein – der Schutz erfolgt über Login + RLS.
// ============================================================

window.APP_CONFIG = {
  SUPABASE_URL: "https://rhdgsjffbumreselepmt.supabase.co",
  SUPABASE_ANON_KEY: "sb_publishable_9Myuc2jNiMM7k7xau6IfyA_R3ya6f94",

  TITLE: "Mittagstisch Sekundarschule Pratteln",

  // Angezeigte Wochentage im Kalender (1 = Montag … 5 = Freitag)
  DAYS: [1, 2, 3, 4, 5],

  // Standard-Anmeldetage für neue Schüler/innen
  DEFAULT_DAYS: [1, 2, 4, 5],

  // Schnellauswahl für die Bemerkungsspalte (werden auch in der Tageszählung ausgewertet)
  REMARK_PRESETS: ["vegetarisch", "vegan", "ohne Schweinefleisch", "laktosefrei", "glutenfrei"]
};
