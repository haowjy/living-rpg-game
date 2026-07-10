extends RefCounted
## Tests for deterministic enabling systems: time, rest, money, and inventory.


func run(t: TestHarness) -> void:
	var db := ContentDB.new()

	t.context("time")
	var rollover := GameState.new(db, 42)
	rollover.start_new_run("hub_a")
	rollover.time_of_day = 3
	var advanced := rollover.advance_time()
	t.ok(advanced["ok"], "time advancement succeeds")
	t.eq(rollover.day, 2, "advancing past Night increments the day")
	t.eq(rollover.time_of_day, 0, "advancing past Night reaches Morning")
	var time_event := rollover.event_log.entries[-1]
	t.eq(time_event["type"], "time_advanced", "time advancement is logged")
	t.eq(time_event["data"], {"day": 2, "time_of_day": 0},
			"time event carries the resulting day and segment")
	var unchanged_clock := [rollover.day, rollover.time_of_day]
	var zero_advance := rollover.advance_time(0)
	t.ok(not zero_advance["ok"] and not String(zero_advance["error"]).is_empty(),
			"zero-segment time advancement is rejected")
	t.eq([rollover.day, rollover.time_of_day], unchanged_clock,
			"rejected time advancement preserves the clock")
	t.eq(rollover.event_log.entries[-1]["type"], "command_rejected",
			"rejected time advancement is logged")

	var traveler := GameState.new(db, 42)
	traveler.start_new_run("hub_a")
	var moved := traveler.move_to_area("road_b")
	t.ok(moved["ok"], "outdoor travel succeeds")
	t.eq(traveler.time_of_day, 1, "travel between outdoor areas advances time")
	t.eq(traveler.event_log.entries[-1]["type"], "time_advanced",
			"outdoor travel logs its time advancement")
	var entered := traveler.move_to_area("hub_a")
	t.ok(entered["ok"], "returning to the hub succeeds")
	var before_interior := traveler.time_of_day
	entered = traveler.move_to_area("hub_a_interior")
	t.ok(entered["ok"], "entering the shop interior succeeds")
	t.eq(traveler.time_of_day, before_interior, "entering an interior does not advance time")
	t.eq(traveler.event_log.entries[-1]["type"], "traveled",
			"interior travel does not append a time event")
	var travel_clock := [traveler.day, traveler.time_of_day]
	var travel_event_count := traveler.event_log.entries.size()
	var blocked_travel := traveler.move_to_area("ruin_c")
	t.ok(not blocked_travel["ok"] and not String(blocked_travel["error"]).is_empty(),
			"non-adjacent travel is rejected")
	t.eq([traveler.day, traveler.time_of_day], travel_clock,
			"rejected travel preserves the clock")
	t.eq(traveler.event_log.entries.size(), travel_event_count + 1,
			"rejected travel appends only its rejection")
	t.eq(traveler.event_log.entries[-1]["type"], "command_rejected",
			"rejected travel appends no time advancement")

	t.context("rest")
	var resting := GameState.new(db, 42)
	resting.start_new_run("hub_a")
	resting.time_of_day = 2
	resting.player().hp = 3
	resting.player().qi = 1
	resting.party[1].hp = 2
	resting.party[1].qi = 0
	var rested := resting.rest()
	t.ok(rested["ok"], "resting at the hub succeeds")
	t.eq(resting.player().hp, resting.player().max_hp, "rest restores HP")
	t.eq(resting.player().qi, resting.player().max_qi, "rest restores qi")
	t.eq(resting.party[1].hp, resting.party[1].max_hp, "rest restores every actor's HP")
	t.eq(resting.party[1].qi, resting.party[1].max_qi, "rest restores every actor's qi")
	t.eq(resting.day, 2, "rest advances to the next day")
	t.eq(resting.time_of_day, 0, "rest advances to Morning")
	t.eq(resting.event_log.entries[-1]["type"], "rested", "rest is logged")
	t.eq(resting.event_log.entries[-1]["data"], {"day": 2, "time_of_day": 0},
			"rest event carries the resulting time")

	var away := GameState.new(db, 42)
	away.start_new_run("road_b")
	away.time_of_day = 2
	away.player().hp = 3
	away.player().qi = 1
	away.party[1].hp = 2
	away.party[1].qi = 0
	var away_vitals := _party_vitals(away)
	var away_clock := [away.day, away.time_of_day]
	var rejected := away.rest()
	t.ok(not rejected["ok"] and not String(rejected["error"]).is_empty(),
			"resting away from the hub is rejected")
	t.eq(_party_vitals(away), away_vitals, "rejected rest preserves every actor's HP and qi")
	t.eq([away.day, away.time_of_day], away_clock, "rejected rest preserves the clock")
	t.eq(away.event_log.entries[-1]["type"], "command_rejected",
			"rejected rest is logged")

	t.context("buy")
	var shopper := GameState.new(db, 42)
	shopper.start_new_run("hub_a_interior")
	shopper.gold = 30
	var bought := shopper.buy("item_salve")
	t.ok(bought["ok"], "buying goods from a present merchant succeeds")
	t.eq(shopper.gold, 24, "buying deducts the item price")
	t.eq(shopper.inventory.get("item_salve", 0), 1, "buying adds one item")
	t.eq(shopper.event_log.entries[-1]["type"], "item_bought", "buying is logged")
	t.eq(shopper.event_log.entries[-1]["data"]["item_id"], "item_salve",
			"buy event identifies the item")

	var exact := GameState.new(db, 42)
	exact.start_new_run("hub_a_interior")
	exact.gold = db.item("item_salve").price
	t.ok(exact.buy("item_salve")["ok"], "buying with exactly the price succeeds")
	t.eq(exact.gold, 0, "exact-price purchase spends all gold")
	var short := GameState.new(db, 42)
	short.start_new_run("hub_a_interior")
	short.gold = db.item("item_salve").price - 1
	var short_inventory := short.inventory.duplicate()
	var short_buy := short.buy("item_salve")
	t.ok(not short_buy["ok"] and not String(short_buy["error"]).is_empty(),
			"buying at price minus one is rejected")
	t.eq(short.gold, db.item("item_salve").price - 1,
			"insufficient-funds rejection preserves gold")
	t.eq(short.inventory, short_inventory,
			"insufficient-funds rejection preserves inventory")
	t.eq(short.event_log.entries[-1]["type"], "command_rejected",
			"insufficient-funds rejection is logged")

	shopper.gold = 0
	var poor := shopper.buy("item_salve")
	t.ok(not poor["ok"], "buying with insufficient gold is rejected")
	t.eq(shopper.inventory.get("item_salve", 0), 1,
			"rejected purchase does not add inventory")
	t.eq(shopper.event_log.entries[-1]["type"], "command_rejected",
			"rejected purchase is logged")

	var remote := GameState.new(db, 42)
	remote.start_new_run("hub_a")
	remote.gold = 30
	var no_merchant := remote.buy("item_salve")
	t.ok(not no_merchant["ok"] and not String(no_merchant["error"]).is_empty(),
			"buying without a present merchant is rejected")
	t.eq(remote.gold, 30, "rejected remote purchase does not deduct gold")
	t.eq(remote.inventory, {}, "rejected remote purchase preserves inventory")
	t.eq(remote.event_log.entries[-1]["type"], "command_rejected",
			"remote purchase rejection is logged")

	var unknown_gold := shopper.gold
	var unknown_inventory := shopper.inventory.duplicate()
	var unknown_item := shopper.buy("item_unknown")
	t.ok(not unknown_item["ok"] and not String(unknown_item["error"]).is_empty(),
			"buying an unknown item returns a command rejection")
	t.eq(shopper.gold, unknown_gold, "unknown purchase does not deduct gold")
	t.eq(shopper.inventory, unknown_inventory, "unknown purchase does not alter inventory")
	t.eq(shopper.event_log.entries[-1]["type"], "command_rejected",
			"unknown purchase rejection is logged")

	t.context("sell")
	shopper.inventory["item_salve"] = 2
	shopper.gold = 0
	var sold := shopper.sell("item_salve")
	t.ok(sold["ok"], "selling an owned item succeeds")
	t.eq(shopper.gold, 3, "selling refunds half the price with integer math")
	t.eq(shopper.inventory["item_salve"], 1, "selling decrements inventory")
	t.eq(shopper.event_log.entries[-1]["type"], "item_sold", "selling is logged")
	t.eq(shopper.event_log.entries[-1]["data"]["refund"], 3,
			"sell event carries the refund")
	var sell_gold := shopper.gold
	var sell_inventory := shopper.inventory.duplicate()
	var unowned_sale := shopper.sell("item_spirit_contract")
	t.ok(not unowned_sale["ok"] and not String(unowned_sale["error"]).is_empty(),
			"selling an unowned item is rejected")
	t.eq(shopper.gold, sell_gold, "unowned sale preserves gold")
	t.eq(shopper.inventory, sell_inventory, "unowned sale preserves inventory")
	t.eq(shopper.event_log.entries[-1]["type"], "command_rejected",
			"unowned sale rejection is logged")

	t.context("use item")
	var user := GameState.new(db, 42)
	user.start_new_run("hub_a")
	user.inventory["item_salve"] = 1
	user.player().hp = user.player().max_hp - 3
	var used := user.use_item("item_salve")
	t.ok(used["ok"], "using a consumable succeeds")
	t.eq(user.player().hp, user.player().max_hp, "consumable healing clamps to max HP")
	t.eq(user.inventory["item_salve"], 0, "using a consumable decrements inventory")
	t.eq(user.event_log.entries[-1]["type"], "item_used", "using an item is logged")
	t.eq(user.event_log.entries[-1]["data"]["heal_hp"], 3,
			"item event carries actual healing")

	user.inventory["item_spirit_contract"] = 1
	user.player().hp = user.player().max_hp - 4
	var injured_hp := user.player().hp
	var inert := user.use_item("item_spirit_contract")
	t.ok(not inert["ok"] and not String(inert["error"]).is_empty(),
			"using a spirit contract away from its destination is rejected")
	t.eq(user.inventory["item_spirit_contract"], 1,
			"rejected spirit contract use does not consume it")
	t.eq(user.player().hp, injured_hp,
			"rejected spirit contract use does not heal an injured player")
	t.eq(user.event_log.entries[-1]["type"], "command_rejected",
			"rejected spirit contract use is logged")

	var unowned_inventory := user.inventory.duplicate()
	var unowned_use := user.use_item("item_salve")
	t.ok(not unowned_use["ok"] and not String(unowned_use["error"]).is_empty(),
			"using an unowned item is rejected")
	t.eq(user.inventory, unowned_inventory, "unowned use preserves inventory")
	t.eq(user.player().hp, injured_hp, "unowned use preserves HP")
	t.eq(user.event_log.entries[-1]["type"], "command_rejected",
			"unowned use rejection is logged")

	t.context("determinism")
	var first_log := _run_fixed_commands(db)
	var second_log := _run_fixed_commands(db)
	t.eq(first_log, second_log,
			"same seed and enabling-system commands produce identical JSONL")


func _run_fixed_commands(db: ContentDB) -> String:
	var gs := GameState.new(db, 42)
	gs.start_new_run("hub_a_interior")
	gs.gold = 30
	gs.buy("item_salve")
	gs.use_item("item_salve")
	gs.move_to_area("hub_a")
	gs.rest()
	gs.move_to_area("road_b")
	return gs.event_log.to_jsonl()


func _party_vitals(gs: GameState) -> Array:
	return gs.party.map(func(actor: ActorState) -> Array: return [actor.hp, actor.qi])
