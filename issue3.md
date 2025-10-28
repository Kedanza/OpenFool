# 🎯 Issue #3: Game State Management

**Priority:** CRITICAL ⭐⭐⭐⭐⭐  
**Geschätzte Zeit:** 2-3 Stunden  
**Abhängigkeiten:** Keine

## 📋 Übersicht
Implementierung des Spielzustands-Management-Systems mit State-Transitions und Callbacks.

## 🎯 Hauptaufgaben

### 1. GameState Enum
```lua
GameState = {
    READY = "ready",
    DRAWING = "drawing", 
    THROWING = "throwing",
    THROWN = "thrown",
    -- etc.
}
```

### 2. State Management
```lua
game = {
    state = GameState.READY,
    setState = function(self, newState)
        -- Transition logic with callbacks
    end
}
```

## ✅ Akzeptanzkriterien
- [ ] GameState enum mit allen Zuständen
- [ ] game:setState() method mit Validation
- [ ] State-Transition-Callbacks
- [ ] oldState Tracking
- [ ] Logging für Debugging
- [ ] Unit tests für alle Transitions

## 📁 Dateien
- `src/gamestate.lua`
- `tests/gamestate_test.lua`

## 📚 Referenzen
- **Original Code:** `core/src/ru/hyst329/openfool/GameScreen.kt` (GameState enum)
- **Detaillierte Anleitung:** `docs/guides/OpenFool_to_Love2D_Translation_Guide.md` (Abschnitt 1)

**Status:** 🔴 Ready to Start