class_name EventLog
extends RefCounted
## Append-only log of everything that happens in a run.
##
## Events are plain Dictionaries so the log is trivially serializable
## (JSONL) and can later be handed to the LLM layer as a data contract.
## The log is the world's memory: UI panels render it, tests replay it.

signal event_appended(event: Dictionary)

var entries: Array[Dictionary] = []
var _next_seq: int = 0


## Appends an event and returns it. `data` must contain only JSON-safe values.
func append(type: String, summary: String, data: Dictionary = {}) -> Dictionary:
	var event := {
		"seq": _next_seq,
		"type": type,
		"summary": summary,
		"data": data,
	}
	_next_seq += 1
	entries.append(event)
	event_appended.emit(event)
	return event


func latest(count: int) -> Array[Dictionary]:
	var start: int = maxi(0, entries.size() - count)
	return entries.slice(start)


func of_type(type: String) -> Array[Dictionary]:
	return entries.filter(func(e: Dictionary) -> bool: return e["type"] == type)


func to_jsonl() -> String:
	var lines := PackedStringArray()
	for event in entries:
		lines.append(JSON.stringify(event))
	return "\n".join(lines)


## Writes the log to a file (used for post-run inspection, not saves).
func dump_to_file(path: String) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(to_jsonl())
	file.close()
	return OK
