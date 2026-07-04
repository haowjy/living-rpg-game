# Story System

The story system generates playable situations from local pressure. The LLM observes events, detects emerging patterns, and proposes story developments. Validation happens at the tool level — proposed scenes must reference real characters, locations, and established facts.

## Story Pressure

Story pressure is unresolved tension attached to places, people, and factions. The story system surfaces pressure that is local, timely, and connected to prior events.

Examples of pressure ready to become story:

- A rivalry forming between the player and a peer.
- A village ready to rebel against its lord.
- A faction's legitimacy weakening after a public failure.
- A companion's loyalty cracking under competing obligations.
- A rumor reaching the wrong person.
- A war creating a claimable power vacuum.

Pressure accumulates from events. When enough pressure builds around a cluster of characters, locations, and factions, the story system proposes a scene.

## Story Sifting

The LLM reads the event stream and proposes emerging patterns as story threads. Sifting is flexible and LLM-driven — there are no rigid pattern-matching rules.

Example: repeated public conflict between the player and Tomas becomes a rivalry thread. A spared bandit plus food shortage plus weak lordship control becomes a recruitment or rebellion thread. The LLM notices these patterns because it reads the full event context, not because a rule fires on specific event types.

When a pattern has enough recurrence, stakes, and actors, the story system promotes it into a quest thread (see [Quests & Threads](#quests-threads)).

## Scene Generation

A scene begins when the story system identifies actionable pressure at the player's current location. The system:

1. Reads the player's location, present characters, recent events, and active pressures.
2. Identifies which pressure is most ready to surface.
3. Generates a scene with narration, NPC actions, and player options.
4. Calls tools to record the resulting events.

Scenes are grounded by validation checks:

| Check | Question |
|---|---|
| Presence | Is the NPC actually here, reachable, or able to send a message? |
| Knowledge | Does this character know the fact they are acting on? |
| Rules | Are rewards, injuries, locations, and state changes legal? |
| Causality | Does the scene follow from prior events and current pressure? |
| Scope | Is the scene local enough for the current player location? |

These checks are enforced by the tools. If `write_event` receives a reference to a character who is not present, the tool rejects the call.

## Content Building

The story system also builds new world content from validated primitives. In the PoC, this means quests, rumors, and local scenes. The same pattern extends to spells, techniques, artifacts, faction projects, settlements, and companion arcs.

The LLM proposes structure and meaning. The tools validate it against the current world state and either accept or reject the proposal.
