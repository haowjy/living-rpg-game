# Player Character

The player character uses standard RPG stats: STR, DEX, CON, INT, WIS, CHA, HP, and level. Equipment slots, use-based skills, learned techniques, proficiency, relationships, reputation, and shrine breakthroughs round out the mechanical identity.

## Stats

| Stat | Abbreviation | Role |
|---|---|---|
| Strength | STR | Melee damage, carrying capacity, physical force |
| Dexterity | DEX | Speed, evasion, ranged accuracy, stealth |
| Constitution | CON | Hit points, endurance, resistance to poison and disease |
| Intelligence | INT | Knowledge recall, arcane aptitude, crafting precision |
| Wisdom | WIS | Perception, insight checks, spiritual sensitivity |
| Charisma | CHA | Persuasion, intimidation, leadership, faction reputation effects |

HP derives from CON and level. Level increases from accumulated experience across combat, exploration, social encounters, and quest completion.

## Skills

Skills grow from use. A player who repeatedly picks locks improves at lockpicking. A player who negotiates with faction leaders improves at persuasion. The skill list is open-ended — new skills appear when the player attempts new kinds of actions.

Skills have proficiency levels: untrained, novice, competent, expert, master.

## Techniques

Techniques are learned forms with proficiency.

The player can learn techniques from manuals, teachers, enemies, relics, shrines, or experiments. Proficiency rises through use, training, drills, and study. At higher proficiency, the player can evolve a technique by bringing references — another technique, a manual passage, a strange book, a shrine, a memory, or a line they write themselves.

A technique is not automatically created by a meaningful event. Events are context the system can read when the player chooses to evolve a technique.

## Equipment

Standard equipment slots:

- Weapon (main hand)
- Off-hand (shield, second weapon, focus)
- Armor (body)
- Head
- Hands
- Feet
- Two accessory slots

Equipment affects stats and opens or closes options. Heavy armor increases effective CON but penalizes DEX. A torch lets the player explore dark sites. A guild badge changes how NPCs react.

## Conflict Resolution

The PoC uses narrative turns. The player describes actions in free text, and the system interprets outcomes based on stats, skills, party state, position, technique proficiency, enemy state, and situation.

V1 should use visual turn-based party combat. The player chooses techniques, targets, positions, items, retreats, and party orders. Combat can track turn order, party ranks, stress, wounds, marks, status effects, cooldowns, and legal target rules.

The deterministic combat layer handles rules: hit checks, damage, status, turn order, cooldowns, legal targets, and proficiency gain. The LLM runs around that layer: enemy barks, morale shifts, history references, contextual complications, and post-combat consequences.

| Layer | Handles | Example |
|---|---|---|
| Combat engine | Turns, position, damage, status, legal targets | A front-rank bandit marks the lead companion |
| LLM meaning layer | Dialogue, morale, environment, history references | A frightened enemy recognizes the player from a rumor |
| Technique system | Learned forms, proficiency, evolution, validation | A mastered step technique evolves into a smoke-feint |

## Character File

The player character's state lives in `world/characters/player.md`:

```markdown
# Player Character

**Level:** 2
**HP:** 18 / 22

## Stats
STR 12 | DEX 14 | CON 11 | INT 10 | WIS 13 | CHA 15

## Skills
- Sword Fighting (novice)
- Persuasion (competent)
- Survival (novice)

## Techniques
- Wolf Step — competent; evasive footwork from a hunter's manual
- Fire Palm — novice; close-range fire strike

## Shrine Path
- First Ember — fire affinity, minor burn resistance

## Equipment
- Rusted longsword (main hand)
- Leather jerkin (armor)
- Traveler's boots (feet)
- Guild badge (accessory)

## Inventory
- 12 silver coins
- Rope (50 ft)
- Dried rations (3 days)
```