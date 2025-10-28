# Issue #3: AI Hand Evaluation System - CRITICAL

**Priority:** CRITICAL ⭐⭐⭐⭐⭐  
**Geschätzte Zeit:** 6-8 Stunden  
**Abhängigkeiten:** Issue #1 (Card System)

## Übersicht
Implementierung des komplexen KI-Bewertungssystems - das Herzstück der OpenFool KI-Logik.

## Beispiel-Code

### Hand-Bewertung
```lua
function evaluateHand(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
    -- Basis-Score: Kartenwerte + Trump-Bonuses
    -- Mehrfach-Rang-Bonuses (gut für Verteidigung)
    -- Farb-Balance-Strafen
    -- Zu-viele-Karten-Strafen
    return totalScore
end
```

### Relative Kartenwerte
```lua
function getRelativeCardValue(rankValue, lowestRank)
    -- Berechne Wert basierend auf Deck-Zusammensetzung
    -- ACE hat Spezialbehandlung
    return relativeValue
end
```

## Kern-Algorithmus
- **Basis-Score:** Kartenwerte * RANK_MULTIPLIER (100)
- **Trump-Bonus:** +1300 pro Trumpfkarte
- **Mehrfach-Ränge:** Bonuses für Paare/Drillinge
- **Farb-Balance:** Strafe für unausgeglichene Verteilung
- **Endspiel:** OUT_OF_PLAY = 30000 (Spieler raus)

## Akzeptanzkriterien
- [ ] evaluateHand() Hauptfunktion
- [ ] getRelativeCardValue() mit ACE-Logik
- [ ] Alle Konstanten korrekt (RANK_MULTIPLIER etc.)
- [ ] Mehrfach-Rang-Bonuses (0, 0, 0.5, 0.75, 1.25)
- [ ] Farb-Balance-Algorithmus
- [ ] Karten-Ratio-Berechnung
- [ ] Unit tests für verschiedene Hände
- [ ] Performance-Tests (1000+ Aufrufe)

## Dateien
- `src/ai_evaluation.lua`
- `tests/ai_evaluation_test.lua`

## Referenzen
- **Original:** `core/src/ru/hyst329/openfool/Player.kt` (evaluateHand)
- **Komplette Anleitung:** `docs/guides/OpenFool_to_Love2D_Translation_Guide.md` (Abschnitt 4 - Hand Bewertung)
- **Nächstes Issue:** #4 (AI Attack Logic)