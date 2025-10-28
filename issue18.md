# Issue #18: Menu System

**Priority:** MEDIUM ⭐⭐⭐  
**Zeit:** 4-5h  
**Abhängigkeiten:** #12 (Love2D Setup), #14 (Rendering)

## Übersicht
Hauptmenü, Einstellungen, Spielkonfiguration.

## Akzeptanzkriterien
- [ ] Hauptmenü (Neues Spiel, Einstellungen, Beenden)
- [ ] Einstellungsmenü
- [ ] Regelkonfiguration UI
- [ ] Spieleranzahl-Auswahl
- [ ] Menü-Navigation
- [ ] Button-Rendering und Input

## Beispiel
```lua
Menu = {}
Menu.__index = Menu

function Menu.new()
    local self = setmetatable({}, Menu)
    self.buttons = {}
    self:addButton("New Game", function() startGame() end)
    self:addButton("Settings", function() showSettings() end)
    return self
end

function Menu:draw()
    for _, button in ipairs(self.buttons) do
        button:draw()
    end
end
```

## Referenzen
- **Original:** `MainMenuScreen.kt`, `NewGameScreen.kt`, `SettingsScreen.kt`
- **Anleitung:** `docs/guides/OpenFool_to_Love2D_Translation_Guide.md`
