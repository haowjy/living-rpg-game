# Godot Workflow

This repo should optimize for coherent progress, not maximum parallelism.

## Default Cadence

Work one meaningful slice at a time on the main checkout until the gameplay architecture stabilizes.

Use worktrees only for:

- Isolated text-heavy tasks.
- Backend/tooling experiments.
- Throwaway UI prototypes.
- Review or comparison branches.

Avoid worktrees for:

- Scene restructuring.
- Asset integration.
- Large `.tscn`, `.tres`, `.res`, texture, audio, or model changes.

## Asset Policy

Game worktrees duplicate checked-out files. That is expensive for assets and can make playtesting confusing.

Use this split:

```text
godot/assets/            tracked runtime assets, branch-owned
godot/external_assets/   ignored local shared asset mount
art-source/              future source art, outside git (cloud or separate storage)
```

Only symlink assets that are intentionally shared and read-only. Do not symlink tracked branch-specific assets wholesale.

## Git LFS

Not used (decided 2026-07-10, verified against GitHub billing docs and Godot
guidance). Game-ready 2D exports stay in plain git; source masters
(PSD/Aseprite/Blender/audio) stay out of the repo entirely.

Revisit only when a file class is both large and frequently revised, or the
repo approaches GitHub's practical limits (50 MiB/file warning, 100 MiB
block, ~1 GB repo guidance). If adopted: track selectively by extension via
`.gitattributes`, never blanket; every agent/CI download of LFS objects
bills against the 10 GB/month bandwidth quota, and worktrees need
`git lfs install --worktree`.

## Godot MCP

The project vendors the Godot AI addon in `godot/addons/godot_ai` and enables it in `godot/project.godot`.

All three clients have tracked project-scoped config:

- Claude Code: `.mcp.json`. Project-scoped servers stay "pending approval" until the workspace is trusted; approve on first use.
- Codex: `.codex/config.toml`, auto-loaded once the project is trusted. If you decline trust, `scripts/codex-godot` injects the same server via `-c` flags.
- opencode: `opencode.json` (`mcp.godot-ai`, `type: "remote"`).

All point to:

```text
http://127.0.0.1:8000/mcp
```

The endpoint is available only when the Godot editor/plugin has started the MCP server. If a client reports that `godot-ai` is configured but cannot connect, open the project in Godot first:

```bash
godot --path godot
```

Then enable or check the plugin at:

```text
Project > Project Settings > Plugins > Godot AI
```

Use MCP for editor introspection, scene tree inspection, script attachment, and visual/debug feedback. Do not use it as a substitute for deterministic tests or for broad, unreviewed scene rewrites.
