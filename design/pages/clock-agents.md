# Clock and Agents

The world moves in layers: coarse global events, regional pressure, town clocks, and rich local agents where the player is close enough to matter.

## Layered World Clock

Simulation detail scales with proximity to the player. Distant events tick coarsely; the player's immediate area runs at full richness.

| Layer | Granularity | Examples |
|---|---|---|
| Global | Low | Wars declared, dynasties fracture, major doctrine changes, distant city falls |
| Regional | Medium | Refugees arrive, roads close, bandits expand, monster migration begins |
| Town/city | Higher | Prices shift, guards crack down, rumors spread, local factions recruit |
| Active local area | Rich | Named NPCs scheme, argue, move, confront, invite, betray, recruit |

Global and regional events create the pressure that drives local story. A distant war produces refugees; refugees create food pressure in Greyford; food pressure makes the mill dispute matter.

## Named NPC Agents

Important named characters are active agents with goals, memory, relationships, plans, and the ability to act. Each NPC agent uses the character-sim pattern from the creative-writing-skills plugin — the LLM speaks in character from the NPC's knowledge, voice, and emotional state.

| Agent | Story function |
|---|---|
| Mara, Guild Clerk | Quest broker, reputation witness, practical local memory |
| Tomas, Rival Adventurer | Peer pressure, competition, humiliation, possible ally or enemy |
| Sister Elian | Church pressure, healing, moral suspicion, institutional leverage |
| Lord Vael | Local ruler, order, legitimacy, threat response |
| Red Sash Captain | Bandit power, alternate recruitment path, anti-lordship pressure |
| Mei the Exile | Early companion with her own agenda and loyalty arc |

Each agent follows the cycle: **goal → memory → relationship → plan → action → consequence**.

Characters who are not important enough for full agent treatment exist as lightweight state — a name, a role, and a few facts — until the story promotes them.

## Background Actions

Agents act during wait, travel, rest, and world ticks. Their actions produce events, not just atmosphere.

- Move to a new area.
- Spread or suppress a rumor.
- Invite or confront the player.
- Recruit another NPC.
- Claim credit for an outcome.
- Shift faction resources or control.

These actions feed back into the event log, creating new pressure that the story system can surface.

## Simulation Limits

> PoC target: 3-6 named agents in one county. A fully simulated continent is out of scope.

Start with the minimum viable agent set. Add agents when the story needs them, not in advance.
