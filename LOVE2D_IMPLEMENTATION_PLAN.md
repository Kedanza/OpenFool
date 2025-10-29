# OpenFool zu Love2D Migration - Implementierungsplan

Branch: `love2d-implementation`

## 📋 Übersicht

Systematische Migration der OpenFool Kotlin/libGDX Implementierung zu Lua/Love2D basierend auf der Translation Guide.

## 🎯 Phase 1: Foundation (Kritischer Pfad)

### Issue #1: Core Data Structures Migration ✅
**GitHub Issue:** [#2](https://github.com/Kedanza/OpenFool/issues/2)  
**Priority:** CRITICAL ⭐⭐⭐⭐⭐  
**Abhängigkeiten:** Keine  
**Geschätzte Zeit:** 4-6 Stunden  
**Status:** COMPLETED | Tests: 23/23 ✓

**Beschreibung:**
Migration der grundlegenden Datenstrukturen von Kotlin zu Lua:
- Suit enum → Lua table
- Rank enum → Lua table  
- Card class → Lua factory function
- Basic card comparison logic (beats function)

**Akzeptanzkriterien:**
- [x] Suit enum als Lua table implementiert
- [x] Rank enum als Lua table implementiert
- [x] createCard() factory function
- [x] card:beats() method implementiert
- [x] card:toString() method
- [x] card:equals() method
- [x] Unit tests für alle Kartenfunktionen

**Dateien erstellt:**
- `src/card.lua`
- `tests/card_test_love.lua`

---

### Issue #2: Deck Management System ✅
**GitHub Issue:** [#3](https://github.com/Kedanza/OpenFool/issues/3)  
**Priority:** CRITICAL ⭐⭐⭐⭐⭐  
**Abhängigkeiten:** Issue #1 (Card System)  
**Geschätzte Zeit:** 3-4 Stunden  
**Status:** COMPLETED | Tests: 28/28 ✓

**Beschreibung:**
Implementierung des Deck-Management-Systems:
- Deck-Erstellung mit konfigurierbaren Kartenanzahlen
- Fisher-Yates Shuffle-Algorithmus
- Karten-Ziehen mit Fehlerbehandlung

**Akzeptanzkriterien:**
- [x] createDeck() factory function
- [x] deck:draw() method
- [x] deck:remaining() method  
- [x] deck:shuffle() method (Fisher-Yates)
- [x] Unterstützung für 24, 32, 36, 52 Karten-Decks
- [x] Unit tests für alle Deck-Operationen

**Dateien erstellt:**
- `src/deck.lua`
- `tests/deck_test_love.lua`

---

### Issue #3: Game State Management ✅
**GitHub Issue:** [#9](https://github.com/Kedanza/OpenFool/issues/9)  
**Priority:** CRITICAL ⭐⭐⭐⭐⭐  
**Abhängigkeiten:** Keine  
**Geschätzte Zeit:** 2-3 Stunden  
**Status:** COMPLETED | Tests: 92/92 ✓

**Beschreibung:**
Implementierung des Spielzustands-Management-Systems:
- GameState enum
- State-Transitions mit Callbacks
- Event-System für Zustandsänderungen

**Akzeptanzkriterien:**
- [x] GameState enum implementiert (7 states)
- [x] game:setState() method mit Callbacks
- [x] State-Validation (nur gültige Übergänge)
- [x] Event-Callbacks für Zustandsänderungen
- [x] Logging für Debugging

**Dateien erstellt:**
- `src/gamestate.lua`
- `tests/gamestate_test_love.lua`

**Hinweis:** Umfassendes State-Management-System mit Transition-Validierung, Callback-System, und Helper-Methoden (isState, isAnyState).

---

### Issue #4: RuleSet Configuration System ✅
**GitHub Issue:** [#8](https://github.com/Kedanza/OpenFool/issues/8)  
**Priority:** HIGH ⭐⭐⭐⭐  
**Abhängigkeiten:** Keine  
**Geschätzte Zeit:** 3-4 Stunden  
**Status:** COMPLETED | Tests: 59/59 ✓

**Beschreibung:**
Implementierung des konfigurierbaren Regelset-Systems:
- Alle Spielregeln-Optionen
- Speichern/Laden von Einstellungen
- Validation der Regel-Kombinationen

**Akzeptanzkriterien:**
- [x] RuleSet table mit allen Optionen
- [x] RuleSet:getLowestRank() method
- [x] RuleSet:save() method
- [x] RuleSet:load() method
- [x] Regel-Validation (z.B. teamPlay nur bei 4+ Spielern)
- [x] Default-Einstellungen

**Dateien erstellt:**
- `src/ruleset.lua`
- `tests/ruleset_test_love.lua`

---

## 🎯 Phase 2: Core Game Logic

### Issue #5: Player System Implementation ✅
**Priority:** CRITICAL ⭐⭐⭐⭐⭐  
**Abhängigkeiten:** Issue #1 (Card System), Issue #4 (RuleSet)  
**Geschätzte Zeit:** 4-5 Stunden  
**Status:** COMPLETED | Tests: 55/55 ✓

**Beschreibung:**
Implementierung des Spieler-Systems:
- Spieler-Struktur mit Hand-Management
- Karten-Sortierung mit verschiedenen Modi
- Basis-Funktionen für Handverwaltung

**Akzeptanzkriterien:**
- [x] createPlayer() factory function
- [x] player:addCard() method
- [x] player:sortCards() method (alle Modi)
- [x] player:removeCard() method
- [x] findCardInHand() utility function
- [x] Hand-Größen-Validation

**Dateien erstellt:**
- `src/player.lua`
- `tests/player_test_love.lua`

**Hinweis:** Lua-spezifisches Problem gelöst - Arrays mit allen nil-Werten haben `#array == 0`, daher wird feste Arraygröße (6) verwendet statt dynamischer Länge.

---

### Issue #6: AI Evaluation System - Hand Value Calculation ✅
**GitHub Issue:** [#4](https://github.com/Kedanza/OpenFool/issues/4)  
**Priority:** CRITICAL ⭐⭐⭐⭐⭐  
**Abhängigkeiten:** Issue #1 (Card), Issue #4 (RuleSet), Issue #5 (Player)  
**Geschätzte Zeit:** 6-8 Stunden  
**Status:** COMPLETED | Tests: 37/37 ✓

**Beschreibung:**
Implementierung des komplexen KI-Bewertungssystems:
- Relative Kartenwert-Berechnung
- Hand-Bewertung mit allen Faktoren
- Komplexe Scoring-Algorithmen

**Akzeptanzkriterien:**
- [x] getRelativeCardValue() function
- [x] evaluateHand() function mit allen Faktoren:
  - [x] Basis-Kartenwerte
  - [x] Trump-Bonuses
  - [x] Mehrfach-Rang-Bonuses
  - [x] Farb-Balance-Strafen
  - [x] Zu-viele-Karten-Strafen
- [x] Umfangreiche Unit Tests für alle Szenarien
- [x] Performance-Optimierung

**Dateien erstellt:**
- `src/ai_evaluation.lua`
- `tests/ai_evaluation_test_love.lua`

---

### Issue #7: AI Decision Making - Attack Logic ✅
**GitHub Issue:** [#5](https://github.com/Kedanza/OpenFool/issues/5)  
**Priority:** HIGH ⭐⭐⭐⭐  
**Abhängigkeiten:** Issue #6 (AI Evaluation)  
**Geschätzte Zeit:** 4-5 Stunden  
**Status:** COMPLETED | Tests: 44/44 ✓

**Beschreibung:**
Implementierung der KI-Angriffs-Logik:
- Beste Karte zum Werfen finden
- Mehrfach-Rang-Bonuses berücksichtigen
- Hand-Optimierung

**Akzeptanzkriterien:**
- [x] aiStartTurn() function
- [x] Rang-Zählung und Bonus-Berechnung
- [x] Hand-Simulation ohne geworfene Karte
- [x] Optimale Karten-Auswahl
- [x] Edge-Case-Behandlung

**Dateien erstellt:**
- `src/ai_attack.lua`
- `tests/ai_attack_test_love.lua`

---

### Issue #8: AI Decision Making - Defense Logic ✅
**GitHub Issue:** [#6](https://github.com/Kedanza/OpenFool/issues/6)  
**Priority:** HIGH ⭐⭐⭐⭐  
**Abhängigkeiten:** Issue #6 (AI Evaluation)  
**Geschätzte Zeit:** 5-6 Stunden  
**Status:** COMPLETED | Tests: 17/17 ✓

**Beschreibung:**
Implementierung der KI-Verteidigungs-Logik:
- Entscheidung zwischen Schlagen und Nehmen
- Komplexe Kosten-Nutzen-Analyse
- Rang-Präsenz-Bonuses

**Akzeptanzkriterien:**
- [x] aiTryBeat() function
- [x] Karten-Schlag-Validation
- [x] Rang-Präsenz-Bonus-Berechnung
- [x] Schlagen-vs-Nehmen Entscheidung
- [x] Endspiel-Logik (cardsRemaining = 0)

**Dateien erstellt:**
- `src/ai_defense.lua`
- `tests/ai_defense_test_love.lua`

---

### Issue #9: AI Decision Making - Throw Additional Cards ✅
**GitHub Issue:** [#24](https://github.com/Kedanza/OpenFool/issues/24)  
**Priority:** MEDIUM ⭐⭐⭐  
**Abhängigkeiten:** Issue #6 (AI Evaluation)  
**Geschätzte Zeit:** 3-4 Stunden  
**Status:** COMPLETED | Tests: 13/13 ✓

**Beschreibung:**
Implementierung der KI-Logik für Nachwerfen:
- Zusätzliche Karten nach erfolgreichem Angriff werfen
- Nur Karten mit vorhandenen Rängen
- Optimale Auswahl basierend auf Hand-Bewertung

**Akzeptanzkriterien:**
- [x] aiThrowOrDone() function
- [x] Rang-Matching-Validation
- [x] Wurf-vs-Fertig Entscheidung
- [x] Mehrfach-Rang-Prioritäten

**Dateien erstellt:**
- `src/ai_throw_additional.lua`
- `tests/ai_throw_additional_test_love.lua`

---

## 🎯 Phase 3: Game Flow Control

### Issue #10: Turn Management System ✅
**GitHub Issue:** [#10](https://github.com/Kedanza/OpenFool/issues/10)  
**Priority:** HIGH ⭐⭐⭐⭐  
**Abhängigkeiten:** Issue #3 (GameState), Issue #5 (Player)  
**Geschätzte Zeit:** 4-5 Stunden  
**Status:** COMPLETED | Tests: 46/46 ✓

**Beschreibung:**
Implementierung der Runden-Verwaltung:
- Spieler-Rotation
- Runden-Ende-Logik
- Karten-Verteilung nach Runden

**Akzeptanzkriterien:**
- [x] Turn-Rotation-Logik (getNextPlayerIndex)
- [x] endTurn() function
- [x] Karten-Sammlung vom Tisch
- [x] Nachziehen-Logik (up to 6 cards per player)
- [x] Spieler-aus-dem-Spiel-Erkennung
- [x] Team-Play-Unterstützung (P1+P2 vs P3+P4)
- [x] getCurrentAttacker/getCurrentDefender
- [x] isGameOver und determineWinner

**Dateien erstellt:**
- `src/turn.lua`
- `tests/turn_test_love.lua`

**Hinweis:** Vollständiges Turn-Management-System mit Team-Play-Unterstützung, Out-of-Play-Erkennung, und komplexer Kartenverteilungslogik.

---

### Issue #11: Game Setup and Initialization
**GitHub Issue:** [#11](https://github.com/Kedanza/OpenFool/issues/11)  
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
**GitHub Issue:** [#12](https://github.com/Kedanza/OpenFool/issues/12)  
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
**GitHub Issue:** [#13](https://github.com/Kedanza/OpenFool/issues/13)  
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
**GitHub Issue:** [#14](https://github.com/Kedanza/OpenFool/issues/14)  
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
**GitHub Issue:** [#16](https://github.com/Kedanza/OpenFool/issues/16)  
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
**GitHub Issue:** [#17](https://github.com/Kedanza/OpenFool/issues/17)  
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
**GitHub Issue:** [#18](https://github.com/Kedanza/OpenFool/issues/18)  
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