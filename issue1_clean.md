# Issue #1: Core Data Structures (Cards, Suits, Ranks) - CRITICAL

**Priority:** CRITICAL ⭐⭐⭐⭐⭐  
**Geschätzte Zeit:** 4-6 Stunden  
**Abhängigkeiten:** Keine - kann sofort begonnen werden

## Übersicht
Migration der grundlegenden Kartensystem-Datenstrukturen von Kotlin zu Lua:
- Suit enum → Lua table (Pik, Karo, Kreuz, Herz)  
- Rank enum → Lua table (Ass bis König)
- Card class → Lua factory function mit beats() Logik

## Beispiel-Code

### Suit & Rank Tables
```lua
Suit = { SPADES = 0, DIAMONDS = 1, CLUBS = 2, HEARTS = 3 }
Rank = { ACE = 1, TWO = 2, THREE = 3, FOUR = 4, FIVE = 5, SIX = 6,
         SEVEN = 7, EIGHT = 8, NINE = 9, TEN = 10, JACK = 11, QUEEN = 12, KING = 13 }
```

### Card Factory mit beats() Logic
```lua
function createCard(suit, rank)
    -- Implementiere: beats(), toString(), equals()
    -- Kern-Algorithmus: (rank + 11) % 13 für Rangvergleiche
    -- Gleiche Farbe: höherer Rang gewinnt
    -- Verschiedene Farbe: nur Trumpf schlägt
end
```

## Akzeptanzkriterien
- [ ] Suit table mit Werten 0-3
- [ ] Rank table mit Werten 1-13  
- [ ] createCard() factory function
- [ ] card:beats() mit Trump-/Ranglogik
- [ ] card:toString() Format: "1s", "13h"
- [ ] card:equals() für Vergleiche
- [ ] findCardInHand() utility
- [ ] Unit tests für alle Funktionen

## Dateien
- `src/card.lua` - Implementierung
- `tests/card_test.lua` - Tests

## Referenzen  
- **Original:** `core/src/ru/hyst329/openfool/Card.kt`
- **Detaillierte Anleitung:** `docs/guides/OpenFool_to_Love2D_Translation_Guide.md` (Abschnitt 2)
- **Nächstes Issue:** #2 (Deck Management)