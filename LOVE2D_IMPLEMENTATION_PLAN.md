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
**GitHub Issue:** [#7](https://github.com/Kedanza/OpenFool/issues/7)  
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

### Issue #9: AI Decision Making - Throw Additional Cards ✅ 🔍
**GitHub Issue:** [#24](https://github.com/Kedanza/OpenFool/issues/24)  
**Priority:** MEDIUM ⭐⭐⭐  
**Abhängigkeiten:** Issue #6 (AI Evaluation)  
**Geschätzte Zeit:** 3-4 Stunden  
**Status:** COMPLETED - NEEDS REVIEW ⚠️ | Tests: 13/13 ✓

**Beschreibung:**
Implementierung der KI-Logik für Nachwerfen:
- Zusätzliche Karten nach erfolgreichem Angriff werfen
- Nur Karten mit vorhandenen Rängen
- Optimale Auswahl basierend auf Hand-Bewertung

**⚠️ Hinweis:** Dieses Feature wurde nachträglich hinzugefügt und war nicht im ursprünglichen Plan. Benötigt Code-Review und Integration-Testing mit dem Rest des Spiels.

**Akzeptanzkriterien:**
- [x] aiThrowOrDone() function
- [x] Rang-Matching-Validation
- [x] Wurf-vs-Fertig Entscheidung
- [x] Mehrfach-Rang-Prioritäten
- [ ] Code-Review durchgeführt
- [ ] Integration mit Game Loop getestet

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

### Issue #11: Game Setup and Initialization ✅
**GitHub Issue:** [#11](https://github.com/Kedanza/OpenFool/issues/11)  
**Priority:** HIGH ⭐⭐⭐⭐  
**Abhängigkeiten:** Issue #2 (Deck), Issue #4 (RuleSet), Issue #5 (Player)  
**Geschätzte Zeit:** 3-4 Stunden  
**Status:** COMPLETED | Tests: 93/93 ✓

**Beschreibung:**
Implementierung der Spiel-Initialisierung:
- Spieler-Erstellung basierend auf RuleSet
- Trump-Bestimmung
- Erster Angreifer-Bestimmung
- Initiale Kartenverteilung

**Akzeptanzkriterien:**
- [x] setupGame() function
- [x] Spieler-Erstellung für 2-5 Spieler
- [x] Trump-Karte und Suit-Bestimmung
- [x] Niedrigster-Trump-Algorithmus für ersten Angreifer
- [x] 6-Karten-Verteilung pro Spieler
- [x] Tisch-Arrays-Initialisierung
- [x] findFirstAttacker() mit ACE/DEUCE Sonderfällen
- [x] needsRedeal() Erkennung
- [x] Vollständige Game-State-Rückgabe (13 Felder)

**Dateien erstellt:**
- `src/game_setup.lua`
- `tests/game_setup_test_love.lua`

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

### Issue #13: Love2D Project Structure Setup ✅
**GitHub Issue:** [#13](https://github.com/Kedanza/OpenFool/issues/13)  
**Priority:** HIGH ⭐⭐⭐⭐  
**Abhängigkeiten:** Keine  
**Geschätzte Zeit:** 2-3 Stunden  
**Status:** COMPLETED - NEEDS TESTING ⚠️

**Beschreibung:**
Einrichtung der Love2D-Projektstruktur:
- main.lua und conf.lua
- Asset-Organisation
- Modul-Imports-System

**Akzeptanzkriterien:**
- [x] main.lua mit love.load(), love.update(), love.draw()
- [x] conf.lua mit Fenster-Konfiguration
- [x] src/init.lua Modul-Organisation
- [x] Modul-Import-System
- [x] Grundlegende Game-Initialisierung
- [x] Keyboard/Mouse-Event-Handling

**Dateien erstellt:**
- `main.lua`
- `conf.lua`
- `src/init.lua`

**⚠️ Hinweis:** Implementation abgeschlossen, aber Tests fehlen. Siehe Issue #22 für Test-Requirements.

---

### Issue #14: Asset Loading System ✅
**GitHub Issue:** [#14](https://github.com/Kedanza/OpenFool/issues/14)  
**Priority:** HIGH ⭐⭐⭐⭐  
**Abhängigkeiten:** Issue #13 (Project Structure)  
**Geschätzte Zeit:** 3-4 Stunden  
**Status:** COMPLETED - NEEDS TESTING ⚠️

**Beschreibung:**
Implementierung des Asset-Loading-Systems:
- Karten-Bilder laden
- Hintergrund und UI-Elemente
- Font-Loading
- Asset-Management

**Akzeptanzkriterien:**
- [x] Alle Kartenbilder laden (rus deck) - 52 cards loaded
- [x] Kartenrückseite - back.png loaded
- [x] Suit-Symbole - 4 suit symbols loaded
- [x] Hintergrund-Textur - background1.png loaded
- [x] Font-Loading - 4 font sizes (12, 16, 24, 32pt)
- [x] Asset-Cache-System - Indexed by "rank-suit"
- [x] Fehlerbehandlung für fehlende Assets - pcall() wrapping

**Dateien erstellt:**
- `src/assets.lua` (217 lines)

**⚠️ Hinweis:** Implementation abgeschlossen, aber Tests fehlen. Siehe Issue #23 für Test-Requirements.

---

### Issue #15: Basic Rendering System ✅
**GitHub Issue:** [#15](https://github.com/Kedanza/OpenFool/issues/15)  
**Priority:** HIGH ⭐⭐⭐⭐  
**Abhängigkeiten:** Issue #14 (Asset Loading)  
**Geschätzte Zeit:** 4-5 Stunden  
**Status:** COMPLETED - NEEDS TESTING ⚠️

**Beschreibung:**
Implementierung des grundlegenden Rendering-Systems:
- Karten-Rendering mit Transformationen
- Hand-Darstellung
- Tisch-Darstellung
- Basis-UI-Elemente

**Akzeptanzkriterien:**
- [x] drawCard() function mit allen Optionen (rotation, scale, faceUp, alpha, highlight)
- [x] drawPlayerHand() function (fan layout with arc animation)
- [x] drawTable() function für Angriff/Verteidigung (card pairs with offset)
- [x] Skalierung und Rotation (full transform support)
- [x] Face-up/Face-down Rendering (conditional image selection)
- [x] Tinting-Unterstützung (alpha blending, highlight borders)
- [x] drawTrump() trump indicator (rotated 90° with deck count)
- [x] Mouse hit detection (isPointInCard for selection)

**Dateien erstellt:**
- `src/rendering.lua` (279 lines)

**⚠️ Hinweis:** Implementation abgeschlossen, aber Tests fehlen. Siehe Issue #24 für Test-Requirements.

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
**GitHub Issue:** [#19](https://github.com/Kedanza/OpenFool/issues/19)  
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
**GitHub Issue:** [#20](https://github.com/Kedanza/OpenFool/issues/20)  
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

### Issue #21: Documentation and Project Finalization
**GitHub Issue:** [#21](https://github.com/Kedanza/OpenFool/issues/21)  
**Priority:** LOW ⭐⭐  
**Abhängigkeiten:** Alle Issues abgeschlossen  
**Geschätzte Zeit:** 3-4 Stunden

**Beschreibung:**
Vollständige Code-Dokumentation und Projekt-Finalisierung:
- README.md aktualisieren
- Code-Kommentare für alle Hauptmodule
- API-Dokumentation
- Entwickler-Guide
- Changelog pflegen

**Akzeptanzkriterien:**
- [ ] README.md aktualisieren (Installation, Build, Run)
- [ ] Code-Kommentare für alle Hauptmodule
- [ ] API-Dokumentation erstellt
- [ ] Entwickler-Guide geschrieben
- [ ] CHANGELOG.md gepflegt
- [ ] Lizenz geprüft

**Dateien zu erstellen/aktualisieren:**
- `README.md`
- `docs/API.md`
- `docs/DEVELOPER_GUIDE.md`
- `CHANGELOG.md`

---

### Issue #22: Love2D Project Structure Tests
**GitHub Issue:** [#22](https://github.com/Kedanza/OpenFool/issues/22)
**Priority:** HIGH ⭐⭐⭐⭐
**Type:** Testing
**Abhängigkeiten:** Issue #13 (Love2D Project Structure)
**Geschätzte Zeit:** 2-3 Stunden

**Beschreibung:**
Create comprehensive tests for the Love2D project structure components to ensure proper initialization, module loading, and basic functionality.

**Akzeptanzkriterien:**
- [ ] `main.lua` loads without errors
- [ ] `love.load()` initializes game state correctly
- [ ] `love.update(dt)` runs without errors
- [ ] `love.draw()` renders basic elements
- [ ] `conf.lua` configures window properly (title, size, vsync)
- [ ] `src/init.lua` loads all required modules
- [ ] Module dependencies resolve correctly
- [ ] Keyboard input handling works
- [ ] Mouse input handling works

**Dateien zu erstellen:**
- `tests/love2d_structure_test.lua`
- `tests/conf_test.lua`
- `tests/module_loading_test.lua`

---

### Issue #23: Asset Loading System Tests
**GitHub Issue:** [#23](https://github.com/Kedanza/OpenFool/issues/23)
**Priority:** HIGH ⭐⭐⭐⭐
**Type:** Testing
**Abhängigkeiten:** Issue #14 (Asset Loading System)
**Geschätzte Zeit:** 3-4 Stunden

**Beschreibung:**
Create comprehensive tests for the asset loading system to ensure all game assets load correctly, error handling works, and the asset cache functions properly.

**Akzeptanzkriterien:**
- [ ] All 52 card images load successfully (russian deck)
- [ ] Card back image loads correctly
- [ ] All 4 suit symbols load (hearts, diamonds, clubs, spades)
- [ ] All 4 font sizes load (12pt, 16pt, 24pt, 32pt)
- [ ] Background image loads successfully
- [ ] Cards are indexed properly by "rank-suit" format
- [ ] Asset cache prevents duplicate loading
- [ ] Missing asset files are handled gracefully

**Dateien zu erstellen:**
- `tests/asset_loading_test.lua`
- `tests/asset_cache_test.lua`
- `tests/asset_error_handling_test.lua`

---

### Issue #24: Rendering System Tests
**GitHub Issue:** [#24](https://github.com/Kedanza/OpenFool/issues/24)
**Priority:** HIGH ⭐⭐⭐⭐
**Type:** Testing
**Abhängigkeiten:** Issue #15 (Basic Rendering System)
**Geschätzte Zeit:** 4-5 Stunden

**Beschreibung:**
Create comprehensive tests for the rendering system to ensure all drawing functions work correctly, visual elements render properly, and performance is acceptable.

**Akzeptanzkriterien:**
- [ ] `drawCard()` renders cards at correct positions
- [ ] Face-up/face-down rendering works correctly
- [ ] Card rotation and scaling applied properly
- [ ] `drawPlayerHand()` creates proper fan layout
- [ ] `drawTable()` shows attack/defense pairs correctly
- [ ] `drawTrump()` shows trump suit rotated 90°
- [ ] `isPointInCard()` detects mouse clicks on cards
- [ ] Rendering maintains 60 FPS
- [ ] No visual artifacts or glitches

**Dateien zu erstellen:**
- `tests/rendering_test.lua`
- `tests/card_drawing_test.lua`
- `tests/layout_test.lua`
- `tests/performance_rendering_test.lua`

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