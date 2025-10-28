# OpenFool Game Mechanics Translation Guide: Kotlin/libGDX zu Lua/Love2D

Eine umfassende Anleitung zur Übersetzung der OpenFool Spielmechaniken (Durak-Kartenspiel) von Kotlin/libGDX nach Lua/Love2D.

---

## Inhaltsverzeichnis

1. [Spielarchitektur Übersicht](#spielarchitektur-übersicht)
2. [Kern-Spielzustand Management](#kern-spielzustand-management)
3. [Kartensystem](#kartensystem)
4. [Deck-Management](#deck-management)
5. [Spieler-KI System](#spieler-ki-system)
6. [Spielfluss-Kontrolle](#spielfluss-kontrolle)
7. [Rendering-System (Love2D)](#rendering-system-love2d)
8. [Regelset-Konfiguration](#regelset-konfiguration)
9. [Wichtige Unterschiede](#wichtige-unterschiede)
10. [Empfohlene Bibliotheken](#empfohlene-bibliotheken)

---

## Spielarchitektur Übersicht

OpenFool ist eine Implementierung des russischen Kartenspiels "Durak" (Narr). Die Hauptkomponenten:

- **GameScreen**: Haupt-Spiellogik und Rendering
- **Player**: KI-Logik und Handverwaltung
- **Card/Deck**: Kartenrepräsentation und -verwaltung
- **RuleSet**: Konfigurierbare Spielregeln
- **verschiedene Screens**: MainMenu, Settings, Result

---

## 1. Kern-Spielzustand Management

### Original (Kotlin)

```kotlin
enum class GameState {
    READY,      // Bereit für nächste Aktion
    DRAWING,    // Karten werden gezogen
    THROWING,   // Karte wird geworfen (Animation)
    THROWN,     // Karte wurde geworfen
    BEATING,    // Karte wird geschlagen (Animation)
    BEATEN,     // Karte wurde geschlagen
    FINISHED    // Runde beendet
}

private var gameState = DRAWING
private var oldGameState = FINISHED
```

### Love2D Translation

```lua
-- Spielzustands-Enum
GameState = {
    READY = "ready",
    DRAWING = "drawing",
    THROWING = "throwing",
    THROWN = "thrown",
    BEATING = "beating",
    BEATEN = "beaten",
    FINISHED = "finished"
}

-- Globale Spielstruktur
game = {
    state = GameState.READY,
    oldState = GameState.FINISHED,
    
    -- Zustandswechsel mit Callback
    setState = function(self, newState)
        if self.state ~= newState then
            self.oldState = self.state
            self.state = newState
            print("State changed: " .. self.oldState .. " -> " .. self.state)
            
            -- Optional: Callback für Zustandsänderungen
            if self.onStateChanged then
                self:onStateChanged(self.state, self.oldState)
            end
        end
    end
}

-- Verwendung
game:setState(GameState.THROWING)
```

---

## 2. Kartensystem

### Original Struktur

**Suit.kt:**
```kotlin
enum class Suit(val value: Int) {
    SPADES(0),
    DIAMONDS(1),
    CLUBS(2),
    HEARTS(3)
}
```

**Rank.kt:**
```kotlin
enum class Rank(val value: Int) {
    ACE(1), TWO(2), THREE(3), ..., KING(13)
}
```

**Card.kt:**
```kotlin
class Card(internal val suit: Suit, internal val rank: Rank) {
    internal fun beats(other: Card, trumpSuit: Suit, deuceBeatsAce: Boolean): Boolean {
        val thisRankValue = (this.rank.value + 11) % 13
        val otherRankValue = (other.rank.value + 11) % 13
        
        if (this.suit === other.suit) {
            return thisRankValue >= otherRankValue || 
                   (deuceBeatsAce && thisRankValue == 0 && otherRankValue == 12)
        } else {
            return this.suit === trumpSuit
        }
    }
}
```

### Love2D Translation

```lua
-- Suit Enum (Farben)
Suit = {
    SPADES = 0,     -- Pik
    DIAMONDS = 1,   -- Karo
    CLUBS = 2,      -- Kreuz
    HEARTS = 3      -- Herz
}

-- Rang Enum
Rank = {
    ACE = 1,
    TWO = 2,
    THREE = 3,
    FOUR = 4,
    FIVE = 5,
    SIX = 6,
    SEVEN = 7,
    EIGHT = 8,
    NINE = 9,
    TEN = 10,
    JACK = 11,
    QUEEN = 12,
    KING = 13
}

-- Karten-Konstruktor (Factory-Funktion)
function createCard(suit, rank)
    local card = {
        suit = suit,
        rank = rank
    }
    
    -- Methode: Schlägt diese Karte eine andere?
    function card:beats(other, trumpSuit, deuceBeatsAce)
        local thisRankValue = (self.rank + 11) % 13
        local otherRankValue = (other.rank + 11) % 13
        
        if self.suit == other.suit then
            -- Gleiche Farbe: höherer Rang gewinnt
            return thisRankValue >= otherRankValue or 
                   (deuceBeatsAce and thisRankValue == 0 and otherRankValue == 12)
        else
            -- Unterschiedliche Farbe: nur Trumpf schlägt
            return self.suit == trumpSuit
        end
    end
    
    -- String-Repräsentation für Debugging
    function card:toString()
        local suits = {'s', 'd', 'c', 'h'}
        return self.rank .. suits[self.suit + 1]
    end
    
    -- Gleichheit prüfen
    function card:equals(other)
        return self.suit == other.suit and self.rank == other.rank
    end
    
    return card
end

-- Hilfsfunktion: Karte in Hand finden
function findCardInHand(hand, card)
    for i, c in ipairs(hand) do
        if c:equals(card) then
            return i
        end
    end
    return nil
end
```

---

## 3. Deck-Management

### Original Logic (Kotlin)

```kotlin
internal class Deck(private val lowestRank: Rank = Rank.TWO) {
    var cards: ArrayList<Card>? = null
    
    init {
        this.cards = ArrayList()
        this.reset()
        this.shuffle()
    }
    
    private fun reset() {
        this.cards!!.clear()
        for (r in Rank.values())
            for (s in Suit.values())
                if (r >= lowestRank || r == Rank.ACE)
                    cards!!.add(Card(s, r))
    }
    
    private fun shuffle() {
        val random = SecureRandom()
        cards!!.shuffle(random)
    }
    
    fun draw(): Card? {
        return try {
            cards!!.removeAt(cards!!.size - 1)
        } catch (e: IndexOutOfBoundsException) {
            null
        }
    }
}
```

### Love2D Translation

```lua
-- Deck-Konstruktor
function createDeck(lowestRank)
    lowestRank = lowestRank or Rank.TWO
    
    local deck = {
        cards = {}
    }
    
    -- Karten erstellen (52 Karten oder abgestreifte Decks)
    local function reset()
        deck.cards = {}
        
        -- Für jeden Rang und jede Farbe
        for rank = Rank.ACE, Rank.KING do
            for suit = Suit.SPADES, Suit.HEARTS do
                -- Füge Karte hinzu wenn Rang >= lowestRank ODER Ass
                if rank >= lowestRank or rank == Rank.ACE then
                    table.insert(deck.cards, createCard(suit, rank))
                end
            end
        end
    end
    
    -- Fisher-Yates Shuffle Algorithmus
    local function shuffle()
        for i = #deck.cards, 2, -1 do
            local j = love.math.random(1, i)
            deck.cards[i], deck.cards[j] = deck.cards[j], deck.cards[i]
        end
    end
    
    -- Karte ziehen (von unten/Ende des Arrays)
    function deck:draw()
        if #self.cards > 0 then
            return table.remove(self.cards)
        end
        return nil
    end
    
    -- Verbleibende Kartenanzahl
    function deck:remaining()
        return #self.cards
    end
    
    -- Initialisierung
    reset()
    shuffle()
    
    return deck
end

-- Verwendungsbeispiel
local myDeck = createDeck(Rank.SIX)  -- 36-Karten-Deck
print("Deck hat " .. myDeck:remaining() .. " Karten")

local card = myDeck:draw()
if card then
    print("Gezogene Karte: " .. card:toString())
end
```

---

## 4. Spieler-KI System

Dies ist der komplexeste Teil. Die KI verwendet Handwert-Bewertung zur Entscheidungsfindung.

### Hand-Bewertung (Hand Value Evaluation)

```lua
-- Relativer Kartenwert basierend auf Deck-Zusammensetzung
function getRelativeCardValue(rankValue, lowestRank)
    lowestRank = lowestRank or Rank.TWO
    local ranksInPlay = (14 - lowestRank) % 13 + 1
    local maxValue = ranksInPlay / 2.0
    
    if rankValue == Rank.ACE then
        return maxValue
    else
        return rankValue + maxValue - 14
    end
end

-- Hauptfunktion zur Bewertung einer Hand
function evaluateHand(hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
    local RANK_MULTIPLIER = 100
    local UNBALANCED_PENALTY = 200
    local MANY_CARDS_PENALTY = 600
    local OUT_OF_PLAY = 30000
    
    -- Wenn keine Karten im Deck und keine in der Hand: aus dem Spiel
    if cardsRemaining == 0 and #hand == 0 then
        return OUT_OF_PLAY
    end
    
    local score = 0
    local countsByRank = {}
    local countsBySuit = {}
    
    -- Initialisiere Zähler
    for i = 1, 13 do
        countsByRank[i] = 0
    end
    for i = 0, 3 do
        countsBySuit[i] = 0
    end
    
    -- Zähle Karten und berechne Basis-Score
    for _, card in ipairs(hand) do
        local relativeValue = getRelativeCardValue(card.rank, lowestRank)
        score = score + math.floor(relativeValue * RANK_MULTIPLIER)
        
        -- Bonus für Trumpfkarten
        if card.suit == trumpSuit then
            score = score + 13 * RANK_MULTIPLIER
        end
        
        countsByRank[card.rank] = countsByRank[card.rank] + 1
        countsBySuit[card.suit] = countsBySuit[card.suit] + 1
    end
    
    -- Bonuspunkte für mehrere Karten desselben Rangs
    -- (gut für Werfen und Verteidigung)
    local bonuses = {0, 0, 0.5, 0.75, 1.25}
    for rank = 1, 13 do
        if countsByRank[rank] > 0 then
            local bonus = bonuses[math.min(countsByRank[rank] + 1, 5)]
            score = score + math.floor(math.max(getRelativeCardValue(rank, lowestRank), 1.0) * bonus)
        end
    end
    
    -- Strafe für unausgeglichene Farben (außer Trumpf)
    local avgSuit = 0
    for _, card in ipairs(hand) do
        if card.suit ~= trumpSuit then
            avgSuit = avgSuit + 1
        end
    end
    avgSuit = avgSuit / 3.0
    
    for suit = Suit.SPADES, Suit.HEARTS do
        if suit ~= trumpSuit and avgSuit > 0 then
            local deviation = math.abs((countsBySuit[suit] - avgSuit) / avgSuit)
            score = score - math.floor(UNBALANCED_PENALTY * deviation)
        end
    end
    
    -- Strafe für zu viele Karten (schwerer loszuwerden)
    local cardsInPlay = cardsRemaining
    for _, handSize in ipairs(playerHands) do
        cardsInPlay = cardsInPlay + handSize
    end
    cardsInPlay = cardsInPlay - #hand
    
    local cardRatio = (cardsInPlay ~= 0) and (#hand / cardsInPlay) or 10.0
    score = score + math.floor((0.25 - cardRatio) * MANY_CARDS_PENALTY)
    
    return score
end
```

### KI Angriff (Start Turn)

```lua
function aiStartTurn(player, trumpSuit, cardsRemaining, playerHands, lowestRank)
    local bonuses = {0, 0, 1.0, 1.5, 2.5}
    local countsByRank = {}
    
    -- Initialisiere
    for i = 1, 13 do
        countsByRank[i] = 0
    end
    
    -- Zähle Ränge
    for _, card in ipairs(player.hand) do
        countsByRank[card.rank] = countsByRank[card.rank] + 1
    end
    
    local maxVal = -math.huge
    local cardIdx = -1
    
    -- Evaluiere jede mögliche Karte zum Werfen
    for i, card in ipairs(player.hand) do
        -- Simuliere Hand ohne diese Karte
        local newHand = {}
        for j, c in ipairs(player.hand) do
            if j ~= i then
                table.insert(newHand, c)
            end
        end
        
        -- Berechne Wert der neuen Hand plus Bonus für diese Karte
        local bonus = bonuses[math.min(countsByRank[card.rank] + 1, 5)]
        local rankBonus = (card.rank == Rank.ACE) and 6 or (card.rank - 8)
        
        local newVal = evaluateHand(newHand, trumpSuit, cardsRemaining, playerHands, lowestRank) +
                       math.floor(bonus * rankBonus * RANK_MULTIPLIER)
        
        if newVal > maxVal then
            maxVal = newVal
            cardIdx = i
        end
    end
    
    -- Entferne und gebe beste Karte zurück
    if cardIdx > 0 then
        return table.remove(player.hand, cardIdx)
    end
    
    return nil
end
```

### KI Verteidigung (Try Beat)

```lua
function aiTryBeat(player, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank, deuceBeatsAce)
    local RANK_PRESENT_BONUS = 300
    local PENALTY = 800
    local TAKE_PENALTY_BASE = 2000
    local TAKE_PENALTY_DELTA = 40
    
    -- Sammle vorhandene Ränge auf dem Tisch
    local ranksPresent = {}
    for _, card in ipairs(attackCards) do
        if card then
            ranksPresent[card.rank] = true
        end
    end
    for _, card in ipairs(defenseCards) do
        if card then
            ranksPresent[card.rank] = true
        end
    end
    
    -- Finde die Angriffskarte, die geschlagen werden muss
    local attackIndex = nil
    for i, card in ipairs(defenseCards) do
        if not card then
            attackIndex = i
            break
        end
    end
    
    if not attackIndex or not attackCards[attackIndex] then
        return nil  -- Keine Karte zu schlagen
    end
    
    local attackCard = attackCards[attackIndex]
    
    -- Evaluiere jede Karte in der Hand
    local maxVal = -math.huge
    local cardIdx = -1
    
    for i, card in ipairs(player.hand) do
        if card:beats(attackCard, trumpSuit, deuceBeatsAce) then
            -- Simuliere Hand ohne diese Karte
            local newHand = {}
            for j, c in ipairs(player.hand) do
                if j ~= i then
                    table.insert(newHand, c)
                end
            end
            
            -- Bonus wenn Rang bereits auf Tisch (leichter loszuwerden)
            local bonus = ranksPresent[card.rank] and RANK_PRESENT_BONUS or 0
            
            local newVal = evaluateHand(newHand, trumpSuit, cardsRemaining, playerHands, lowestRank) + bonus
            
            if newVal > maxVal then
                maxVal = newVal
                cardIdx = i
            end
        end
    end
    
    -- Simuliere Hand wenn Spieler nimmt
    local handIfTake = {}
    for _, card in ipairs(player.hand) do
        table.insert(handIfTake, card)
    end
    for _, card in ipairs(attackCards) do
        if card then
            table.insert(handIfTake, card)
        end
    end
    for _, card in ipairs(defenseCards) do
        if card then
            table.insert(handIfTake, card)
        end
    end
    
    -- Entscheidung: Schlagen oder Nehmen?
    local currentValue = evaluateHand(player.hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
    local takeValue = evaluateHand(handIfTake, trumpSuit, cardsRemaining, playerHands, lowestRank)
    
    local shouldBeat = (currentValue - maxVal < PENALTY) or
                       (takeValue - maxVal < TAKE_PENALTY_BASE - TAKE_PENALTY_DELTA * cardsRemaining) or
                       (cardsRemaining == 0)
    
    if shouldBeat and cardIdx > 0 then
        return table.remove(player.hand, cardIdx)
    else
        return nil  -- Nimmt Karten
    end
end
```

### KI Nachwerfen (Throw or Done)

```lua
function aiThrowOrDone(player, attackCards, defenseCards, trumpSuit, cardsRemaining, playerHands, lowestRank)
    -- Sammle vorhandene Ränge
    local ranksPresent = {}
    for _, card in ipairs(attackCards) do
        if card then
            ranksPresent[card.rank] = true
        end
    end
    for _, card in ipairs(defenseCards) do
        if card then
            ranksPresent[card.rank] = true
        end
    end
    
    local bonuses = {0, 0, 1.0, 1.5, 2.5}
    local countsByRank = {}
    
    for i = 1, 13 do
        countsByRank[i] = 0
    end
    
    for _, card in ipairs(player.hand) do
        countsByRank[card.rank] = countsByRank[card.rank] + 1
    end
    
    local maxVal = -math.huge
    local cardIdx = -1
    
    -- Finde beste Karte zum Werfen (muss vorhandenen Rang haben)
    for i, card in ipairs(player.hand) do
        if ranksPresent[card.rank] then
            local newHand = {}
            for j, c in ipairs(player.hand) do
                if j ~= i then
                    table.insert(newHand, c)
                end
            end
            
            local bonus = bonuses[math.min(countsByRank[card.rank] + 1, 5)]
            local rankBonus = (card.rank == Rank.ACE) and 6 or (card.rank - 8)
            
            local newVal = evaluateHand(newHand, trumpSuit, cardsRemaining, playerHands, lowestRank) +
                           math.floor(bonus * rankBonus * RANK_MULTIPLIER)
            
            if newVal > maxVal then
                maxVal = newVal
                cardIdx = i
            end
        end
    end
    
    -- Entscheidung: Werfen oder Fertig?
    local PENALTY_BASE = 1200
    local PENALTY_DELTA = 50
    
    local currentValue = evaluateHand(player.hand, trumpSuit, cardsRemaining, playerHands, lowestRank)
    
    if (currentValue - maxVal < PENALTY_BASE - PENALTY_DELTA * cardsRemaining) and cardIdx > 0 then
        return table.remove(player.hand, cardIdx)
    else
        return nil  -- Sagt "Fertig"
    end
end
```

---

## 5. Spielfluss-Kontrolle

### Spieler-Struktur

```lua
function createPlayer(name, index, ruleSet)
    return {
        name = name,
        index = index,
        hand = {},
        outOfPlay = false,
        saidDone = false,
        
        -- Karte zur Hand hinzufügen
        addCard = function(self, card)
            table.insert(self.hand, card)
        end,
        
        -- Hand sortieren
        sortCards = function(self, sortingMode, trumpSuit)
            if sortingMode == "unsorted" then
                return
            end
            
            table.sort(self.hand, function(c1, c2)
                local v1 = (c1.suit + (3 - trumpSuit)) % 4
                local v2 = (c2.suit + (3 - trumpSuit)) % 4
                local r1 = (c1.rank + 11) % 13
                local r2 = (c2.rank + 11) % 13
                
                if sortingMode == "suit_asc" then
                    if v1 ~= v2 then return v1 < v2 end
                    return r1 < r2
                elseif sortingMode == "suit_desc" then
                    if v1 ~= v2 then return v1 > v2 end
                    return r1 > r2
                elseif sortingMode == "rank_asc" then
                    if r1 ~= r2 then return r1 < r2 end
                    return v1 < v2
                elseif sortingMode == "rank_desc" then
                    if r1 ~= r2 then return r1 > r2 end
                    return v1 > v2
                end
                
                return false
            end)
        end
    }
end
```

### Runden-Ende Logik

```lua
function endTurn(playerIndex, attackCards, defenseCards, players, deck, discardPile)
    -- Sammle alle Tischkarten
    local tableCards = {}
    
    for _, card in ipairs(attackCards) do
        if card then
            table.insert(tableCards, card)
        end
    end
    
    for _, card in ipairs(defenseCards) do
        if card then
            table.insert(tableCards, card)
        end
    end
    
    -- Verteile Karten
    if playerIndex < 0 then
        -- Karten gehen auf Ablagestapel (erfolgreich verteidigt)
        for _, card in ipairs(tableCards) do
            table.insert(discardPile, card)
        end
    else
        -- Spieler nimmt Karten (nicht verteidigt)
        for _, card in ipairs(tableCards) do
            players[playerIndex]:addCard(card)
        end
        
        -- Sortiere Hand nach Aufnahme
        players[playerIndex]:sortCards("suit_asc", trumpSuit)
    end
    
    -- Ziehe Karten nach (wenn Deck nicht leer)
    if deck:remaining() > 0 then
        for _, player in ipairs(players) do
            local cardsToDraw = 6 - #player.hand
            
            for j = 1, cardsToDraw do
                local card = deck:draw()
                if not card then
                    break
                end
                player:addCard(card)
            end
            
            -- Sortiere Hand nach Ziehen
            player:sortCards("suit_asc", trumpSuit)
            
            if deck:remaining() == 0 then
                break
            end
        end
    end
    
    -- Prüfe ob Spieler aus dem Spiel sind
    if deck:remaining() == 0 then
        for _, player in ipairs(players) do
            if #player.hand == 0 and not player.outOfPlay then
                player.outOfPlay = true
                print(player.name .. " ist aus dem Spiel!")
            end
        end
    end
    
    -- Setze Tisch-Arrays zurück
    for i = 1, 6 do
        attackCards[i] = nil
        defenseCards[i] = nil
    end
    
    -- Setze Spieler-Status zurück
    for _, player in ipairs(players) do
        player.saidDone = false
    end
end
```

### Spielende-Prüfung

```lua
function isGameOver(players, teamPlay)
    if teamPlay then
        -- Team-Modus: Prüfe ob ein ganzes Team aus dem Spiel ist
        -- Team 1: Spieler 0 und 2
        -- Team 2: Spieler 1 und 3
        local team1Out = players[1].outOfPlay and players[3].outOfPlay
        local team2Out = players[2].outOfPlay and players[4].outOfPlay
        
        return team1Out or team2Out
    else
        -- Einzelmodus: Spiel endet wenn nur noch 1 Spieler übrig
        local activePlayers = 0
        
        for _, player in ipairs(players) do
            if not player.outOfPlay then
                activePlayers = activePlayers + 1
            end
        end
        
        return activePlayers <= 1
    end
end

function determineWinner(players, teamPlay)
    if teamPlay then
        if players[1].outOfPlay and players[3].outOfPlay then
            return "team2"  -- Team 2 gewinnt
        else
            return "team1"  -- Team 1 gewinnt
        end
    else
        -- Finde den letzten verbleibenden Spieler (der Verlierer)
        for i, player in ipairs(players) do
            if not player.outOfPlay then
                return i  -- Dieser Spieler hat verloren
            end
        end
        
        -- Alle Spieler aus dem Spiel: Unentschieden
        return 0
    end
end
```

---

## 6. Rendering-System (Love2D)

### Ressourcen Laden

```lua
function love.load()
    -- Kartenbilder
    cardImages = {}
    
    -- Lade alle Karten (1-13 für jeden Suit)
    for suit = 0, 3 do
        local suitChar = ({'s', 'd', 'c', 'h'})[suit + 1]
        
        for rank = 1, 13 do
            local path = string.format("assets/decks/rus/%d%s.png", rank, suitChar)
            cardImages[rank .. suitChar] = love.graphics.newImage(path)
        end
    end
    
    -- Kartenrückseite
    cardImages.back = love.graphics.newImage("assets/decks/rus/back.png")
    
    -- Hintergrund
    background = love.graphics.newImage("assets/backgrounds/background1.png")
    
    -- Farb-Symbole
    suitSymbols = {
        [Suit.SPADES] = love.graphics.newImage("assets/suits/spades.png"),
        [Suit.DIAMONDS] = love.graphics.newImage("assets/suits/diamonds.png"),
        [Suit.CLUBS] = love.graphics.newImage("assets/suits/clubs.png"),
        [Suit.HEARTS] = love.graphics.newImage("assets/suits/hearts.png")
    }
    
    -- Font
    font = love.graphics.newFont("assets/fonts/8835.otf", 24)
    love.graphics.setFont(font)
end
```

### Karten Zeichnen

```lua
function drawCard(card, x, y, scale, faceUp, rotation, tint)
    scale = scale or 1.0
    rotation = rotation or 0
    tint = tint or {1, 1, 1, 1}
    
    local img
    if faceUp and card then
        img = cardImages[card:toString()]
    else
        img = cardImages.back
    end
    
    if img then
        love.graphics.setColor(tint)
        love.graphics.draw(img, x, y, rotation, scale, scale)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

-- Spieler-Hand zeichnen
function drawPlayerHand(player, x, y, scale, spacing, faceUp)
    for i, card in ipairs(player.hand) do
        local cardX = x + (i - 1) * spacing
        drawCard(card, cardX, y, scale, faceUp, 0)
    end
end

-- Tisch (Angriff/Verteidigung) zeichnen
function drawTable(attackCards, defenseCards, x, y, scale)
    local spacing = 90 * scale
    
    for i = 1, 6 do
        local cardX = x + (i - 1) * spacing
        
        -- Angriffskarte
        if attackCards[i] then
            drawCard(attackCards[i], cardX, y, scale, true, 0)
        end
        
        -- Verteidigungskarte (leicht versetzt)
        if defenseCards[i] then
            drawCard(defenseCards[i], cardX + 10 * scale, y - 10 * scale, scale, true, 0)
        end
    end
end
```

### Einfaches Animations-System

```lua
-- Tween-System für Kartenbewegung
Tweens = {}

function createTween(target, property, endValue, duration, onComplete)
    local tween = {
        target = target,
        property = property,
        startValue = target[property],
        endValue = endValue,
        duration = duration,
        elapsed = 0,
        onComplete = onComplete,
        completed = false
    }
    
    table.insert(Tweens, tween)
    return tween
end

function love.update(dt)
    -- Update alle Tweens
    for i = #Tweens, 1, -1 do
        local tween = Tweens[i]
        
        if not tween.completed then
            tween.elapsed = tween.elapsed + dt
            local t = math.min(tween.elapsed / tween.duration, 1)
            
            -- Easing: Smooth (ease-in-out)
            t = t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t
            
            tween.target[tween.property] = tween.startValue + (tween.endValue - tween.startValue) * t
            
            if t >= 1 then
                tween.completed = true
                
                if tween.onComplete then
                    tween.onComplete()
                end
                
                table.remove(Tweens, i)
            end
        end
    end
end

-- Verwendungsbeispiel
local cardVisual = {x = 100, y = 100}

createTween(cardVisual, "x", 500, 0.5, function()
    print("Animation abgeschlossen!")
end)
```

### Karten-Klick-Erkennung

```lua
function love.mousepressed(x, y, button)
    if button == 1 then  -- Linksklick
        -- Prüfe Spieler-Hand
        local player = players[1]  -- Menschlicher Spieler
        
        for i, card in ipairs(player.hand) do
            local cardX = playerHandX + (i - 1) * cardSpacing
            local cardY = playerHandY
            local cardW = cardWidth * cardScale
            local cardH = cardHeight * cardScale
            
            if x >= cardX and x <= cardX + cardW and
               y >= cardY and y <= cardY + cardH then
                -- Karte wurde geklickt
                onCardClicked(player, card, i)
                return
            end
        end
    end
end

function onCardClicked(player, card, index)
    if game.state == GameState.READY and currentAttacker == player then
        -- Spieler greift an
        if canThrowCard(card, attackCards, defenseCards) then
            throwCard(player, card, index)
        end
    elseif game.state == GameState.THROWN and currentDefender == player then
        -- Spieler verteidigt
        if canBeatCard(card, attackCards, defenseCards, trumpSuit) then
            beatCard(player, card, index)
        end
    end
end
```

---

## 7. Regelset-Konfiguration

```lua
RuleSet = {
    deuceBeatsAce = false,              -- Zwei schlägt Ass
    loweredFirstDiscardLimit = false,   -- Erster Abwurf auf 5 Karten limitiert
    allowPass = false,                  -- Weitergeben erlaubt
    playerCount = 4,                    -- Anzahl Spieler (2-5)
    teamPlay = true,                    -- Team-Modus (nur für 4/6 Spieler)
    cardCount = 52                      -- Karten im Deck (24, 32, 36, 52)
}

-- Niedrigster Rang basierend auf Kartenanzahl berechnen
function RuleSet:getLowestRank()
    return ((14 - (self.cardCount / 4)) % 13) + 1
end

-- Regelset speichern/laden
function RuleSet:save(filename)
    local data = love.filesystem.write(filename, table.concat({
        "deuceBeatsAce=" .. tostring(self.deuceBeatsAce),
        "loweredFirstDiscardLimit=" .. tostring(self.loweredFirstDiscardLimit),
        "allowPass=" .. tostring(self.allowPass),
        "playerCount=" .. tostring(self.playerCount),
        "teamPlay=" .. tostring(self.teamPlay),
        "cardCount=" .. tostring(self.cardCount)
    }, "\n"))
end

function RuleSet:load(filename)
    if love.filesystem.getInfo(filename) then
        local content = love.filesystem.read(filename)
        
        for line in content:gmatch("[^\n]+") do
            local key, value = line:match("(.+)=(.+)")
            
            if key == "deuceBeatsAce" or key == "loweredFirstDiscardLimit" or 
               key == "allowPass" or key == "teamPlay" then
                self[key] = (value == "true")
            elseif key == "playerCount" or key == "cardCount" then
                self[key] = tonumber(value)
            end
        end
    end
end
```

---

## 8. Vollständiges Spiel-Setup

```lua
function setupGame()
    -- Regelset
    local rules = RuleSet
    
    -- Spieler erstellen
    players = {}
    local playerNames = {"Du", "West", "Nord", "Ost"}
    
    for i = 1, rules.playerCount do
        players[i] = createPlayer(playerNames[i], i, rules)
    end
    
    -- Deck erstellen
    deck = createDeck(rules:getLowestRank())
    
    -- Trumpf bestimmen
    trumpCard = deck.cards[1]
    trumpSuit = trumpCard.suit
    
    print("Trumpf ist: " .. trumpCard:toString())
    
    -- Karten an Spieler verteilen
    for i = 1, rules.playerCount do
        for j = 1, 6 do
            local card = deck:draw()
            if card then
                players[i]:addCard(card)
            end
        end
        
        -- Hand sortieren
        players[i]:sortCards("suit_asc", trumpSuit)
    end
    
    -- Ersten Angreifer bestimmen (niedrigster Trumpf)
    local lowestTrump = Rank.ACE
    local firstAttacker = 1
    
    for i, player in ipairs(players) do
        for _, card in ipairs(player.hand) do
            if card.suit == trumpSuit then
                if card.rank ~= Rank.ACE and card.rank < lowestTrump or lowestTrump == Rank.ACE then
                    lowestTrump = card.rank
                    firstAttacker = i
                end
            end
        end
    end
    
    currentAttackerIndex = firstAttacker
    currentDefenderIndex = (firstAttacker % rules.playerCount) + 1
    
    print(players[firstAttacker].name .. " beginnt mit niedrigstem Trumpf: " .. lowestTrump)
    
    -- Tisch-Arrays
    attackCards = {}
    defenseCards = {}
    for i = 1, 6 do
        attackCards[i] = nil
        defenseCards[i] = nil
    end
    
    -- Ablagestapel
    discardPile = {}
    
    -- Spiel starten
    game:setState(GameState.READY)
end
```

---

## 9. Wichtige Unterschiede: Kotlin vs. Lua/Love2D

### Event-System

**Kotlin/libGDX:**
- Verwendet Actor-System mit Event-Listenern
- Events werden durch Hierarchie propagiert

**Love2D:**
- Verwendet Callback-Funktionen
- Direkte Funktionsaufrufe

```lua
-- Statt Events: Direkte Callbacks
function onCardThrown(player, card)
    print(player.name .. " wirft " .. card:toString())
    -- Logik hier
end
```

### Speicherverwaltung

**Kotlin:**
- Automatische Garbage Collection
- Objekt-Referenzen

**Lua:**
- Garbage Collection vorhanden
- Aber: Verwende weak tables für große Sammlungen

```lua
-- Weak table für Card Actors (verhindert Memory Leaks)
cardActors = setmetatable({}, {__mode = "v"})
```

### Delta Time

**Love2D verwendet Frame-unabhängige Updates:**

```lua
function love.update(dt)
    -- dt = Sekunden seit letztem Frame
    -- Alle Bewegungen/Animationen mit dt multiplizieren
    
    cardX = cardX + velocity * dt
end
```

### Bildschirm-Koordinaten

**libGDX:**
- Y-Achse zeigt nach oben (0 = unten)

**Love2D:**
- Y-Achse zeigt nach unten (0 = oben)

```lua
-- Koordinaten eventuell invertieren
local screenY = love.graphics.getHeight() - y
```

---

## 10. Empfohlene Love2D Bibliotheken

### UI-Komponenten
- **[Suit](https://github.com/vrld/SUIT)**: Einfache Immediate-Mode GUI
- **[LÖVE Frames](https://github.com/linux-man/LoveFrames)**: Retained-Mode GUI

```lua
-- Suit Beispiel
local suit = require 'suit'

function love.draw()
    suit.Button("Neues Spiel", 100, 100, 200, 40)
    if suit.Button("Einstellungen", 100, 150, 200, 40).hit then
        -- Button wurde geklickt
    end
end
```

### Animationen
- **[Flux](https://github.com/rxi/flux)**: Tween-Bibliothek
- **[Timer](https://github.com/vrld/hump/blob/master/timer.lua)**: Verzögerungen und Zeitgeber

```lua
local flux = require 'flux'

-- Karte bewegen
flux.to(card, 0.5, {x = 500, y = 300}):ease("quadout")
```

### Kollisionserkennung
- **[HC](https://github.com/vrld/HC)**: 2D Collision Detection
- **[Bump](https://github.com/kikito/bump.lua)**: AABB Collision

```lua
local bump = require 'bump'

world = bump.newWorld()
world:add(card, cardX, cardY, cardW, cardH)

-- Klick-Test
local items = world:queryPoint(mouseX, mouseY)
```

### State Management
- **[HUMP.gamestate](https://github.com/vrld/hump/blob/master/gamestate.lua)**: Screen-Management

```lua
local Gamestate = require 'hump.gamestate'

local menu = {}
local game = {}

function menu:draw()
    -- Menü zeichnen
end

Gamestate.switch(menu)
```

---

## Zusammenfassung

### Kernschritte zur Übersetzung:

1. **Datenstrukturen konvertieren**: Enums → Tables, Classes → Factory Functions
2. **Event-System ersetzen**: Events → Direct Callbacks
3. **KI-Logik portieren**: Hand-Evaluation Algorithmen direkt übertragen
4. **Rendering anpassen**: libGDX Scene2D → Love2D draw() Funktionen
5. **Input-Handling**: Touch/Click Events → love.mousepressed()
6. **Assets organisieren**: Alle Bilder/Fonts in assets/ Ordner

### Empfohlene Projekt-Struktur:

```
openfool-love2d/
├── main.lua                 # Einstiegspunkt
├── conf.lua                 # Love2D Konfiguration
├── assets/
│   ├── decks/
│   │   └── rus/            # Kartenbilder
│   ├── backgrounds/
│   └── fonts/
├── src/
│   ├── card.lua            # Karten-Logik
│   ├── deck.lua            # Deck-Verwaltung
│   ├── player.lua          # Spieler & KI
│   ├── ai.lua              # KI-Algorithmen
│   ├── ruleset.lua         # Regelkonfiguration
│   └── game.lua            # Haupt-Spiellogik
└── lib/                    # Externe Bibliotheken
    ├── flux.lua
    └── suit.lua
```

Mit dieser Anleitung können Sie die komplette Spielmechanik von OpenFool nach Lua/Love2D übertragen!
