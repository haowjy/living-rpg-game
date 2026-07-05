# Growth and Power

Growth supports the story of rising faster than ordinary people in a collapsing world. The player's rise is multi-channel: mana cultivation rank, personal strength, allies, reputation, territory, institutional leverage, and player-made techniques born from lived events.

## Mana Rank (Cultivation)

The core progression axis. Mana rank represents the player's cultivated power — their ability to channel and shape mana through techniques. Rank advances through tiered breakthroughs, not XP accumulation.

### Rank Tiers

Each tier requires accumulated insights (from lived experience, manuals, or player-written reflections) and a breakthrough challenge — a trial, revelation, or crisis that tests whether the player has internalized what they've learned.

Rank names TBD (could be numbered stages, named tiers like Initiate/Adept/Master/Sage, or something world-specific). The mechanical effect: higher rank unlocks stronger technique compositions, increases mana capacity, and opens new primitive combinations during insight validation.

### Insight Sources

| Source | How it works |
|---|---|
| Lived experience | Events with narrative weight generate insights automatically (existing pipeline) |
| Manuals | Discoverable technique scrolls, martial arts texts, meditation guides — studied to gain structured insights |
| Player-written | Free text reflections combining manual knowledge with lived experience — the player articulates their own understanding |

Manuals are found in the world (looted from enemies, bought from merchants, discovered in ruins, gifted by masters). A manual alone gives partial insight — the player must also have relevant experience to fully internalize it. A swordsmanship manual means more to someone who has fought than to someone who hasn't.

## Power Types

Combat strength matters, but the sandbox fantasy gets stronger when power also means people, places, resources, and legitimacy.

| Power | What it lets the player do |
|---|---|
| Personal strength | Survive dangerous sites, duel rivals, take risks others cannot |
| Reputation | Open doors, attract followers, frighten enemies, shift rumors |
| Allies | Run missions, hold sites, provide skills, create personal story arcs |
| Resources | Feed people, pay troops, craft gear, rebuild territory |
| Territory | Make the map physically reflect the player's rise |
| Legitimacy | Move from adventurer to recognized leader, founder, or ruler |

## Team Building

The first "building" system is recruiting and retaining people. A party can become a company; a company can become a faction; a faction can hold territory.

Companions have loyalty, fear, ambition, ideology, injury, memory, and personal threads. They are not passive followers — they react to the player's choices, and their stories can diverge or conflict with the player's goals.

## Territory

Territory starts small and becomes visible. Claiming a shrine, mill, camp, watchtower, or ruined fort is more legible than an abstract faction score.

Local control changes what rumors spread, who patrols roads, who collects taxes, who gets protected, and who resents the player.

## Insight Spellcraft

The signature system: players make their own spells from the story they lived.

> Every run can produce spells, techniques, and doctrines that no other player found, because no other player lived the same history.

The pipeline:

1. **Event** — Something meaningful happens (survived an ambush, spared an enemy, founded a company, meditated in a ruin).
2. **Insight** — The game distills what the player experienced into a named insight.
3. **Proposal** — The LLM builds a technique from the insight, proposing a name, story logic, and mechanical shape.
4. **Validation** — The tools compile the proposal into legal mechanics (primitives like dash, shield, mark, fear, morale buff) and reject anything that violates balance or world rules.
5. **Legend** — The technique becomes part of the player's ability list and their story.

### Examples

| Source event | Proposed technique | Validated mechanics |
|---|---|---|
| Survived an ash wolf ambush | Ash Wolf Step | Dash, afterimage, flanking bonus |
| Spared a Red Sash bandit after taking the mill | Red Sash Binding | Mark enemy, fear check, surrender pressure |
| Founded a company under a burned banner | Oath-Flame Standard | Ally morale buff, formation aura, reputation tag |
| Meditated in a ruined shrine after betrayal | Shrine-Breath Vow | Shield, focus recovery, oath-triggered penalty |

### Primitives

Techniques are assembled from a vocabulary of mechanical primitives:

Dash, damage, push, pull, shield, bind, mark, reveal, summon, terrain change, morale buff, fear pressure, reputation shift, faction aura, dialogue unlock, oath condition, cooldown, range, cost, tier, escalation risk.

The LLM proposes creative combinations. The tools validate cost, tier, cooldown, balance, and world consistency before a technique becomes real. V0 uses a small point budget so generated techniques are creative in name and origin but bounded in mechanics; see [V0 Implementation Spec](implementation-spec.md).
