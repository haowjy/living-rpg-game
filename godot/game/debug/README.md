# Debug And Observability

Debugging is part of the prototype, not a later cleanup pass.

The first playable slice should include:

- A small debug overlay that can show current area, player position, interactable target, active flags, and recent events.
- A serializable action/event trace so behavior can be replayed or inspected without reading prose.
- Clear error output for invalid actions, missing resources, bad area ids, and failed state transitions.
- A way to dump current deterministic state from the running game.

Keep this folder for Godot-local inspection tools. General test runners or repo scripts belong outside Godot.

Do not route normal gameplay through debug tools. Debug code observes state; it should not become the source of state.
