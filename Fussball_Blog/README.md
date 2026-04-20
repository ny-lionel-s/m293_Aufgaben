# Fussball Blog - Projektdokumentation

## Projektübersicht

Dieses Projekt wurde im Rahmen des Moduls `M293` als statischer, responsiver Fussball-Blog umgesetzt. Der Blog behandelt die Top 5 europäischen Ligen sowie die UEFA Champions League und erfüllt die im Projektauftrag geforderten Seitentypen, Inhalte und Dokumentationsbestandteile.

Ziel war ein Webauftritt mit:

- `Startseite` mit neuesten oder beliebtesten Artikeln
- `Artikelübersicht` mit Themenfilter
- `Artikeldetailseiten` mit Text, Bild, Autor:in und optionalem Videobereich
- `Kontaktseite` mit Autoreninformationen und Kontaktformular
- responsivem Verhalten für `Mobile`, `Tablet` und `Desktop`

---

## Projektziele

- Entwicklung eines vollständig responsiven Blogs mit eigenem `HTML`, `CSS` und etwas `JavaScript`
- saubere Seitenstruktur mit `header`, `main` und `footer`
- Grid-Layouts für Themen, Artikelkarten und Inhaltsbereiche
- Umsetzung aller Pflichtpunkte aus dem Projektauftrag
- dokumentierter und reflektierter Einsatz von mindestens zwei KI-Tools

---

## Projektstruktur

```text
Fussball_Blog/
├── index.html
├── artikel.html
├── kontakt.html
├── css/
│   └── styles.css
├── artikel/
│   ├── bayern-klassiker.html
│   ├── barcelona-jugend.html
│   ├── champions-league-favoriten.html
│   ├── champions-league-viertelfinale.html
│   ├── city-titelrennen.html
│   ├── inter-dominanz.html
│   ├── leverkusen-meister.html
│   ├── liverpool-comeback.html
│   ├── marseille-europa.html
│   ├── milan-renaissance.html
│   ├── psg-monaco.html
│   └── real-madrid-form.html
├── images/
│   ├── Wireframe_Startseite_Mobile.png
│   ├── Wireframe_Startseite_Tablet.png
│   ├── Wireframe_Startseite_Desktop.png
│   ├── Wireframe_Artikeluebersicht_Mobile.png
│   ├── Wireframe_Artikeluebersicht_Tablet.png
│   ├── Wireframe_Artikeluebersicht_Desktop.png
│   ├── Wireframe_Artikeldetail_Mobile.png
│   ├── Wireframe_Artikeldetail_Tablet.png
│   ├── Wireframe_Artikeldetail_Desktop.png
│   ├── Wireframe_Kontaktseite_Mobile.png
│   ├── Wireframe_Kontaktseite_Tablet.png
│   └── Wireframe_Kontaktseite_Desktop.png
├── generate-wireframes.ps1
├── WIREFRAMES.md
└── README.md
```

---

## Umgesetzte Seiten

### 1. Startseite

Datei: `index.html`

Umsetzung:

- Hero-Bereich mit Einleitung zum Blog
- Newsletter-Anmeldung auf der Startseite
- Themenübersicht für 6 Wettbewerbe
- Kartenbereich mit aktuellen Artikeln
- klare Navigation zu `Home`, `Artikel` und `Kontakt`

Erfüllter Auftragsbezug:

- beliebteste oder neuste Artikel auf der Startseite
- Übersicht aller Themen
- Newsletter-Anmeldung

### 2. Artikelübersicht

Datei: `artikel.html`

Umsetzung:

- alle Artikel in einer gemeinsamen Übersicht
- Filterbuttons für alle Themenbereiche
- Anzeige aller Artikel oder nur eines bestimmten Themas
- Filterung zusätzlich über URL-Parameter wie `?thema=bundesliga`

Erfüllter Auftragsbezug:

- Themenseite mit allen Artikeln
- Filter nach Thema
- Grid-Layout für Inhalte

### 3. Artikeldetailseiten

Dateien: `artikel/*.html`

Umsetzung:

- 12 kuratierte Artikeldetailseiten
- je Seite: Thema, Titel, Bild, Autor:in, Datum, Lesezeit und Text
- Rücklink zur Artikelübersicht
- Platz für optionalen Videoeinsatz ist im Wireframing berücksichtigt

Erfüllter Auftragsbezug:

- Detailseite mit Artikel, Bild, evtl. Video, Autor:in und Thema

### 4. Kontaktseite

Datei: `kontakt.html`

Umsetzung:

- Vorstellung von 5 Autor:innen mit Foto und Kurzbeschreibung
- Kontaktformular mit:
  - Name
  - E-Mail-Adresse
  - Betreffauswahl per Dropdown
  - Nachricht
- thematisch auswählbare Betreffzeilen

Erfüllter Auftragsbezug:

- Informationen über die Autor:innen
- Kontaktformular
- Dropdown zur Betreffauswahl

---

## Inhaltlicher Umfang

- `3` Hauptseiten: `index.html`, `artikel.html`, `kontakt.html`
- `12` Artikeldetailseiten
- `6` Themenbereiche:
  - Bundesliga
  - Premier League
  - La Liga
  - Serie A
  - Ligue 1
  - Champions League
- `5` Autor:innenprofile

Damit ist die Anforderung `mindestens 3 Hauptseiten` und `mindestens 10 Artikel` erfüllt.

---

## Design & Styleguide

### Farbpalette

```css
--primary-color: #2c5f2d;
--secondary-color: #97bf0d;
--accent-color: #ff6b35;
--dark-bg: #1a1a1a;
--light-bg: #f5f5f5;
--text-dark: #333;
--text-light: #fff;
--border-color: #ddd;
--champions-gold: #ffd700;
```

### Typografie

- Hauptschrift: `Segoe UI`, `Tahoma`, `Geneva`, `Verdana`, `sans-serif`
- Basis-Schriftgrösse: `16px`
- Zeilenhöhe: `1.6`
- klare Hierarchie für `h1`, `h2` und `h3`

### Layout-Prinzipien

- `Mobile First` als Grundidee
- `CSS Grid` für Kartenraster und grössere Inhaltsbereiche
- `Flexbox` für Navigation, Formulare und kleinere Komponenten
- Breakpoints:
  - Mobile: bis `480px`
  - Tablet: `481px - 768px`
  - Desktop: ab `769px`

---

## Responsive Umsetzung

### Mobile

- vertikale oder kompakte Navigation
- einspaltige Artikelkarten
- gestapelte Formulare
- klare Leseführung ohne Seitwärts-Scrollen

### Tablet

- breiteres Raster für Themen und Artikel
- mehrspaltige Bereiche bei ausreichend Platz
- bessere Ausnutzung der verfügbaren Breite

### Desktop

- horizontale Navigation
- mehrspaltige Artikelgrids
- grosszügigere Inhalte und klarer Seitenaufbau

---

## Technische Umsetzung

### HTML

- semantische Struktur mit `header`, `nav`, `main`, `section`, `article`, `footer`
- formulargerechte Eingabefelder und Labels
- sprechende Linkstruktur zwischen Seiten und Detailartikeln

### CSS

- zentrale Gestaltung in `css/styles.css`
- Variablen für Farben und wiederkehrende Werte
- Grid- und Flexbox-Layouts
- Hover- und Übergangseffekte
- Media Queries für verschiedene Bildschirmbreiten

### JavaScript

Einsatz auf `artikel.html`:

- Event-Listener für Filterbuttons
- Filterung über `data-category`
- Auswertung von URL-Parametern

---

## Wireframes

Die im Projektauftrag geforderten Wireframes sind vollständig vorhanden.

### Erzeugte Wireframes

#### Startseite
- `images/Wireframe_Startseite_Mobile.png`
- `images/Wireframe_Startseite_Tablet.png`
- `images/Wireframe_Startseite_Desktop.png`

#### Artikelübersicht
- `images/Wireframe_Artikeluebersicht_Mobile.png`
- `images/Wireframe_Artikeluebersicht_Tablet.png`
- `images/Wireframe_Artikeluebersicht_Desktop.png`

#### Artikeldetail
- `images/Wireframe_Artikeldetail_Mobile.png`
- `images/Wireframe_Artikeldetail_Tablet.png`
- `images/Wireframe_Artikeldetail_Desktop.png`

#### Kontaktseite
- `images/Wireframe_Kontaktseite_Mobile.png`
- `images/Wireframe_Kontaktseite_Tablet.png`
- `images/Wireframe_Kontaktseite_Desktop.png`

Zusätzliche Dokumentation:

- `WIREFRAMES.md`
- `generate-wireframes.ps1`

---

## KI-Einsatz in der Entwicklung

Der Projektauftrag verlangt den dokumentierten Einsatz von mindestens zwei KI-Tools. Für dieses Projekt wurden `Codex` und `ChatGPT` verwendet.

### KI-Tool 1: Codex

Einsatzbereiche:

- Analyse der bestehenden Projektstruktur
- Überarbeitung und Ergänzung von HTML-, CSS- und JavaScript-Dateien
- Prüfung der Auftragsabdeckung
- Erstellung und Generierung der Wireframes
- Bereinigung und Aktualisierung der Projektdokumentation

Beispiele:

- Anpassung der Seitenstruktur an den Projektauftrag
- Erstellung der Wireframes für alle Seitentypen und Gerätegrössen
- Überprüfung, welche Assets im Projekt noch verwendet werden

### KI-Tool 2: ChatGPT

Einsatzbereiche:

- Ideenfindung für Inhalt, Aufbau und Formulierungen
- Unterstützung bei Texten für Artikelideen, Seitentexte und Dokumentation
- Reflexion über Designentscheidungen und Seitenlogik
- Hilfe bei der Strukturierung der README-Dokumentation

Beispiele:

- Ausformulierung von Beschreibungen und Abschnitten
- Vergleich von Umsetzungsvarianten
- sprachliche Vereinfachung und bessere Gliederung

### Wofür KI konkret eingesetzt wurde

Laut Auftrag sollte KI für `Layout`, `Codevorschläge` und `UI-Optimierungen` eingesetzt werden. Das wurde wie folgt umgesetzt:

- Layout:
  - Seitenaufbau für Startseite, Artikelübersicht, Detailseite und Kontaktseite
  - Wireframe-Struktur für Mobile, Tablet und Desktop
- Codevorschläge:
  - Struktur für Karten, Filter und Formularbereiche
  - Verbesserungen an HTML- und CSS-Abschnitten
- UI-Optimierungen:
  - klarere Hero-Bereiche
  - bessere visuelle Hierarchien
  - konsistentere Karten- und Formularlogik

---

## Vergleich der KI-Tools

| Kriterium | Codex | ChatGPT |
|-----------|-------|---------|
| Codeänderungen direkt im Projekt | Sehr stark | Mittel |
| Analyse bestehender Dateien | Sehr stark | Gut |
| Textliche Dokumentation | Gut | Sehr stark |
| Hilfe bei Struktur und Ideen | Gut | Sehr stark |
| Iterative technische Anpassungen | Sehr stark | Gut |
| Geeignet für dieses Projekt | Sehr hoch | Hoch |

### Fazit zum Vergleich

- `Codex` war besonders stark bei konkreten Projektänderungen, Codeanpassungen und der Wireframe-Erstellung.
- `ChatGPT` war besonders hilfreich bei Formulierungen, Strukturierung und konzeptioneller Unterstützung.
- Die Kombination aus beiden Tools war sinnvoll, weil eines stärker im Code und eines stärker in Sprache und Struktur war.

---

## Erfüllung des Projektauftrags

| Anforderung aus dem Auftrag | Status | Umsetzung im Projekt |
|---|---|---|
| Blog zu einem frei gewählten Thema | Erfüllt | Fussball-Blog mit 6 Themenbereichen |
| Mindestens 2 KI-Tools einsetzen und vergleichen | Erfüllt | Codex und ChatGPT dokumentiert und verglichen |
| Startseite mit neuesten oder beliebtesten Artikeln | Erfüllt | `index.html` mit Artikelkarten |
| Übersicht aller Themen auf der Startseite | Erfüllt | Themenkarten auf `index.html` |
| Newsletter-Anmeldung | Erfüllt | Formular auf der Startseite |
| Themenseite mit allen Artikeln | Erfüllt | `artikel.html` |
| Anzeige aller Artikel oder eines Themas | Erfüllt | Filterbuttons und URL-Parameter |
| Detailseite mit Artikel, Bild, evtl. Video, Autor:in und Thema | Erfüllt | 12 Detailseiten, Video im Wireframing berücksichtigt |
| Kontaktseite mit Autoreninformationen | Erfüllt | `kontakt.html` mit 5 Autor:innen |
| Kontaktformular mit Betreffauswahl | Erfüllt | Dropdown in `kontakt.html` |
| 100% eigener HTML- und CSS-Code | Erfüllt | Kein Framework, eigener Code in HTML/CSS |
| Seitenstruktur mit Header, Main und Footer | Erfüllt | auf allen Hauptseiten vorhanden |
| Grid-Layout für Artikelübersicht und Inhalte | Erfüllt | Kartenraster und Layoutbereiche mit CSS Grid |
| Formulare für Newsletter und Kontakt | Erfüllt | beide vorhanden |
| Responsives Design für Mobile, Tablet und Desktop | Erfüllt | Breakpoints und responsive Layoutlogik vorhanden |
| Mindestens 3 Hauptseiten | Erfüllt | `index.html`, `artikel.html`, `kontakt.html` |
| Mindestens 10 Artikel | Erfüllt | 12 Artikel vorhanden |
| Wireframes in Git/Markdown | Erfüllt | 12 PNGs, `WIREFRAMES.md`, `generate-wireframes.ps1` |
| Styleguide mit Typografie und Farben | Erfüllt | in diesem README dokumentiert |
| Dokumentation des KI-Einsatzes | Erfüllt | in diesem README dokumentiert |

### Optionales

| Optionaler Punkt | Status | Hinweis |
|---|---|---|
| Kommentarfunktion | Nicht umgesetzt | nicht Teil des aktuellen Umfangs |
| Likes mit Web Storage API | Nicht umgesetzt | nicht Teil des aktuellen Umfangs |

---

## Lokale Verwendung

```bash
# Projekt öffnen
cd Fussball_Blog

# index.html direkt im Browser öffnen
# oder mit einem Live-Server starten
```

---

## Veröffentlichung

Für die Abgabe werden laut Auftrag benötigt:

- Link zum publizierten Webauftritt, z. B. über `GitHub Pages`
- Link zum öffentlichen Git-Repository mit Quellcode und Dokumentation

Mögliche Veröffentlichungsplattformen:

- `GitHub Pages`
- `Netlify`
- `Vercel`

---

## Reflexion

### Technische Erkenntnisse

- Ein sauberes Kartenlayout lässt sich mit `CSS Grid` gut skalieren.
- `Flexbox` und `Grid` ergänzen sich sinnvoll.
- Responsive Design muss auf Inhaltslogik und nicht nur auf Bildschirmbreite reagieren.
- Ein konsistentes Komponentenmodell vereinfacht spätere Erweiterungen.

### Erkenntnisse zum KI-Einsatz

- KI spart Zeit bei Struktur, Überarbeitung und Variantenbildung.
- Die Vorschläge müssen immer geprüft und an den konkreten Auftrag angepasst werden.
- Besonders bei Dokumentation und Layoutentscheidungen hilft iteratives Arbeiten.
- Für ein gutes Ergebnis bleibt die fachliche Kontrolle durch die entwickelnde Person notwendig.

---

## Autor & Credits

**Projekt:** Fussball Blog - M293 Projektauftrag  
**Umsetzung:** mit Unterstützung durch Codex und ChatGPT  
**Entwicklungszeit:** März bis April 2026  
**Lizenz:** Educational Project

---

## Stand

**Version:** 1.1  
**Stand:** April 2026  
**Status:** Projekt dokumentiert und auftragskonform aufbereitet
