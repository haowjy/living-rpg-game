# Growth, Techniques, and Weapons

Growth should preserve two feelings: the player becomes more capable through
understandable rules, and their history changes what that capability becomes.
Deterministic systems own power; LLMs propose personalized forms within those
systems.

## Technique lifecycle

### Learn

Techniques come from manuals, teachers, observed enemies, relics, experiments,
or other concrete sources. Learning creates a legal technique definition rather
than a free-text power.

### Practice

Proficiency rises through use, drills, study, training, and relevant
exploration. Ordinary gains are deterministic and recorded as events.

| Level | Meaning |
|---|---|
| Untrained | Known but unreliable |
| Novice | Usable with meaningful limits |
| Competent | Reliable under ordinary pressure |
| Expert | Strong enough to define tactics |
| Master | Flexible enough to evolve |

### Evolve

At an eligible threshold, the player chooses references:

- another known technique;
- a manual passage, relic, or teacher;
- a remembered event;
- a recurring combat pattern;
- a line or intention written by the player.

The Growth Oracle retrieves relevant history and proposes several forms. A
validator accepts only effects expressible through legal primitives and within
the technique's budget.

```text
base technique + chosen references + relevant history
                         |
                         v
                  LLM proposals
                         |
                         v
             mechanical validation
                         |
                         v
                player selection
```

Events provide context. They do not automatically award a new technique.

## Technique definition

A technique contains a cost, target rule, range, effect sequence, conditions,
cooldown, proficiency, and history. Effects come from a bounded vocabulary such
as damage, guard, heal, move, mark, apply status, remove status, reveal, push,
pull, counter, summon, or alter terrain.

Elements, statuses, and modifiers belong to the shared effect engine. The LLM
may combine them but may not invent an unresolvable rule.

## Semi-deterministic weapons

A weapon has a deterministic body:

- category, grip, range, and damage profile;
- material and quality;
- legal techniques and elemental affinities;
- modifier slots and upgrade budget;
- ownership and recorded history.

An LLM may propose its name, description, visual identity, emerging traits, and
reforging paths. The weapon validator compiles only legal changes within its
budget. A remembered weapon may become narratively unique without receiving
arbitrary statistics.

## Crafting and reforging

Crafting consumes known ingredients, tools, stations, and time. Recipes and
material transformations are deterministic. Experimentation may ask an LLM to
propose a result, but the crafting system validates ingredients, output type,
quality range, and modifiers before anything is created.

The first slice needs only a few recipes and one reforge path.

## Broader power

Power also includes reputation, relationships, allies, resources, territory,
and legitimacy. These channels matter because they change what the player can
attempt and how people respond.

Shrines and breakthroughs may later alter rank, affinity, vows, drawbacks, and
the allowed weirdness of future evolutions. They are not required to prove the
first presentation slice.
