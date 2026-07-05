# Overview

A living fantasy sandbox where story is the primary attractor: start as nobody in a volatile world, learn techniques, survive pressure, and make power your own.

## Primary Pitch

**Start as nobody. Learn forms. Survive the chaos. Change what your techniques become.**

The game is a story-first sandbox set in a volatile fantasy age: petty kingdoms, warlords, churches, guilds, bandits, monsters, shrines, ruins, and desperate towns are all moving at once. The player rises faster than ordinary people because chaos creates opportunities — ruins to explore, factions to exploit, allies to recruit, villages to save, roads to control, and power vacuums to fill.

The main sell is a world that remembers what the player does and uses that remembered history later: in NPC reactions, rumors, faction changes, technique evolutions, and shrine breakthroughs.

## Core Loop

1. **Survive** — Arrive weak in a dangerous region.
2. **Explore** — Move through towns, roads, ruins, nests, shrines.
3. **Learn** — Find manuals, teachers, enemy forms, relics, and techniques.
4. **Practice** — Gain proficiency by using, drilling, or studying techniques.
5. **Evolve** — At mastery thresholds, combine references and history into new technique branches.
6. **Break through** — At shrines, upgrade the player's base path, element, bonuses, or weirdness ceiling.
7. **Shape history** — The world records and reacts to the player's rise.

The loop is self-directed. The player chooses goals, takes risks, and lives with consequences. The world provides pressure and opportunity; the player provides direction.

## Technique Mastery

The technique system is not an automatic event-reward pipeline.

Events are context. Training is simple. Evolution is chosen.

A player learns a form from a manual, teacher, enemy, relic, or shrine. Proficiency rises through use and practice. Once the technique is mastered enough, the player can evolve it by referencing another technique, a manual passage, a strange book, a shrine, a memory, or a line they write themselves. The LLM reads those references alongside the player's history and proposes new forms. Tools validate the mechanics.

> Every run can produce techniques no other player found, because no other player used the same forms, survived the same pressures, chose the same references, or broke through at the same shrines.

See [Growth & Power](#growth-power) for the full progression model.

## Combat Direction

V0 uses narrative turn resolution: the player describes actions, and the system resolves outcomes against stats, skills, position, techniques, party state, enemy state, and scene pressure.

V1 should move toward visual turn-based party combat rather than real-time action. Darkest Dungeon is the closest reference: readable turns, party positions, stress, injuries, marks, status effects, named techniques, and tactical consequences.

The LLM adds meaning around combat — dialogue, morale, history references, consequences, and technique evolution — while deterministic rules own turn order, damage, status, target legality, and proficiency gain.

## What "Building" Means

The thing being built is the player themselves first: stats, skills, techniques, reputation, relationships, shrine path, and understanding of the world. Growth can then expand outward into party, faction, territory, and legitimacy.

1. Helpless newcomer — weak stats, no reliable techniques, no reputation.
2. Capable survivor — core skills improving, first learned forms becoming reliable.
3. Known quantity — reputation spreading, NPCs react to the player's history.
4. Specialist or generalist — deep technique mastery or broad skill coverage.
5. Regional force — personal power and reputation reshape local events.

Relationships are a growth channel, not a requirement. Players who want allies, factions, and political leverage can pursue them. Players who want to solo the world as a wandering swordsman can do that too.

## Volatile Era

The world is unstable by default. Think Three Kingdoms energy — medieval micro-states, border wars, opportunistic warlords, splintering institutions, and dangerous frontiers.

Chaos is the opportunity engine that lets the player grow faster than everyone else. War creates power vacuums. Famine creates leverage. Monster pressure creates reputation. Institutional fracture creates narrative control.

## PoC Scope

The proof-of-concept is a meridian package — a set of agents and skills that run on open platforms. It proves map movement, location-scoped context, persistent event memory, world-clock pressure, named NPC agents, technique proficiency, technique evolution, shrine breakthroughs, and a story system that generates scenes from local pressure.

See [Prototype Plan](#prototype) for the full PoC plan and success criteria.