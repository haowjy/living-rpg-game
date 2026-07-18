# Player Character

The player character is the mechanical and social throughline. The world may be
people-focused, but relationships, promises, reputation, techniques, weapons,
and remembered choices still accumulate around the player.

## Baseline identity

Use familiar RPG attributes unless playtesting proves a smaller set works
better:

| Attribute | Covers |
|---|---|
| Strength | Force, carrying, heavy weapon use |
| Dexterity | Movement, accuracy, evasion, delicate work |
| Constitution | Health, endurance, resistance |
| Intelligence | Knowledge, analysis, technical crafting |
| Wisdom | Perception, judgment, sensitivity to unusual phenomena |
| Charisma | Persuasion, intimidation, leadership |

Derived health, action resources, defenses, and equipment requirements remain
deterministic. Exact formulas are implementation decisions.

## Skills and techniques

General skills improve through use or training. Techniques are named combat or
exploration forms with explicit effects and proficiency. Their history records
where they came from, how they were practiced, and which references shaped
their evolutions.

See [Growth, Techniques, and Weapons](growth-power.md).

## Equipment

The baseline equipment model supports a main hand, off-hand, armor, and a small
number of accessory slots. Items change legal actions as well as statistics: a
torch permits exploration, a badge changes social access, and a weapon enables
particular techniques.

Weapons retain identity and history because reforging may use both as context.

## Social history

The player state links to:

- known people and relationship axes;
- requests received;
- explicit commitments;
- reputation and rumors;
- witnessed events;
- authored notes or journal entries.

This history does not become a quest list. It gives people and the Oracle enough
evidence to react coherently.

## Conflict

Combat is visually presented and deterministically resolved. The player chooses
legal techniques, targets, movement, items, retreats, and party orders. Enemy
and companion controllers may be deterministic or LLM-backed, but they receive
the same legal-action set.

The LLM can add battle intent, barks, recognition, and tactical choice. It
cannot change turn order, ignore a cost, invent a status, or declare damage.

## First-slice character

The first slice needs:

- a small attribute block;
- one weapon and basic equipment;
- several techniques with visible tactical differences;
- one proficiency change;
- one validated technique evolution or weapon reforge;
- enough social history for a person to remember a promise.

Levels, large skill lists, party management, and shrine paths can wait until
the basic loop proves which progression signals the player actually notices.
