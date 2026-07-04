# Quests and Threads

Quests are living story threads attached to areas, factions, and events. They are how the player sees story pressure become playable. A quest can begin from an NPC, a rumor, a faction order, a personal favor, an ambush, or a story-sifting promotion.

A good quest is a contested situation with stakeholders, locations, visibility, and consequences.

## Quest Shape

A quest file captures the thread's current state, connections, and possible outcomes:

```
# Reclaim the North Mill

**Type:** Local conflict
**Status:** Active
**Primary area:** North Mill
**Origin:** Greyford Market

## Involved areas
- Greyford Market
- North Mill
- Red Sash Camp

## Involved factions
- Vael Lordship
- Red Sash Bandits
- Greyford Millers
- Church of the Seal

## Stakes
- Food supply for Greyford
- Public order and lord's legitimacy
- Player reputation
- Faction balance of power

## Possible resolutions
- Bandits destroyed — lordship strengthened
- Bandits recruited — player gains a fighting force
- Mill returned to villagers — popular support, lord embarrassed
- Lord Vael claims credit — player loses standing with commoners
- Church claims credit — institutional power grows
- Player keeps the mill — first territorial claim
```

## Two Browsing Axes

Quests and areas answer different questions about the same events:

| Axis | Question | Example |
|---|---|---|
| Area (`areas/north-mill/`) | What is happening at this physical place? | Control, damage, NPCs present, recent events, danger |
| Quest (`quests/reclaim-north-mill.md`) | What story thread connects these events? | Stakes, beats, branches, consequences, involved factions |

## Promotion Rules

Not every event becomes a quest. The story system promotes an event pattern into a quest thread when it has:

- **Recurrence** — The pattern has happened more than once.
- **Stakes** — Something meaningful is at risk.
- **Actors** — Named characters or factions are involved.
- **Future choices** — The player has plausible options ahead.

**Promote:** The player spares a bandit, food shortage rises, bandits control the mill, and the lordship is weak. This becomes a recruitment, rebellion, or legitimacy thread.

**Leave as flavor:** A one-off merchant comment with no area, actor, consequence, or future pressure stays as atmosphere or a low-weight rumor.
