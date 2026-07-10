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

1. In `<hub A>`, talk to `<elder A>` → accept. You learn `<technique A; strike>` and the
   quest starts. Check the party panel (top right) shows the technique at *untrained*.
2. Talk to `<merchant B>` (shrine hint) and `<rival C>` (pre-quest line).
3. Exit west→`<road B>`. Fight the `<monster A>` pack: use `<technique A>` (it is *force* —
   watch the break meter on `<monster A>` deplete and the stun trigger), have
   `<companion A>` stack burn, watch statuses tick. Win.
4. Open the event log [L]: the fight should read as a story (damage, breaks, statuses,
   proficiency, victory).
5. Go north from the road to `<shrine D>`. Approach the altar → seal the pact.
   Confirm the vow: player max HP drops by 2; `<spirit A>` appears in the party panel.
6. Fight the road pack again (it is repeatable): `<spirit A>` acts first (fastest), Invoke
   hits all enemies, then the spirit shows *resting* and the player loses the +2 passive
   until it re-bonds. Technique uses accumulate — around the 3rd use, proficiency hits
   *novice* (event in the log).
7. Go to `<ruin C>`, approach the gate. Because the spirit is contracted you should see
   **both** resolutions: fight, or let `<spirit A>` negotiate.
   - Run A: negotiate. Quest resolves without combat.
   - Run B (fresh run or before contracting): fight the band.
8. Return to `<hub A>`: `<elder A>` and `<rival C>` have different dialogue depending on
   *how* you resolved it. The world remembered.
9. F3: confirm seed, area, and flags look right.

## What to judge

- Does the loop (explore → talk → fight → grow → choose) feel like a game yet?
- Is combat readable? Do breaks/statuses/spirit states make sense at a glance?
- Is the event log already telling a retellable story?

## Known intentional gaps

Placeholder art everywhere, no save/load, no sound, minimal balance, no reactive
timing layer (deferred by decision), single spirit/technique content.
