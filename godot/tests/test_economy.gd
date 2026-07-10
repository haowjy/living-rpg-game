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

	t.context("rest")
	var resting := GameState.new(db, 42)
	resting.start_new_run("hub_a")
	resting.time_of_day = 2
	resting.player().hp = 3
	resting.player().qi = 1
	var rested := resting.rest()
	t.ok(rested["ok"], "resting at the hub succeeds")
	t.eq(resting.player().hp, resting.player().max_hp, "rest restores HP")
	t.eq(resting.player().qi, resting.player().max_qi, "rest restores qi")
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
