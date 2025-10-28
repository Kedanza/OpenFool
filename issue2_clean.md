# Issue #2: Deck Management System - CRITICAL

**Priority:** CRITICAL ⭐⭐⭐⭐⭐  
**Geschätzte Zeit:** 3-4 Stunden  
**Abhängigkeiten:** Issue #1 (Card System)

## Übersicht
Implementierung des Deck-Management-Systems mit konfigurierbaren Kartenanzahlen und Shuffle-Algorithmus.

## Beispiel-Code

### Deck Creation
```lua
function createDeck(lowestRank)
    -- Erstelle 24, 32, 36 oder 52 Karten
    -- ACE immer enthalten, unabhängig von lowestRank
    -- Beispiel: lowestRank = Rank.SIX → 36-Karten-Deck
end
```

### Fisher-Yates Shuffle
```lua
for i = #cards, 2, -1 do
    local j = love.math.random(1, i)
    cards[i], cards[j] = cards[j], cards[i]
end
```

### Draw & Management
```lua
function deck:draw()
    return table.remove(self.cards) -- von Ende ziehen
end

function deck:remaining()
    return #self.cards
end
```

## Akzeptanzkriterien
- [ ] createDeck(lowestRank) factory function
- [ ] Unterstützung für 24, 32, 36, 52 Karten-Decks
- [ ] deck:draw() method (O(1) Performance)
- [ ] deck:remaining() method
- [ ] deck:shuffle() mit Fisher-Yates Algorithmus
- [ ] ACE-Spezialbehandlung (immer enthalten)
- [ ] Unit tests für alle Deck-Größen
- [ ] Error handling für leeres Deck

## Dateien
- `src/deck.lua` - Implementierung
- `tests/deck_test.lua` - Tests

## Referenzen
- **Original:** `core/src/ru/hyst329/openfool/Deck.kt`
- **Detaillierte Anleitung:** `docs/guides/OpenFool_to_Love2D_Translation_Guide.md` (Abschnitt 3)
- **Nächstes Issue:** #3 (Game State Management)