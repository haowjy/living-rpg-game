#!/usr/bin/env bash
set -o pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output_file="$(mktemp "${TMPDIR:-/tmp}/living-rpg-tests.XXXXXX")"
trap 'rm -f "$output_file"' EXIT

godot_bin="${GODOT_BIN:-godot}"
"$godot_bin" --headless --path "$project_dir" -s res://tests/run_tests.gd 2>&1 \
	| tee "$output_file"
godot_status=${PIPESTATUS[0]}

if (( godot_status != 0 )); then
	echo "Headless test command exited with status $godot_status." >&2
	exit "$godot_status"
fi

if grep -Eq 'SCRIPT ERROR:|ERROR: Failed to load script' "$output_file"; then
	echo "Headless test output contains a script load/runtime error." >&2
	exit 1
fi

if ! grep -Fq 'PASS —' "$output_file"; then
	echo "Headless test output is missing the final PASS marker." >&2
	exit 1
fi
