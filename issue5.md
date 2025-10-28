# Issue #5: AI Defense Logic (tryBeat) - CRITICAL

**Priority:** CRITICAL ⭐⭐⭐⭐⭐  
**Geschätzte Zeit:** 5-6 Stunden  
**Abhängigkeiten:** Issue #3 (AI Evaluation)

## Übersicht
KI-Entscheidung: Schlagen oder Nehmen? Komplexe Kosten-Nutzen-Analyse.

## Kern-Logik
- Finde alle Karten die schlagen können
- Simuliere Hand nach Schlagen
- Simuliere Hand nach Nehmen
- Vergleiche Outcomes mit Strafen
- Entscheide basierend auf cardsRemaining

## Akzeptanzkriterien
- [ ] aiTryBeat() function
- [ ] Rang-Präsenz-Bonus (300)
- [ ] PENALTY (800) und TAKE_PENALTY Konstanten
- [ ] Schlagen-vs-Nehmen Entscheidung
- [ ] Endspiel-Logik (cardsRemaining = 0)
- [ ] Unit tests für verschiedene Szenarien

## Referenzen
- **Original:** `core/src/ru/hyst329/openfool/Player.kt` (tryBeat)
- **Anleitung:** `docs/guides/OpenFool_to_Love2D_Translation_Guide.md` (Abschnitt 4)
