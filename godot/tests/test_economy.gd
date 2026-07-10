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
