# WildSound

**Entdecke die Welt der Tiere – durch ihre Stimmen!**

Das spannende Quiz, bei dem du herausfinden musst, welches Tier welchen Laut macht.

WildSound macht Tierwissen zum Erlebnis: Spiele, rate und lerne faszinierende Fakten über Tiere und ihre Stimmen. Perfekt für Kinder, Erwachsene, Tierfreunde, Naturfans und als edukatives Spiel für die ganze Familie.

## Design

<img width="200" alt="Simulator Screenshot - iPhone 16 Pro - 2025-09-03 at 09 39 26-portrait" src="https://github.com/user-attachments/assets/a55abc2b-9565-4dcc-9325-465feeb64680" />
<img width="200" alt="Simulator Screenshot - iPhone 16 Pro - 2025-09-03 at 09 47 17-portrait" src="https://github.com/user-attachments/assets/812c5f8f-bffd-4aca-b214-7295cde01385" />
<img width="200" alt="Simulator Screenshot - iPhone 16 Pro - 2025-09-03 at 09 41 04-portrait" src="https://github.com/user-attachments/assets/435e2c98-a8c9-472d-87db-8c779cf69746" />
<img width="200" alt="Simulator Screenshot - iPhone 16 Pro - 2025-09-03 at 10 03 57-portrait" src="https://github.com/user-attachments/assets/adb5d339-419c-4bed-a297-03635c09b890" />





## Features

- [ ] Tierlaute-Quiz: Zu jedem Tier wird ein Ton abgespielt – du musst das passende Tier auswählen!
- [ ] Detailansicht: Zu jedem Tier gibt es spannende Fakten und Bilder aus Wikipedia (DE mit EN-Fallback).
- [ ] Lokale Speicherung des Fortschritts per SwiftData (z. B. erratene Tiere, Favoriten).
- [ ] Nutzung von Firebase Storage für Tierstimmen (MP3).
- [ ] Übersicht aller bereits entdeckten Tiere (Sammlung) mit Filtern (Alle/Erraten/Favoriten).
- [ ] Globaler Highscore (SwiftData) mit Reset-Option.
- [ ] Admin-Login (Firebase Auth) und Admin-Bereich zum schnellen Hinzufügen/Ändern von Tieren.

## Technischer Aufbau

#### Projektaufbau

- **MVVM-Architektur:**  
  - Models: Animal, QuizState, AppStats
  - ViewModels: QuizViewModel, CollectionsViewModel, AnimalDetailViewModel, ResultsViewModel, AuthViewModel, AdminQuickAddViewModel
  - Views: QuizGridView, AnimalDetailView, CollectionsView, QuizResultsView, AdminQuickAddView, StartView, RootContainerView
    
- **Repositories:**  
  - Wikipedia-Anbindung (REST Page Summary)
  - SwiftData (lokale Speicherung)
  - Firebase Storage (Audio laden)
  - Firebase Firestore (Daten-Sync inkl. Admin-Flag & Änderungszeitpunkten)
    
- **Ordnerstruktur:** 
  - Models
  - ViewModels
  - Views
  - Services
  - Resources

#### Audio Widergabe

- Die Tierstimmen liegen als MP3 im Firebase Storage.
- Playback erfolgt mit AVPlayer; die App lädt zur Laufzeit die Download-URL aus dem Storage und spielt von dort ab.

#### Datenspeicherung

- **Tiere & ihre Grunddaten:** 
  - Gespeichert als Model-Objekte in SwiftData (z. B. Name, storagePath als Pfad im Firebase Storage, wikiTitleDe, optional wikiTitleEn, isFavorite, guessedCount, imageCrop, soundSource).

- **Bilder & Tier Detail Beschreibungen:**
  - Dynamisch zur Laufzeit über die MediaWiki REST API (Page Summary).
  - Fallback: Falls ein DE-Eintrag fehlt, wird EN genutzt.
  - Bilder werden über die im Summary enthaltenen Bild-URLs (Wikimedia Commons) angezeigt.

- **Tierstimmen:**  
  - Quelle: Firebase Storage (MP3).
  - Hinweis: Es gibt keinen direkten xeno-canto API-Abruf; xeno-canto/freesound dienen lediglich als Herkunfts-Metadatum.
    
- **Nutzerfortschritt, Favoriten, Highscores:**  
  - Lokal in SwiftData gespeichert (u. a. globaler Highscore über AppStats).

- **Warum genau so?**  
  - **SwiftData:** Modern, Lokal, erweiterbar.
  - **Firebase Storage:** Professioneller Cloud-Speicher für Mediendateien.
  - **Wikipedia-API:** Liefert sehr zuverlässig aktuelle Bilder und Texte zu praktisch jedem Tier.
  - **Firestore:** Synchronisiert Inhalte & Admin-Status; Änderungen werden effizient inkrementell geladen.

#### Zentrale Datenlogik

- **Alle wichtigen Datenquellen werden im SwiftData-Model pro Tier gebündelt:**
  - Die App speichert Name, storagePath (anstelle einer direkten Sound-URL), Wiki-Titel u. a. lokal.
  - Bilder und Tier Details werden live über die Wikipedia API geladen.

- **Sync-Logik (Firestore):**
  - Inkrementeller Import: Bei App-Start werden nur Datensätze seit dem letzten Sync-Zeitpunkt geladen (lastSync), anhand eines Änderungs-Zeitstempels.
  - Upsert-Strategie: Abgleich erfolgt stabil über den storagePath.
 
#### API Calls

- **Wikipedia REST API (MediaWiki Page Summary):**  
  - Für Kurzbeschreibung & Bild-URL pro Tier (DE mit EN-Fallback).

- **Firebase Storage:**  
  - Für MP3-Downloads (Signierte Download-URL zur Laufzeit).

#### 3rd-Party Frameworks

  - Firebase SDK für iOS (Auth, Firestore, Storage) – über Swift Package Manager


## Ausblick

- [ ] Verschiedene Schwierigkeitsgrade und Tierklassen (Vögel, Säugetiere, Reptilien etc.)
- [ ] Mehrsprachigkeit: Tiernamen in mehreren Sprachen auswählbar
- [ ] Belohnungssystem (z. B. Abzeichen)
- [ ] Lokaler Multiplayer-Modus 

