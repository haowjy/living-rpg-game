class_name DialogueData
extends RefCounted
## Authored dialogue and interaction prompts, branching on GameState flags.
## Actions are executed by Main; dialogue itself never mutates the sim.

static func for_npc(npc_id: String, gs: GameState) -> Dictionary:
	match npc_id:
		"elder_a":
			return _elder(gs)
		"merchant_b":
			return _merchant(gs)
		"rival_c":
			return _rival(gs)
		"reeve_f":
			return _reeve(gs)
		"mentor_e":
			return _mentor(gs)
		"warden_g":
			return _warden(gs)
		"marshal_d":
			return _marshal(gs)
	return _say("<?>", ["..."])


static func _elder(gs: GameState) -> Dictionary:
	if not gs.flag("quest_a_started"):
		return {
			"title": "<elder A>",
			"lines": [
				"Your strike has a foundation now. The road will test whether it holds.",
				"<captain H>'s band occupies <ruin C>, and <noble family A> has posted a bounty.",
				"Find out why the old watch broke. How you settle it is yours to choose.",
			],
			"choices": [
				{"label": "Take the task", "action": "learn_and_start_quest", "args": {}},
				{"label": "Step away", "action": "close", "args": {}},
			],
		}
	if gs.flag("quest_a_done"):
		var lines: Array = []
		if gs.flag("quest_a_resolved_combat"):
			lines = ["The ruin is quiet, and the band is broken.", "Strength answers fast. Remember what follows it."]
		elif gs.flag("quest_a_resolved_talk"):
			lines = ["The watch stands again. Re-swearing the watch-oath was the harder answer."]
		else:
			lines = ["An unpaid charter brought into daylight. Steel could not have cut as deeply."]
		if gs.player().technique_by_id("technique_c") == null:
			return {
				"title": "<elder A>",
				"lines": lines + ["You held your ground at the ruin. Now learn how to guard it."],
				"choices": [
					{"label": "Learn <technique C; guard stance>", "action": "learn_technique_c", "args": {}},
					{"label": "Leave", "action": "close", "args": {}},
				],
			}
		return _say("<elder A>", lines + ["Keep practicing the guard stance."])
	return _say("<elder A>", ["The band still holds <ruin C>. Learn why, then choose your answer."])


static func _merchant(gs: GameState) -> Dictionary:
	var lines: Array = [
		"A spirit contract is no use in a pack. Carry one to <shrine D>.",
		"<warden G> will conduct the ceremony if a spirit answers.",
	] if not gs.flag("spirit_contracted") else ["You carry a spirit now. Maybe trade can breathe again."]
	return {
		"title": "<merchant B>",
		"lines": lines,
		"choices": [
			{"label": "Buy <spirit contract> (20 gold)", "action": "buy_item", "args": {"item_id": "item_spirit_contract"}},
			{"label": "Buy <salve> (6 gold)", "action": "buy_item", "args": {"item_id": "item_salve"}},
			{"label": "Leave", "action": "close", "args": {}},
		],
	}


static func _rival(gs: GameState) -> Dictionary:
	if gs.flag("quest_a_resolved_combat"):
		return _say("<rival C>", ["Heard you carved through the ruin.", "I would have done it cleaner."])
	if gs.flag("quest_a_resolved_talk"):
		return _say("<rival C>", ["You put the band back on watch?", "That story is spreading too quickly for my liking."])
	if gs.flag("quest_a_resolved_expose"):
		return _say("<rival C>", ["You made <noble family A> pay by showing everyone the charter.", "Hard to outfight someone who changes what the fight was about."])
	return _say("<rival C>", ["The elder gave the ruin job to you?", "Do not die out there. It would reflect badly on the rest of us."])


static func _reeve(gs: GameState) -> Dictionary:
	if gs.flag("has_charter") and not gs.flag("quest_a_done"):
		return {
			"title": "<reeve F>",
			"lines": ["That seal is genuine. <noble family A> left the watch unpaid, then called them bandits."],
			"choices": [
				{"label": "Present the charter", "action": "expose_charter", "args": {}},
				{"label": "Keep it for now", "action": "close", "args": {}},
			],
		}
	if gs.flag("quest_a_resolved_expose"):
		return _say("<reeve F>", ["The charter is public now. <noble family A> paid grudgingly, but they paid."])
	return _say("<reeve F>", [
		"By order of <noble family A>, a bounty is posted on the band occupying <ruin C>.",
		"Speak with <elder A> before you take the old road.",
	])


static func _mentor(gs: GameState) -> Dictionary:
	if gs.flag("mentor_taught") or gs.player().technique_by_id("technique_d") != null:
		return _say("<mentor E>", ["Your answer is in the way you use <technique D> now."])
	return {
		"title": "<mentor E>",
		"lines": ["Who broke first, the band or the bond?"],
		"choices": [
			{"label": "Answer, then learn <technique D>", "action": "learn_technique_d", "args": {}},
			{"label": "Keep walking", "action": "close", "args": {}},
		],
	}


static func _warden(_gs: GameState) -> Dictionary:
	return _say("<warden G>", ["Bring a spirit contract to the altar. The choice made there is yours."])


static func _marshal(gs: GameState) -> Dictionary:
	if not gs.flag("quest_a_done"):
		return _say("<marshal D>", ["A broken watch is rarely only a problem of bandits."])
	if gs.flag("marshal_offer_seen"):
		return _say("<marshal D>", ["My offer remains. I will not ask for your answer today."])
	return {
		"title": "<marshal D>",
		"lines": [
			"However you ended the trouble at <ruin C>, you saw farther than the bounty.",
			"I have work for someone who can do that. Think on the offer; do not answer yet.",
		],
		"choices": [{"label": "Leave the offer unanswered", "action": "see_marshal_offer", "args": {}}],
	}


## The ceremony at <shrine D>, conducted by <warden G>.
static func shrine(gs: GameState) -> Dictionary:
	if gs.flag("spirit_contracted"):
		return _say("<warden G> — spirit contract ceremony", ["The altar is quiet. One spirit has joined the party."])
	if int(gs.inventory.get("item_spirit_contract", 0)) < 1:
		return _say("<warden G> — spirit contract ceremony", [
			"A ceremony cannot begin without a spirit contract.",
			"Acquire one from <merchant B> in the <hub A> shop.",
		])
	return {
		"title": "<warden G> — spirit contract ceremony",
		"lines": ["<warden G> names the spirit contract aloud. Three presences answer the altar."],
		"choices": [
			{"label": "Choose <spirit A>", "action": "choose_spirit", "args": {"spirit_id": "spirit_a"}},
			{"label": "Choose <spirit B; sprout>", "action": "choose_spirit", "args": {"spirit_id": "spirit_b"}},
			{"label": "Choose <spirit C; ember fox>", "action": "choose_spirit", "args": {"spirit_id": "spirit_c"}},
			{"label": "Leave", "action": "close", "args": {}},
		],
	}


## The confrontation at <ruin C>, with three possible resolutions.
static func ruin(gs: GameState) -> Dictionary:
	if gs.flag("quest_a_done"):
		return _say("<ruin C>", ["The confrontation here is over."])
	if gs.flag("has_charter"):
		return _say("<ruin C>", ["The band has stood down while you carry the unpaid charter to <reeve F>."])
	if not gs.flag("quest_a_started"):
		return _say("<ruin C>", ["Armed figures watch from the rubble.", "(Speak to <elder A> in <hub A> first.)"])
	var choices: Array = [
		{"label": "Fight the band", "action": "fight_encounter", "args": {"encounter_id": "enc_ruin"}},
	]
	if gs.flag("spirit_contracted"):
		choices.append({"label": "Reinstate the road watch", "action": "negotiate_ruin", "args": {}})
	choices.append({"label": "Take the unpaid charter", "action": "take_charter", "args": {}})
	choices.append({"label": "Withdraw", "action": "close", "args": {}})
	return {
		"title": "<ruin C> — <captain H>",
		"lines": [
			"<captain H>, leader of the band, raises the faded colors of the old road watch.",
			"He holds out a charter bearing <noble family A>'s seal. Its promised wages were never paid.",
			"They took the ruin after the charter failed them. Now he waits for your answer.",
		],
		"choices": choices,
	}


static func _say(title: String, lines: Array) -> Dictionary:
	return {"title": title, "lines": lines, "choices": [{"label": "Leave", "action": "close", "args": {}}]}
