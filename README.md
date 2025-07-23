# WildSound

**Entdecke die Welt der Tiere – durch ihre Stimmen!**

Das spannende Quiz, bei dem du herausfinden musst, welches Tier welchen Laut macht.

WildSound macht Tierwissen zum Erlebnis: Spiele, rate und lerne faszinierende Fakten über Tiere und ihre Stimmen. Perfekt für Kinder, Erwachsene, Tierfreunde, Naturfans und als edukatives Spiel für die ganze Familie.



## Design

**In diesem Moment entsteht gerade eine sehr coole Tierstimmen-Quiz App!** 

**Bilder folgen bald...**


## Features

- [ ] Tierlaute-Quiz: Zu jedem Tier wird ein Ton abgespielt – du musst das passende Tier auswählen!
- [ ] Detailansicht: Zu jedem Tier gibt es spannende Fakten und Bilder aus Wikipedia.
- [ ] Lokale Speicherung des Fortschritts per SwiftData (z. B. erratene Tiere, Favoriten).
- [ ] Nutzung von Firebase Storage für Tierstimmen (MP3).
- [ ] Direkte Nutzung von xeno-canto für Vogelstimmen.
- [ ] Übersicht aller bereits entdeckten Tiere (Sammlung).

## Technischer Aufbau

#### Projektaufbau

- **MVVM-Architektur:**  
  - Model: Animal, QuizState, etc.
  - ViewModel: QuizViewModel, AnimalListViewModel, etc.
  - Views: QuizView, DetailView, CollectionView
    
- **Repositories:**  
  - Für API-Anbindung (Wikipedia, xeno-canto)
  - Für lokale Speicherung (SwiftData)
    
- **Ordnerstruktur:** 
  - Models
  - ViewModels
  - Views
  - Services
  - Resources

#### Audio Widergabe

- Die Tierstimmen werden mit AVFoundation (AVPlayer) direkt aus dem Internet gestreamt oder aus dem Firebase Storage abgespielt.

#### Datenspeicherung

- **Tiere & ihre Grunddaten:** 
  - Gespeichert als Model-Objekte in SwiftData (Name, Sound-URL, wikiTitle etc.).

- **Bilder & Tier Detail Beschreibungen:**
  - Dynamisch zur Laufzeit von der Wikipedia API geladen (Beschreibung, Foto, Details).

- **Tierstimmen:**  
  - Firebase Storage: MP3-Dateien werden von der App per URL geladen
  - Für Vögel: Nutzung der xeno-canto API und MP3-Links.
    
- **Nutzerfortschritt, Favoriten, Highscores:**  
  - Lokal in SwiftData gespeichert.
 
- **Warum genau so?**  
  - **SwiftData**: Modern, Lokal, leicht erweiterbar.
  - **Firebase Storage**: Professioneller Cloud-Speicher für Mediendateien.
  - **xeno-canto**: Legale, große Vogelstimmendatenbank.
  - **Wikipedia-API**: Liefert sehr zuverlässig aktuelle Bilder und Texte zu praktisch jedem Tier.

#### Zentrale Datenlogik

- **Alle wichtigen Datenquellen werden im SwiftData-Model pro Tier gebündelt:**
  - Die App speichert Name, wikiTitle und Sound-URL (Firebase Storage/xeno-canto) in SwiftData
  - Bilder und Tier Details werden live über die Wikipedia API geladen.

#### API Calls

- **Wikipedia REST API (MediaWiki REST API):**  
 - Für Bild und Beschreibung jedes Tieres (über den WikiTitle im Model).
  
- **xeno-canto API:**  
  - Für Vogelstimmen.
  
- **Firebase Storage:**  
  - Für alle anderen Tierstimmen als MP3.


#### 3rd-Party Frameworks

- Firebase SDK für iOS (Swift Package Manager)


## Ausblick

- [ ] Verschiedene Schwierigkeitsgrade und Tierklassen (Vögel, Säugetiere, Reptilien etc.)
- [ ] Mehrsprachigkeit: Tiernamen in mehreren Sprachen auswählbar
- [ ] Belohnungssystem (z. B. Abzeichen)
- [ ] Lokaler Multiplayer-Modus 

