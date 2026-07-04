# Player Character

The player character uses standard RPG stats: STR, DEX, CON, INT, WIS, CHA, HP, and level. Equipment slots and a skill list that grows from use round out the mechanical identity. Techniques from the insight spellcraft system slot into the ability list alongside conventional skills.

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

Skills have proficiency levels (untrained, novice, competent, expert, master) that affect the narrative DM's interpretation of attempts.

## Techniques

Techniques come from the insight spellcraft pipeline (see [Growth & Power](#growth-power)). They slot into the ability list alongside conventional skills. A technique like "Ash Wolf Step" sits next to "Sword Fighting" and "Lockpicking" — the player uses all of them the same way, by describing what they want to do.

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

The PoC uses a narrative DM — the player describes actions in free text, the LLM interprets and narrates outcomes based on stats, skills, and situation.

V1 uses real-time action combat. The player controls movement and attacks directly (WASD + mouse on PC, joystick on controller). Techniques from insight spellcraft slot into a hotbar (4 slots, mapped to number keys or face buttons) and are usable in real-time — dashes, strikes, area effects, defensive moves.

The deterministic game engine handles base combat: hit detection, damage calculation, enemy AI behavior trees. The LLM runs in the background and perturbs the fight — an enemy shouts a taunt referencing your history, reinforcements arrive because a lookout escaped, the environment shifts (a bridge collapses, fire spreads), an enemy breaks and flees because they recognize you. The player feels a living fight, not a scripted encounter.

| Layer | Handles | Example |
|---|---|---|
| Game engine | Movement, collision, damage, enemy base AI | Bandit swings sword, player dodges, damage applies |
| LLM perturbation | Dialogue, reinforcements, environment, morale | Bandit yells "that's the Mill-Savior!" — two others flee |
| Technique system | Player abilities from insight spellcraft | "Ash Wolf Step" dash leaves afterimage, flanks enemy |

## Character File

The player character's state lives in `world/characters/player.md`:

```
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
- Ash Wolf Step — Dash + afterimage + flanking bonus

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
