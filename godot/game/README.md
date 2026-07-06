# Game Scaffold

This folder holds the deterministic Godot prototype. The structure is domain-based so scenes, scripts, resources, and local assets can stay near the gameplay concept they serve.

Use smaller files and focused folders by default. A good folder gives an agent enough context to make a change without reading the whole project; a good file does one real job and can be read top to bottom.

Start with a small free-form 2D vertical slice:

- One authored area.
- Player movement.
- One NPC interaction.
- One state-changing choice.
- One exit or area transition.
- One conflict or risk resolution.
- UI that shows location, options, character state, and memory/event changes.
- Debug output that makes state changes and errors inspectable.

Do not fill every folder before there is real behavior. Add files when a playable slice needs them.
