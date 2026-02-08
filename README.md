# WildSound

**Entdecke die Welt der Tiere – durch ihre Stimmen!**

WildSound ist eine iOS SwiftUI-Lern- und Quiz-App, bei der Tierstimmen erkannt werden müssen.

Die App verbindet Spielmechanik mit Wissensvermittlung:  
Zu jedem Tier wird ein echter Tierlaut abgespielt, und der Spieler muss das passende Tier auswählen.  
Anschließend werden automatisch Bilder und Kurzbeschreibungen aus Wikipedia geladen.

Der Fokus des Projekts liegt weniger auf einem statischen Quiz, sondern auf einer dynamisch erweiterbaren Architektur:
Neue Tiere können über einen integrierten Admin-Bereich hinzugefügt werden, ohne dass die App neu veröffentlicht werden muss.

Die Kerndaten der Tiere werden serverseitig in einer Cloud-Datenbank verwaltet und beim Start der App synchronisiert.  
Ergänzende Inhalte wie Bilder und Beschreibungen werden zusätzlich zur Laufzeit aus externen Quellen (Wikipedia) geladen, während die Audiodateien aus einem Cloud-Speicher gestreamt werden.

Das Projekt entstand im Rahmen der App-Developer-Ausbildung am Syntax Institut und wurde als eigenständig konzipiertes Abschlussprojekt umgesetzt.  
Es demonstriert den Aufbau einer datengetriebenen SwiftUI-App mit Cloud-Backend, lokaler Persistenz und inkrementeller Synchronisation.

Das Repository dient als Demonstrations- und Portfolio-Projekt.  
Es enthält bewusst keine Produktionsdaten oder privaten Zugangsdaten.  
Die veröffentlichte Version stellt den App-Client dar, während Inhalte und Medien über eine separate Firebase-Instanz bereitgestellt werden.


## Design

<img width="200" alt="Simulator Screenshot - iPhone 16 Pro - 2025-09-03 at 09 39 26-portrait" src="https://github.com/user-attachments/assets/a55abc2b-9565-4dcc-9325-465feeb64680" />
<img width="200" alt="Simulator Screenshot - iPhone 16 Pro - 2025-09-03 at 09 47 17-portrait" src="https://github.com/user-attachments/assets/812c5f8f-bffd-4aca-b214-7295cde01385" />
<img width="200" alt="Simulator Screenshot - iPhone 16 Pro - 2025-09-03 at 09 41 04-portrait" src="https://github.com/user-attachments/assets/435e2c98-a8c9-472d-87db-8c779cf69746" />
<img width="200" alt="Simulator Screenshot - iPhone 16 Pro - 2025-09-03 at 10 03 57-portrait" src="https://github.com/user-attachments/assets/adb5d339-419c-4bed-a297-03635c09b890" />


## Verwendete Technologien

- Swift & SwiftUI
- MVVM-Architektur
- SwiftData (lokale Persistenz)
- Firebase Authentication
- Firebase Firestore (Inhalts-Synchronisation)
- Firebase Storage (Audiodateien)
- Wikipedia REST API (Bilder & Beschreibungen)
- AVFoundation (Audiowiedergabe)


## Features

- Tierlaute-Quiz: Zu jedem Tier wird ein echter Tierlaut abgespielt, und das passende Tier muss ausgewählt werden.
- Tier-Detailansicht mit automatisch geladenen Bildern und Beschreibungen aus Wikipedia (DE mit EN-Fallback).
- Sammlung aller entdeckten Tiere mit Filteroptionen (Alle / Erraten / Favoriten).
- Favoritenfunktion und Fortschrittsverfolgung.
- Globaler Highscore mit Reset-Option.
- Lokale Datenspeicherung über SwiftData (Fortschritt bleibt erhalten).
- Admin-Bereich zum Hinzufügen und Aktualisieren von Tieren ohne App-Update.


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
 
## Technische Herausforderungen & Lösungen

Während der Entwicklung traten mehrere typische Probleme moderner App-Architekturen auf, die gezielt gelöst wurden:

**Asynchrone Datenquellen (Firestore + Wikipedia + Storage)**  
Die App kombiniert drei voneinander unabhängige externe Datenquellen.  
Um Inkonsistenzen zu vermeiden, wurde ein lokaler Zwischenspeicher (SwiftData) eingeführt.  
Die App arbeitet primär mit lokalen Daten und synchronisiert diese im Hintergrund inkrementell.

**Offlinefähigkeit & Performance**  
Da Bilder, Texte und Audiodateien aus dem Internet geladen werden, könnten Ladezeiten oder Verbindungsprobleme das Spielerlebnis stören.  
Durch lokale Speicherung bereits geladener Tiere (SwiftData) kann das Quiz auch ohne aktive Internetverbindung weitergespielt werden.

**Stabile Identifikation von Tieren**  
Anstatt Tiere über ihren Namen zu identifizieren (fehleranfällig durch Übersetzungen), wird der `storagePath` im Firebase Storage als eindeutige technische ID verwendet.  
Dadurch bleiben Updates, Umbenennungen oder Übersetzungen stabil kompatibel.

**Admin-System ohne eigenes Backend-Serverhosting**  
Ein klassischer eigener Server wurde bewusst vermieden.  
Stattdessen übernimmt Firebase Authentication die Benutzerverwaltung, während Firestore über Security Rules entscheidet, wer Schreibrechte besitzt.  
Die App prüft beim Login, ob die UID in der Firestore-Collection `admins` existiert und schaltet nur dann den Admin-Bereich frei.

**Sicherheit öffentlicher Repositories**  
Da das Projekt öffentlich auf GitHub liegt, werden keine Zugangsdaten im Repository gespeichert.  
Die Firebase-Konfigurationsdatei (`GoogleService-Info.plist`) wird lokal verwendet und bewusst nicht versioniert.


#### Audiowiedergabe

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

- **Wikipedia API:**  
  - Liefert Bilder und Kurzbeschreibungen zu den Tieren (DE mit EN-Fallback).

- **Firebase Storage:**  
  - Für MP3-Downloads (Signierte Download-URL zur Laufzeit).

#### 3rd-Party Frameworks

  - Firebase SDK für iOS (Auth, Firestore, Storage) – über Swift Package Manager

## Lokales Ausführen des Projekts (Firebase-Konfiguration erforderlich)

Dieses Projekt verwendet Firebase (Authentication, Firestore und Storage) als Backend für Inhalte und den Admin-Bereich.

Aus Sicherheitsgründen ist die Konfigurationsdatei **`GoogleService-Info.plist` nicht im Repository enthalten**.

Die App kann ohne Firebase kompiliert und gestartet werden, läuft dann jedoch im Demo-Modus ohne Inhalte.  
Das bedeutet: Die Benutzeroberfläche und Spiellogik sind funktionsfähig, jedoch werden keine Tiere, Bilder oder Audiodateien geladen und der Admin-Bereich ist nicht verfügbar.


### Eigene Firebase-Instanz einrichten

Um das Projekt vollständig lokal nutzen zu können, muss eine eigene Firebase-Instanz erstellt werden:

1. Firebase-Projekt erstellen  
   https://console.firebase.google.com

2. Eine iOS-App hinzufügen mit der Bundle-ID:
   `de.micksch.WildSound`

3. Die Datei `GoogleService-Info.plist` herunterladen

4. Datei in Xcode in den Ordner `WildSound/WildSound/` ziehen  
   (Target „WildSound“ aktivieren, nicht committen)

5. In Firebase aktivieren:
   - Authentication (E-Mail/Passwort)
   - Firestore Database
   - Storage

### Admin-Bereich

Der Admin-Bereich basiert auf Firebase Authentication und einem Admin-Flag in Firestore.

Nach dem Erstellen eines Users muss dieser in Firestore manuell als Admin eingetragen werden:  
Collection: `admins`  
Dokument-ID = UID des Benutzers

Erst danach ist der Admin-Bereich innerhalb der App zugänglich.

Hinweis:  
Dieses Repository enthält bewusst **keine Produktionsdaten, Audiodateien oder Zugangsdaten**.


## Ausblick

- [ ] Verschiedene Schwierigkeitsgrade und Tierklassen (Vögel, Säugetiere, Reptilien etc.)
- [ ] Mehrsprachigkeit: Tiernamen in mehreren Sprachen auswählbar
- [ ] Belohnungssystem (z. B. Abzeichen)
- [ ] Lokaler Multiplayer-Modus 

