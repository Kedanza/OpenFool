# OpenFool zu Love2D Migration - Implementierungsplan

Branch: `love2d-implementation`

## 📋 Übersicht

Systematische Migration der OpenFool Kotlin/libGDX Implementierung zu Lua/Love2D basierend auf der Translation Guide.

## 🎯 Phase 1: Foundation (Kritischer Pfad)

### Issue #1: Core Data Structures Migration
**Priority:** CRITICAL ⭐⭐⭐⭐⭐  
**Abhängigkeiten:** Keine  
**Geschätzte Zeit:** 4-6 Stunden

**Beschreibung:**
Migration der grundlegenden Datenstrukturen von Kotlin zu Lua:
- Suit enum → Lua table
- Rank enum → Lua table  
- Card class → Lua factory function
- Basic card comparison logic (beats function)

**Akzeptanzkriterien:**
- [ ] Suit enum als Lua table implementiert
- [ ] Rank enum als Lua table implementiert
- [ ] createCard() factory function
- [ ] card:beats() method implementiert
- [ ] card:toString() method
- [ ] card:equals() method
- [ ] Unit tests für alle Kartenfunktionen

**Dateien zu erstellen:**
- `src/card.lua`
- `tests/card_test.lua`

---

### Issue #2: Deck Management System
**Priority:** CRITICAL ⭐⭐⭐⭐⭐  
**Abhängigkeiten:** Issue #1 (Card System)  
**Geschätzte Zeit:** 3-4 Stunden

**Beschreibung:**
Implementierung des Deck-Management-Systems:
- Deck-Erstellung mit konfigurierbaren Kartenanzahlen
- Fisher-Yates Shuffle-Algorithmus
- Karten-Ziehen mit Fehlerbehandlung

**Akzeptanzkriterien:**
- [ ] createDeck() factory function
- [ ] deck:draw() method
- [ ] deck:remaining() method  
- [ ] deck:shuffle() method (Fisher-Yates)
- [ ] Unterstützung für 24, 32, 36, 52 Karten-Decks
- [ ] Unit tests für alle Deck-Operationen

**Dateien zu erstellen:**
- `src/deck.lua`
- `tests/deck_test.lua`

---

### Issue #3: Game State Management
**Priority:** CRITICAL ⭐⭐⭐⭐⭐  
**Abhängigkeiten:** Keine  
**Geschätzte Zeit:** 2-3 Stunden

**Beschreibung:**
Implementierung des Spielzustands-Management-Systems:
- GameState enum
- State-Transitions mit Callbacks
- Event-System für Zustandsänderungen

**Akzeptanzkriterien:**
- [ ] GameState enum implementiert
- [ ] game:setState() method mit Callbacks
- [ ] State-Validation (nur gültige Übergänge)
- [ ] Event-Callbacks für Zustandsänderungen
- [ ] Logging für Debugging

**Dateien zu erstellen:**
- `src/gamestate.lua`
- `tests/gamestate_test.lua`

---

### Issue #4: RuleSet Configuration System
**Priority:** HIGH ⭐⭐⭐⭐  
**Abhängigkeiten:** Keine  
**Geschätzte Zeit:** 3-4 Stunden

**Beschreibung:**
Implementierung des konfigurierbaren Regelset-Systems:
- Alle Spielregeln-Optionen
- Speichern/Laden von Einstellungen
- Validation der Regel-Kombinationen

**Akzeptanzkriterien:**
- [ ] RuleSet table mit allen Optionen
- [ ] RuleSet:getLowestRank() method
- [ ] RuleSet:save() method
- [ ] RuleSet:load() method
- [ ] Regel-Validation (z.B. teamPlay nur bei 4+ Spielern)
- [ ] Default-Einstellungen

**Dateien zu erstellen:**
- `src/ruleset.lua`
- `tests/ruleset_test.lua`

---

## 🎯 Phase 2: Core Game Logic

### Issue #5: Player System Implementation
**Priority:** CRITICAL ⭐⭐⭐⭐⭐  
**Abhängigkeiten:** Issue #1 (Card System), Issue #4 (RuleSet)  
**Geschätzte Zeit:** 4-5 Stunden

**Beschreibung:**
Implementierung des Spieler-Systems:
- Spieler-Struktur mit Hand-Management
- Karten-Sortierung mit verschiedenen Modi
- Basis-Funktionen für Handverwaltung

**Akzeptanzkriterien:**
- [ ] createPlayer() factory function
- [ ] player:addCard() method
- [ ] player:sortCards() method (alle Modi)
- [ ] player:removeCard() method
- [ ] findCardInHand() utility function
- [ ] Hand-Größen-Validation

**Dateien zu erstellen:**
- `src/player.lua`
- `tests/player_test.lua`

---

### Issue #6: AI Evaluation System - Hand Value Calculation
**Priority:** CRITICAL ⭐⭐⭐⭐⭐  
**Abhängigkeiten:** Issue #1 (Card), Issue #4 (RuleSet), Issue #5 (Player)  
**Geschätzte Zeit:** 6-8 Stunden

**Beschreibung:**
Implementierung des komplexen KI-Bewertungssystems:
- Relative Kartenwert-Berechnung
- Hand-Bewertung mit allen Faktoren
- Komplexe Scoring-Algorithmen

**Akzeptanzkriterien:**
- [ ] getRelativeCardValue() function
- [ ] evaluateHand() function mit allen Faktoren:
  - [ ] Basis-Kartenwerte
  - [ ] Trump-Bonuses
  - [ ] Mehrfach-Rang-Bonuses
  - [ ] Farb-Balance-Strafen
  - [ ] Zu-viele-Karten-Strafen
- [ ] Umfangreiche Unit Tests für alle Szenarien
- [ ] Performance-Optimierung

**Dateien zu erstellen:**
- `src/ai_evaluation.lua`
- `tests/ai_evaluation_test.lua`

---

### Issue #7: AI Decision Making - Attack Logic
**Priority:** HIGH ⭐⭐⭐⭐  
**Abhängigkeiten:** Issue #6 (AI Evaluation)  
**Geschätzte Zeit:** 4-5 Stunden

**Beschreibung:**
Implementierung der KI-Angriffs-Logik:
- Beste Karte zum Werfen finden
- Mehrfach-Rang-Bonuses berücksichtigen
- Hand-Optimierung

**Akzeptanzkriterien:**
- [ ] aiStartTurn() function
- [ ] Rang-Zählung und Bonus-Berechnung
- [ ] Hand-Simulation ohne geworfene Karte
- [ ] Optimale Karten-Auswahl
- [ ] Edge-Case-Behandlung

**Dateien zu erstellen:**
- `src/ai_attack.lua`
- `tests/ai_attack_test.lua`

---

### Issue #8: AI Decision Making - Defense Logic
**Priority:** HIGH ⭐⭐⭐⭐  
**Abhängigkeiten:** Issue #6 (AI Evaluation)  
**Geschätzte Zeit:** 5-6 Stunden

**Beschreibung:**
Implementierung der KI-Verteidigungs-Logik:
- Entscheidung zwischen Schlagen und Nehmen
- Komplexe Kosten-Nutzen-Analyse
- Rang-Präsenz-Bonuses

**Akzeptanzkriterien:**
- [ ] aiTryBeat() function
- [ ] Karten-Schlag-Validation
- [ ] Rang-Präsenz-Bonus-Berechnung
- [ ] Schlagen-vs-Nehmen Entscheidung
- [ ] Endspiel-Logik (cardsRemaining = 0)

**Dateien zu erstellen:**
- `src/ai_defense.lua`
- `tests/ai_defense_test.lua`

---

### Issue #9: AI Decision Making - Throw Additional Cards
**Priority:** MEDIUM ⭐⭐⭐  
**Abhängigkeiten:** Issue #6 (AI Evaluation)  
**Geschätzte Zeit:** 3-4 Stunden

**Beschreibung:**
Implementierung der KI-Logik für Nachwerfen:
- Zusätzliche Karten nach erfolgreichem Angriff werfen
- Nur Karten mit vorhandenen Rängen
- Optimale Auswahl basierend auf Hand-Bewertung

**Akzeptanzkriterien:**
- [ ] aiThrowOrDone() function
- [ ] Rang-Matching-Validation
- [ ] Wurf-vs-Fertig Entscheidung
- [ ] Mehrfach-Rang-Prioritäten

**Dateien zu erstellen:**
- `src/ai_throw_additional.lua`
- `tests/ai_throw_additional_test.lua`

---

## 🎯 Phase 3: Game Flow Control

### Issue #10: Turn Management System
**Priority:** HIGH ⭐⭐⭐⭐  
**Abhängigkeiten:** Issue #3 (GameState), Issue #5 (Player)  
**Geschätzte Zeit:** 4-5 Stunden

**Beschreibung:**
Implementierung der Runden-Verwaltung:
- Spieler-Rotation
- Runden-Ende-Logik
- Karten-Verteilung nach Runden

**Akzeptanzkriterien:**
- [ ] Turn-Rotation-Logik
- [ ] endTurn() function
- [ ] Karten-Sammlung vom Tisch
- [ ] Nachziehen-Logik
- [ ] Spieler-aus-dem-Spiel-Erkennung
- [ ] Hand-Sortierung nach Aktionen

**Dateien zu erstellen:**
- `src/turn_management.lua`
- `tests/turn_management_test.lua`

---

### Issue #11: Game Setup and Initialization
**Priority:** HIGH ⭐⭐⭐⭐  
**Abhängigkeiten:** Issue #2 (Deck), Issue #4 (RuleSet), Issue #5 (Player)  
**Geschätzte Zeit:** 3-4 Stunden

**Beschreibung:**
Implementierung der Spiel-Initialisierung:
- Spieler-Erstellung basierend auf RuleSet
- Trump-Bestimmung
- Erster Angreifer-Bestimmung
- Initiale Kartenverteilung

**Akzeptanzkriterien:**
- [ ] setupGame() function
- [ ] Spieler-Erstellung für 2-5 Spieler
- [ ] Trump-Karte und Suit-Bestimmung
- [ ] Niedrigster-Trump-Algorithmus für ersten Angreifer
- [ ] 6-Karten-Verteilung pro Spieler
- [ ] Tisch-Arrays-Initialisierung

**Dateien zu erstellen:**
- `src/game_setup.lua`
- `tests/game_setup_test.lua`

---

### Issue #12: Win Condition Detection
**Priority:** MEDIUM ⭐⭐⭐  
**Abhängigkeiten:** Issue #5 (Player), Issue #4 (RuleSet)  
**Geschätzte Zeit:** 2-3 Stunden

**Beschreibung:**
Implementierung der Siegbedingungs-Erkennung:
- Einzelspiel vs Team-Spiel
- Siegbedingungen-Prüfung
- Gewinner-Bestimmung

**Akzeptanzkriterien:**
- [ ] isGameOver() function
- [ ] determineWinner() function
- [ ] Team-Modus-Unterstützung
- [ ] Unentschieden-Behandlung
- [ ] Korrektes Verlierer-System (letzter Spieler verliert)

**Dateien zu erstellen:**
- `src/win_conditions.lua`
- `tests/win_conditions_test.lua`

---

## 🎯 Phase 4: Love2D Integration

### Issue #13: Love2D Project Structure Setup
**Priority:** HIGH ⭐⭐⭐⭐  
**Abhängigkeiten:** Keine  
**Geschätzte Zeit:** 2-3 Stunden

**Beschreibung:**
Einrichtung der Love2D-Projektstruktur:
- main.lua und conf.lua
- Asset-Organisation
- Modul-Imports-System

**Akzeptanzkriterien:**
- [ ] main.lua mit love.load(), love.update(), love.draw()
- [ ] conf.lua mit Fenster-Konfiguration
- [ ] assets/ Ordner-Struktur
- [ ] src/ Modul-Organisation
- [ ] lib/ für externe Bibliotheken
- [ ] Modul-Import-System

**Dateien zu erstellen:**
- `main.lua`
- `conf.lua`
- `src/init.lua`

---

### Issue #14: Asset Loading System
**Priority:** HIGH ⭐⭐⭐⭐  
**Abhängigkeiten:** Issue #13 (Project Structure)  
**Geschätzte Zeit:** 3-4 Stunden

**Beschreibung:**
Implementierung des Asset-Loading-Systems:
- Karten-Bilder laden
- Hintergrund und UI-Elemente
- Font-Loading
- Asset-Management

**Akzeptanzkriterien:**
- [ ] Alle Kartenbilder laden (rus deck)
- [ ] Kartenrückseite
- [ ] Suit-Symbole
- [ ] Hintergrund-Textur
- [ ] Font-Loading
- [ ] Asset-Cache-System
- [ ] Fehlerbehandlung für fehlende Assets

**Dateien zu erstellen:**
- `src/assets.lua`
- `tests/assets_test.lua`

---

### Issue #15: Basic Rendering System
**Priority:** HIGH ⭐⭐⭐⭐  
**Abhängigkeiten:** Issue #14 (Asset Loading)  
**Geschätzte Zeit:** 4-5 Stunden

**Beschreibung:**
Implementierung des grundlegenden Rendering-Systems:
- Karten-Rendering mit Transformationen
- Hand-Darstellung
- Tisch-Darstellung
- Basis-UI-Elemente

**Akzeptanzkriterien:**
- [ ] drawCard() function mit allen Optionen
- [ ] drawPlayerHand() function
- [ ] drawTable() function für Angriff/Verteidigung
- [ ] Skalierung und Rotation
- [ ] Face-up/Face-down Rendering
- [ ] Tinting-Unterstützung

**Dateien zu erstellen:**
- `src/rendering.lua`
- `tests/rendering_test.lua`

---

### Issue #16: Input Handling System
**Priority:** MEDIUM ⭐⭐⭐  
**Abhängigkeiten:** Issue #15 (Rendering)  
**Geschätzte Zeit:** 3-4 Stunden

**Beschreibung:**
Implementierung des Input-Handling-Systems:
- Maus-Klick-Erkennung auf Karten
- Touch-Gesten (falls erforderlich)
- Keyboard-Shortcuts
- Input-State-Management

**Akzeptanzkriterien:**
- [ ] love.mousepressed() Integration
- [ ] Karten-Klick-Erkennung
- [ ] onCardClicked() callback system
- [ ] Bounding-Box-Kollision
- [ ] Input-State-Validation
- [ ] Hover-Effekte (optional)

**Dateien zu erstellen:**
- `src/input.lua`
- `tests/input_test.lua`

---

### Issue #17: Animation System
**Priority:** LOW ⭐⭐  
**Abhängigkeiten:** Issue #15 (Rendering)  
**Geschätzte Zeit:** 4-6 Stunden

**Beschreibung:**
Implementierung eines einfachen Animations-Systems:
- Tween-System für Kartenbewegungen
- Smooth-Transitionen
- Animation-Callbacks

**Akzeptanzkriterien:**
- [ ] Basis-Tween-System
- [ ] createTween() function
- [ ] Easing-Funktionen
- [ ] Animation-Update in love.update()
- [ ] Completion-Callbacks
- [ ] Kartenbewegung-Animationen

**Dateien zu erstellen:**
- `src/animation.lua`
- `tests/animation_test.lua`

---

## 🎯 Phase 5: Game Integration

### Issue #18: Core Game Loop Integration
**Priority:** CRITICAL ⭐⭐⭐⭐⭐  
**Abhängigkeiten:** Alle vorherigen Issues  
**Geschätzte Zeit:** 6-8 Stunden

**Beschreibung:**
Integration aller Komponenten in den Haupt-Game-Loop:
- Verbindung von AI-Logik mit Rendering
- Game-State-Management
- Turn-basiertes Gameplay
- Player-Input-Integration

**Akzeptanzkriterien:**
- [ ] Vollständiger Game-Loop
- [ ] AI vs Human gameplay
- [ ] Korrekte State-Transitions
- [ ] Synchronisation zwischen Logik und Rendering
- [ ] Error-Handling
- [ ] Debug-Output

**Dateien zu erstellen:**
- `src/game.lua`
- Integration in `main.lua`

---

### Issue #19: Menu System
**Priority:** MEDIUM ⭐⭐⭐  
**Abhängigkeiten:** Issue #13 (Project Structure), Issue #15 (Rendering)  
**Geschätzte Zeit:** 4-5 Stunden

**Beschreibung:**
Implementierung eines einfachen Menü-Systems:
- Hauptmenü
- Einstellungen-Menü
- Spiel-Modi-Auswahl

**Akzeptanzkriterien:**
- [ ] Hauptmenü mit Buttons
- [ ] Neues Spiel starten
- [ ] Einstellungen-Screen
- [ ] RuleSet-Konfiguration UI
- [ ] Menü-Navigation
- [ ] Screen-Management

**Dateien zu erstellen:**
- `src/menu.lua`
- `src/settings_menu.lua`

---

### Issue #20: Testing and Polish
**Priority:** MEDIUM ⭐⭐⭐  
**Abhängigkeiten:** Issue #18 (Game Integration)  
**Geschätzte Zeit:** 6-8 Stunden

**Beschreibung:**
Umfangreiche Tests und Feinschliff:
- Integration-Tests
- Gameplay-Tests
- Performance-Optimierung
- Bug-Fixes

**Akzeptanzkriterien:**
- [ ] Vollständiges Spiel funktioniert
- [ ] Alle KI-Modi getestet
- [ ] Performance acceptable (60 FPS)
- [ ] Keine kritischen Bugs
- [ ] Code-Review durchgeführt
- [ ] Dokumentation aktualisiert

**Dateien zu prüfen:**
- Alle `src/*.lua` files
- Alle `tests/*.lua` files

---

## 📊 Abhängigkeits-Graph

```
Phase 1 (Foundation):
Issue #1 (Cards) → Issue #2 (Deck)
Issue #1 (Cards) → Issue #5 (Player)
Issue #4 (RuleSet) → Issue #5 (Player)
Issue #3 (GameState) ← unabhängig
Issue #4 (RuleSet) ← unabhängig

Phase 2 (Core Logic):
Issue #5 (Player) → Issue #6 (AI Evaluation)
Issue #6 (AI Evaluation) → Issue #7 (AI Attack)
Issue #6 (AI Evaluation) → Issue #8 (AI Defense)  
Issue #6 (AI Evaluation) → Issue #9 (AI Throw)

Phase 3 (Game Flow):
Issue #5 (Player) + Issue #3 (GameState) → Issue #10 (Turn Management)
Issue #2 (Deck) + Issue #4 (RuleSet) + Issue #5 (Player) → Issue #11 (Game Setup)
Issue #5 (Player) + Issue #4 (RuleSet) → Issue #12 (Win Conditions)

Phase 4 (Love2D):
Issue #13 (Project Structure) → Issue #14 (Asset Loading)
Issue #14 (Asset Loading) → Issue #15 (Rendering)
Issue #15 (Rendering) → Issue #16 (Input)
Issue #15 (Rendering) → Issue #17 (Animation)

Phase 5 (Integration):
Alle vorherigen → Issue #18 (Game Integration)
Issue #13 + Issue #15 → Issue #19 (Menu)
Issue #18 → Issue #20 (Testing)
```

## ⚡ Kritischer Pfad (Minimal Viable Product)

Für eine funktionsfähige Version in kürzester Zeit:

1. **Issue #1** (Cards) 
2. **Issue #2** (Deck)
3. **Issue #5** (Player)
4. **Issue #6** (AI Evaluation)
5. **Issue #7** (AI Attack)
6. **Issue #8** (AI Defense)
7. **Issue #13** (Love2D Setup)
8. **Issue #14** (Asset Loading)
9. **Issue #15** (Rendering)
10. **Issue #18** (Game Integration)

**Geschätzte Zeit für MVP:** 35-45 Stunden

## 🚀 Nächste Schritte

1. **Issues in GitHub anlegen** (in der angegebenen Reihenfolge)
2. **Labels zuweisen:**
   - `priority:critical`, `priority:high`, `priority:medium`, `priority:low`
   - `phase:foundation`, `phase:core-logic`, `phase:game-flow`, `phase:love2d`, `phase:integration`
   - `type:feature`, `type:refactor`, `type:testing`
3. **Milestone erstellen** für jede Phase
4. **Branch-Protection** einrichten
5. **Mit Issue #1 beginnen**

Dieser Plan bietet eine strukturierte Herangehensweise mit klaren Abhängigkeiten und Prioritäten für die komplette Migration von OpenFool zu Love2D.