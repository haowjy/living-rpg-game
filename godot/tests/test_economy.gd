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
	away.player().hp = 3
	var rejected := away.rest()
	t.ok(not rejected["ok"], "resting away from the hub is rejected")
	t.eq(away.player().hp, 3, "rejected rest does not restore HP")
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
	t.ok(not no_merchant["ok"], "buying without a present merchant is rejected")
	t.eq(remote.gold, 30, "rejected remote purchase does not deduct gold")
	t.eq(remote.event_log.entries[-1]["type"], "command_rejected",
			"remote purchase rejection is logged")

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
	var inert := user.use_item("item_spirit_contract")
	t.ok(not inert["ok"], "using a spirit contract away from its destination is rejected")
	t.eq(inert["error"], "Nothing happens here.", "spirit contract rejection is explicit")
	t.eq(user.inventory["item_spirit_contract"], 1,
			"rejected spirit contract use does not consume it")
	t.eq(user.event_log.entries[-1]["type"], "command_rejected",
			"rejected spirit contract use is logged")

	t.context("consume seam")
	user.inventory["item_salve"] = 2
	t.ok(user._consume_item("item_salve"), "consume helper reports an owned item")
	t.eq(user.inventory["item_salve"], 1, "consume helper decrements an owned item")
	t.ok(not user._consume_item("missing"), "consume helper rejects an absent item")
	t.eq(user.inventory.get("missing", 0), 0,
			"consume helper does not create an absent inventory entry")

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
