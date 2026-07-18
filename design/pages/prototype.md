# First Playable Slice

The first slice proves that Living RPG has a compelling stage before it asks an
LLM to supply a full story. A human-authored script, deterministic driver, and
LLM must all be able to perform scenes through the same Director contract.

## Outcome

After 20–30 minutes, a player should remember a person, a promise, a Dungeon
expedition, and a change to their fighting style. The test is the quality and
controllability of the experience, not the quantity of content.

## What to build

| Part | First version |
|---|---|
| Presentation | Mobile-capable 2D/2.5D exploration, dialogue, portraits, camera cues, transitions, combat UI |
| Director | Small command vocabulary usable from scripts, debug tools, and LLM adapters |
| Place | One settlement exterior, one interior, one Dungeon entrance |
| People | Player plus 4–5 named characters with schedules, knowledge, memories, and relationships |
| Story | One request, one promise or refusal, one delayed consequence |
| Dungeon | One seed-driven layout that can generate repeatedly and spawn visible monsters |
| Combat | One deterministic turn-based encounter with interchangeable enemy controllers |
| Growth | Several techniques, one mastery/evolution demonstration, one semi-deterministic weapon |
| State | Commands, canonical events, save/load, and replay |

## Play sequence

1. The player walks through the settlement and meets a named person.
2. That person asks for something in ordinary dialogue. No task card appears.
3. The player may promise, refuse, or leave the request unresolved.
4. The player enters a generated Dungeon and encounters a spawned monster.
5. Combat resolves through deterministic rules and records technique use.
6. The player returns after time has passed.
7. The requester reacts only to facts they know.
8. The player evolves a technique or reforges a weapon from legal primitives.

The first version may use authored situation selection and deterministic NPC
responses. The LLM enters through the same interfaces once the scene works
without it.

## Director proof

The debug console must be able to stage commands such as:

```ts
focusCamera("mara")
speak("mara", "You came back alone.", { expression: "guarded" })
moveTo("tomas", "market_gate")
face("tomas", "player")
offerChoices(["Explain", "Apologize", "Leave"])
beginEncounter("dungeon_entry")
```

The client owns pathfinding, timing, animation, and failure handling. The
director states intent.

## Acceptance criteria

1. The same scripted scene runs from the Director console and from a structured
   external request.
2. Movement, time, combat, inventory, and state mutation remain deterministic.
3. Replaying the same command sequence with the same seed produces the same
   canonical events and Dungeon result.
4. Every NPC reaction is supported by witnessed events, received information,
   or a recorded memory.
5. Ignoring a request changes later behavior without displaying a quest failure.
6. The Dungeon is navigable, contains legal spawns, and cannot trap the player.
7. Enemy turns continue through deterministic AI when no LLM is available.
8. Technique and weapon proposals compile only from legal effects and budgets.
9. The slice remains usable at a mobile viewport and with touch controls.
10. A developer can inspect state, events, memories, and LLM traces.

## Not required yet

- A complete autonomous story Oracle.
- A large overworld.
- More than one Dungeon theme.
- A full crafting economy.
- Spirits or pet collection.
- Procedural generation of every visual asset during play.
- A final engine commitment before the presentation spike is evaluated.
