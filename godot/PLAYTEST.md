# Playtest Checklist — First Deterministic Slice

## Run it

```bash
# Verify the project boots headless (no errors expected):
/Applications/Godot.app/Contents/MacOS/Godot --headless --path godot --quit

# Run the sim test suite (exits 0 when green):
/Applications/Godot.app/Contents/MacOS/Godot --headless --path godot -s res://tests/run_tests.gd

# Play:
/Applications/Godot.app/Contents/MacOS/Godot --path godot
```

Controls: **WASD/arrows** move · **E** interact · **L** event log · **F3** debug overlay.

## Happy path

1. In `<hub A>`, confirm `<technique A; strike>` starts at *competent*. Talk to `<reeve F>`
   about the bounty, then take `<elder A>`'s task.
2. Enter the hub shop, buy `<spirit contract>` from `<merchant B>`, and return outside.
3. On `<road B>`, answer `<mentor E>`'s question and learn `<technique D>`. Fight the
   repeatable pack once.
4. At `<shrine D>`, approach the altar. Confirm `<warden G>` offers exactly three spirits;
   choose one and confirm it joins without changing the player's HP.
5. At `<ruin C>`, confirm `<captain H>` shows the old watch colors and unpaid charter.
   Verify each resolution on a fresh run: fight; reinstate the watch with a spirit; or take
   the charter and present it to `<reeve F>`.
6. After reinstatement, revisit `<road B>` and confirm the repeating encounter is absent.
7. Back in `<hub A>`, check `<rival C>`'s resolution-specific reaction, learn
   `<technique C; guard stance>` from `<elder A>`, and hear `<marshal D>`'s unanswered offer.
8. Open the event log [L] and debug overlay [F3]; confirm the chosen path and flags are shown.

## What to judge

- Does the loop (explore → talk → fight → grow → choose) feel like a game yet?
- Is combat readable? Do breaks/statuses/spirit states make sense at a glance?
- Is the event log already telling a retellable story?

## Known intentional gaps

Placeholder art everywhere, no save/load, no sound, minimal balance, no reactive
timing layer (deferred by decision), single spirit/technique content.
