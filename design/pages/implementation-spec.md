# First Slice Implementation Spec

This document defines the contracts needed to prove the presentation-first,
Oracle-directable game. It does not choose a final engine or require a complete
story Oracle.

## Success condition

One small location, one request, one Dungeon expedition, one deterministic
battle, and one personalized upgrade must form a coherent 20–30 minute play
sequence. The same scene can be driven by an authored script or a structured
LLM request without giving either direct access to state or presentation
internals.

## Scope

### Required

- Mobile-capable 2D/2.5D exploration and dialogue presentation.
- One settlement exterior, one interior, and one Dungeon theme.
- Player plus 4–5 named people.
- Commands, canonical events, seeded randomness, save/load, and replay.
- Time passage, schedules, knowledge, memories, requests, and commitments.
- Deterministic turn-based combat with a fallback enemy controller.
- Effects, elements, statuses, modifiers, several techniques, and one weapon.
- One technique evolution or weapon reforge through a validated proposal.
- Director console, state inspector, event viewer, and LLM trace.

### Deferred

- A large autonomous Oracle.
- A simulated continent or full economy.
- Multiple Dungeon themes and final regeneration rules.
- Spirits, pet collection, or spirit-centered combat.
- Large-scale faction and territory management.
- Final framework commitment.

## Runtime boundary

```text
input controller
  player | script | deterministic AI | LLM adapter
                         |
                         v
                 command validation
                         |
                         v
              deterministic simulation
                         |
                         v
                  canonical events
                   /           \
                  v             v
          presentation       world memory
```

Controllers express intent. The simulation decides what is legal and records
the result. Presentation reacts to accepted intent and canonical events.

## Core state

The storage implementation may be files, a database, or both. It must expose
inspectable, serializable records equivalent to:

```ts
interface GameState {
  version: number
  seed: string
  clock: WorldClock
  playerId: EntityId
  characters: Record<EntityId, CharacterState>
  areas: Record<EntityId, AreaState>
  dungeonDefinitions: Record<EntityId, DungeonDefinition>
  activeDungeon?: DungeonInstance
  items: Record<EntityId, ItemInstance>
  techniques: Record<EntityId, TechniqueState>
  requests: Record<EntityId, RequestState>
  commitments: Record<EntityId, CommitmentState>
  threads: Record<EntityId, ThreadState>
  combat?: CombatState
  eventCursor: number
}
```

Every entity has a stable ID. Every state change comes from a validated command
and emits one or more append-only events.

## Simulation commands

The first slice needs a small command set:

```text
move_character(character_id, destination_id)
advance_time(duration, reason)
interact(actor_id, target_id)
transfer_item(source_id, target_id, item_id, quantity)
record_request(request)
record_commitment(commitment)
share_information(source_id, recipient_id, event_or_rumor_id)
begin_dungeon(definition_id, seed)
spawn_monster(dungeon_id, spawn_zone_id)
begin_combat(participants)
submit_combat_action(actor_id, action)
record_training(character_id, technique_id, source)
evolve_technique(proposal)
reforge_weapon(proposal)
write_event(event)
```

Commands return a success result with emitted event IDs or a typed failure with
enough information for a controller to recover.

## Director commands

Director commands perform a scene without changing canonical facts:

```text
focus_camera(target_id)
speak(speaker_id, text, expression)
move_to(actor_id, destination_id)
face(actor_id, target_id)
emote(actor_id, cue)
play_animation(actor_id, animation_id)
offer_choices(choice_set)
show_effect(effect_id, targets)
begin_encounter(encounter_id)
transition_area(area_id, entry_id)
```

If a Director command implies movement, the presentation requests or consumes
an accepted simulation movement command. It may not teleport a canonical actor
for convenience.

## Events and knowledge

An event records time, location, actors, witnesses, visibility, factual
consequences, and references to the command that produced it.

```ts
interface GameEvent {
  id: EntityId
  time: WorldTime
  type: string
  locationId?: EntityId
  actorIds: EntityId[]
  witnessIds: EntityId[]
  visibility: "private" | "witnessed" | "public"
  summary: string
  consequences: Consequence[]
  refs: EntityId[]
}
```

Characters may react only to events they experienced, witnessed, received, or
legally inferred. The event log records world truth; character knowledge and
memory record their access to it.

## Requests and commitments

A request records who asked whom, what was asked, when, witnesses, and any
understood urgency. A commitment is separate and requires clear agreement.

The system never creates a player-facing task automatically. Time and events
determine whether the requested outcome occurred. The Oracle or fallback rules
decide whether the result deserves a later scene.

## Time and schedules

Movement, conversation, rest, crafting, training, and Dungeon exploration
consume deterministic amounts of time. Advancing time:

1. updates the clock;
2. executes eligible scheduled actions;
3. resolves delayed messages and travel;
4. updates Dungeon spawn eligibility;
5. emits consequential events;
6. checks whether an Oracle trigger point has been reached.

The first slice needs schedules only for its named cast.

## Dungeon generation

The overworld area is generated once and saved. A Dungeon instance is generated
from a definition and seed.

```ts
interface DungeonDefinition {
  id: EntityId
  theme: string
  danger: number
  terrainSetId: EntityId
  roomPieceIds: EntityId[]
  monsterTableId: EntityId
  spawnBudget: number
  requiredLandmarks: string[]
}
```

Generation must guarantee a reachable entrance, a traversable playable route,
legal spawn zones, and a valid exit. Routine monster spawning is deterministic
and respects population, terrain, distance, and cooldown constraints.

The regeneration lifecycle remains an open design decision. The first slice
may expose a debug option to reroll so alternatives can be evaluated.

## Combat resolution

Each turn follows a fixed sequence:

1. Calculate legal actions.
2. The active controller selects one.
3. Validate target, range, cost, cooldown, and conditions.
4. Apply effects in defined priority order.
5. Resolve reactions and triggered modifiers.
6. Update durations, resources, positions, and defeat state.
7. Emit combat events.
8. Advance to the next legal actor or end the encounter.

The fallback enemy controller uses readable priorities or utility scores. An
LLM battle controller receives only the legal-action set and returns one action
plus optional intent text. A timeout or invalid selection immediately falls
back without changing the battle seed.

## Effects, techniques, and weapons

Effects use a bounded vocabulary: damage, heal, move, guard, dodge, counter,
apply status, remove status, mark, reveal, push, pull, summon, and terrain
change. Elements and modifiers alter those effects through explicit ordering
rules.

A technique definition contains cost, targeting, range, cooldown, conditions,
effects, proficiency, and history. A weapon contains category, material,
quality, damage profile, affinities, modifier slots, upgrade budget, and
history.

Technique evolution and weapon reforging follow the same proposal flow:

1. Player chooses an eligible base and references.
2. Context builder retrieves relevant history.
3. LLM or authored generator proposes several options.
4. Validator compiles legal effects and rejects over-budget mechanics.
5. Player selects an accepted option.
6. Simulation records the new definition and event.

No accepted proposal may depend on mechanics that exist only in prose.

## Oracle adapters

The first slice defines interfaces for four optional LLM lanes:

| Lane | Input | Output | Fallback |
|---|---|---|---|
| Story Oracle | Local pressure, cast, memories, presentation limits | Scene proposal | Authored situation rule |
| Character interaction | Character state, knowledge, conversation | Dialogue and intent | Authored line/choice |
| Battle controller | Legal actions, visible battle state, intent | One legal action | Priority or utility AI |
| Growth Oracle | Base item/technique, references, history, budget | Upgrade proposals | Authored upgrade set |

Each adapter records model, prompt version, retrieved context IDs, response,
validation result, latency, and cost.

## First scenario

1. Player enters the settlement and speaks with a named person.
2. The person requests that the player carry information before a stated time.
3. The player agrees, refuses, or leaves the matter unresolved.
4. The player enters a generated Dungeon instead.
5. A legal monster spawn leads to deterministic combat.
6. Technique use produces proficiency history and loot includes a weapon or
   crafting material.
7. Time advances beyond the original request's useful window.
8. The player returns and meets someone who has legally learned the outcome.
9. An authored rule or Story Oracle stages the reaction through Director
   commands.
10. The player evolves a technique or reforges the weapon through a validated
    proposal.

## Verification

- `command-validation`: illegal mutations fail without partial state changes.
- `deterministic-replay`: the same snapshot, seed, and commands reproduce state
  and events.
- `director-parity`: console and external structured requests stage the same
  supported cues.
- `knowledge-boundary`: a person cannot react to an unknown private event.
- `request-without-quest`: a request and commitment resolve without creating a
  player-facing objective.
- `clock-schedules`: time advancement executes eligible background actions once.
- `dungeon-connectivity`: every accepted instance has a reachable route and exit.
- `spawn-legality`: monsters respect budget, distance, and terrain rules.
- `combat-fallback`: an invalid or timed-out LLM action uses deterministic AI.
- `effect-order`: statuses and modifiers resolve in stable order.
- `upgrade-budget`: illegal technique and weapon proposals are rejected.
- `save-load`: a save restores canonical state, seeds, and event position.
