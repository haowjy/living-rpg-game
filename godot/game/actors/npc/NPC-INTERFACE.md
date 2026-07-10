# NPC body command socket

`NpcBody` is the collision-validating presentation boundary between an NPC's
decision maker and the visible world. The bundled `NpcBrain` is deterministic
and replaceable. A future LLM local oracle may drive the same five commands; it
does not receive authority to set transforms, bypass collision, or mutate the
game simulation/event log.

| Command | Effect |
|---|---|
| `move_to(world_pos: Vector2)` | Walk toward a world position using `move_and_slide`. |
| `face(direction: Vector2)` | Immediately face the dominant cardinal direction and idle. |
| `approach(target_node: Node2D)` | Follow a live target and stop at conversational distance. |
| `initiate_dialogue() -> bool` | Emit `wants_dialogue(npc_id)` if the UI is free; return `false` while busy. |
| `idle()` | Cancel movement and return to the standing frame. |

## Events and ownership

- `wants_dialogue(npc_id)` is re-emitted by `WorldView` through its existing
  `interacted("npc", npc_id)` contract.
- `command_finished` tells a brain that movement or approach completed.
- The body owns velocity, collision, facing, and animation. Brains own intent.
- `NpcBrain` uses a private seeded `RandomNumberGenerator`; this affects only
  presentation and never writes the deterministic simulation event log.
- A proactive brain waits briefly when dialogue, a menu, or combat is active,
  then aborts. Dialogue is never forced and cannot soft-lock the player.
