class_name DialogueData
extends RefCounted
## Authored dialogue and interaction prompts, branching on GameState flags.
##
## A prompt is a Dictionary:
##   {"title": String, "lines": Array[String],
##    "choices": [{"label": String, "action": String, "args": Dictionary}]}
## Actions are executed by Main: "close", "learn_and_start_quest",
## "offer_pact", "accept_pact", "fight_encounter", "negotiate_ruin".

static func for_npc(npc_id: String, gs: GameState) -> Dictionary:
	match npc_id:
		"elder_a":
			return _elder(gs)
		"merchant_b":
			return _merchant(gs)
		"rival_c":
			return _rival(gs)
	return _say("<?>", ["..."])


static func _elder(gs: GameState) -> Dictionary:
	if not gs.flag("quest_a_started"):
		return {
			"title": "<elder A>",
			"lines": [
				"You have quick hands and no teacher. Watch once, then do it right.",
				"(<elder A> demonstrates <technique A; strike>.)",
				"Now listen. <monster B>'s band took <ruin C> on the old road.",
				"Deal with them before winter does. How you deal with them is yours to choose.",
			],
			"choices": [
				{"label": "Accept the technique and the task", "action": "learn_and_start_quest", "args": {}},
				{"label": "Step away", "action": "close", "args": {}},
			],
		}
	if gs.flag("quest_a_resolved_combat"):
		return _say("<elder A>", [
			"So the ruin is quiet, and the band is broken.",
			"Strength answers fast. Remember that the road will remember you now.",
		])
	if gs.flag("quest_a_resolved_talk"):
		return _say("<elder A>", [
			"They walked away? And the ruin stands empty without a drop of blood.",
			"Stranger than steel, that. The spirit chose its holder well.",
		])
	return _say("<elder A>", [
		"The band still holds <ruin C>. Train on the road if you must, but go.",
	])


static func _merchant(gs: GameState) -> Dictionary:
	if not gs.flag("spirit_contracted"):
		return _say("<merchant B>", [
			"Roads are bad for trade and worse for traders.",
			"There is an old shrine past the road, <shrine D>. Travelers say it still answers.",
			"Whatever answers there wants something. It always does.",
		])
	return _say("<merchant B>", [
		"You carry something with you now. The air moves wrong around you.",
		"Good. Maybe the roads get safer.",
	])


static func _rival(gs: GameState) -> Dictionary:
	if gs.flag("quest_a_resolved_combat"):
		return _say("<rival C>", [
			"Heard you carved through the ruin. Everyone heard.",
			"Enjoy the cheering. I would have done it cleaner.",
		])
	if gs.flag("quest_a_resolved_talk"):
		return _say("<rival C>", [
			"You talked them out of the ruin? Talked?",
			"That story is spreading faster than a fire. I do not like how it makes me look.",
		])
	return _say("<rival C>", [
		"The elder gave the ruin job to you? To you.",
		"Do not die out there. It would look bad for everyone who trained here.",
	])


## The shrine altar at <shrine D>.
static func shrine(gs: GameState) -> Dictionary:
	if gs.flag("spirit_contracted"):
		return _say("<shrine D> altar", [
			"The altar is quiet. The pact is made; nothing more waits here.",
		])
	return {
		"title": "<shrine D> altar",
		"lines": [
			"Wind circles the altar though the trees are still.",
			"Something offers itself: a companion of gale and appetite — <spirit A>.",
			"It asks a vow of blood: 2 of your greatest strength (max HP), forever.",
		],
		"choices": [
			{"label": "Seal the pact (-2 max HP, gain <spirit A>)", "action": "accept_pact", "args": {}},
			{"label": "Refuse", "action": "close", "args": {}},
		],
	}


## The confrontation at <ruin C>. Two resolutions once the quest is live.
static func ruin(gs: GameState) -> Dictionary:
	if gs.flag("quest_a_done"):
		return _say("<ruin C>", [
			"The ruin is quiet now. Crows pick at what the band left behind.",
		])
	if not gs.flag("quest_a_started"):
		return _say("<ruin C>", [
			"Armed figures watch you from the rubble. Whatever this is, you are not ready to name it.",
			"(Speak to <elder A> in <hub A> first.)",
		])
	var choices: Array = [
		{"label": "Fight the band", "action": "fight_encounter", "args": {"encounter_id": "enc_ruin"}},
	]
	if gs.flag("spirit_contracted"):
		choices.append({
			"label": "Let <spirit A> speak for you (negotiate)",
			"action": "negotiate_ruin", "args": {},
		})
	choices.append({"label": "Withdraw", "action": "close", "args": {}})
	return {
		"title": "<ruin C>",
		"lines": [
			"<monster B>'s band bars the gap in the wall. The leader hefts a blade.",
			"\"The ruin is ours. Walk away, or feed the crows.\"",
		]
			+ ([
				"At your shoulder, <spirit A> stirs — the wind carries your words further than they should go.",
			] if gs.flag("spirit_contracted") else []),
		"choices": choices,
	}


static func _say(title: String, lines: Array) -> Dictionary:
	return {
		"title": title,
		"lines": lines,
		"choices": [{"label": "Leave", "action": "close", "args": {}}],
	}
