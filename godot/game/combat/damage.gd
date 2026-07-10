class_name Damage
extends RefCounted
## Pure damage/status math for combat. All integer, fully deterministic.
##
## Status semantics (Slay-the-Spire-style stacking counters):
## - "vulnerable": while stacks > 0 the holder takes +50% damage per hit;
##   stacks tick down by 1 at the end of the holder's own turn.
## - "guard": while stacks > 0 incoming hits are halved and consume 1 stack.
## - "burn": at the start of the holder's turn they take `stacks` damage,
##   then stacks tick down by 1.
## Broken (break meter empty) targets also take +50% damage.

const VULNERABLE_NUM := 3
const VULNERABLE_DEN := 2
const BROKEN_NUM := 3
const BROKEN_DEN := 2


## Final damage of a hit, after attacker bonus and target statuses.
static func compute_hit(base_power: int, attacker_bonus: int, target: Combatant) -> int:
	var amount := base_power + attacker_bonus
	if target.status("vulnerable") > 0:
		amount = amount * VULNERABLE_NUM / VULNERABLE_DEN
	if target.broken:
		amount = amount * BROKEN_NUM / BROKEN_DEN
	if target.status("guard") > 0:
		amount = amount / 2
	return maxi(1, amount)


## Applies a hit; consumes guard; returns the damage dealt.
static func apply_hit(base_power: int, attacker_bonus: int, target: Combatant) -> int:
	var amount := compute_hit(base_power, attacker_bonus, target)
	if target.status("guard") > 0:
		target.decrement_status("guard")
	target.set_hp(target.hp() - amount)
	return amount


## Depletes the target's break meter if the element matches a weak tag.
## Returns true if this hit broke the target.
static func apply_break(element: String, break_power: int, target: Combatant) -> bool:
	if target.broken or target.max_toughness <= 0 or element == "":
		return false
	if not target.weak_tags.has(element):
		return false
	target.toughness = maxi(0, target.toughness - break_power)
	if target.toughness == 0:
		target.broken = true
		return true
	return false
