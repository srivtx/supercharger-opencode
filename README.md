# supercharger-opencode

> **68 production-grade skills** across **14 categories**, bundled into **9 curated presets** for [opencode](https://opencode.ai). One curl command. No npm, no auth, no version churn.

![Skills](https://img.shields.io/badge/skills-68-purple)
![Presets](https://img.shields.io/badge/presets-9-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Install](https://img.shields.io/badge/install-curl--only-orange)

---

## Quick start

The most popular entry point — the **design preset** — installs the full design category in one command:

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/srivtx/supercharger-opencode@main/install.sh | bash -s -- add design
```

Restart opencode. Done.

> **Why jsDelivr?** GitHub's `raw.githubusercontent.com` CDN is known to cache the previous main-branch version for 5–30+ minutes after a push. jsDelivr mirrors the same repo with a faster global CDN and more aggressive cache invalidation, so you always get the latest version immediately.

---

## Presets

Don't know where to start? Pick a preset. Each one is a curated mix of skills organized by **what you're trying to do** — not by source category.

| Preset | Skills | What it's for |
|---|---|---|
| `minimal` | 5 | The 5 essentials: TDD, debugging, planning, claude-design, pr-workflow. |
| `design` | 5 | The full design category. HTML artifacts, token specs, brand templates, mockups. |
| **`visual`** | **10** | **Design + diagrams + creative coding. The most popular preset.** |
| `creative` | 17 | Every creative skill. Design, video, music, art. |
| `frontend` | 19 | Visual + the dev workflow. For people who build UIs for a living. |
| `devops` | 14 | GitHub, MCP, debugging, multi-agent orchestration. |
| `researcher` | 10 | arXiv, wikis, blogs, papers, OCR. |
| `ml` | 12 | HuggingFace, Jupyter, arXiv, Python debugging. |
| `pm` | 12 | Documents, Notion, PowerPoint, Obsidian, OCR. |

```bash
# Browse all presets with details
curl -fsSL https://cdn.jsdelivr.net/gh/srivtx/supercharger-opencode@main/install.sh | bash -s -- presets

# See what's in one preset
curl -fsSL .../install.sh | bash -s -- info visual

# Install it
curl -fsSL .../install.sh | bash -s -- add visual
```

### Recommended ladders

**For designers:**
```bash
add design    # start here
add visual    # when you need diagrams + creative coding
add creative  # when you want everything
```

**For developers:**
```bash
add minimal     # the bare essentials
add frontend    # add design + dev workflow
add devops      # when you start doing infra
```

**For researchers / PMs / ML engineers:**
```bash
add researcher   # or `ml`, or `pm`
```

---

## Commands

| Command | What it does |
|---|---|
| `add <skill \| category \| preset> [...]` | Install skills, categories, or presets |
| `remove <skill> [...]` | Uninstall one or more skills |
| `remove --all` | Uninstall every supercharger-installed skill |
| `list` | Show all 68 skills with install status |
| `list-categories` | Show the 14 categories |
| `presets` | Show the 9 curated preset bundles |
| `info <skill \| category \| preset>` | Show details for one target |
| `help` | Show usage |

`add` resolves in order: **preset → skill → category**. Most specific match wins.

### Environment variables

| Variable | Default | Purpose |
|---|---|---|
| `SUPERCHARGER_INSTALL_DIR` | `~/.config/opencode/skill` | Where skills get installed |
| `SUPERCHARGER_BRANCH` | `main` | Which git ref to pull from |

---

## Requirements

- `curl` (universal)
- `tar` (universal)
- `jq` — `brew install jq` / `apt install jq` / `winget install jqlang.jq`

---

## Skills (the full 68)

If you want the raw list instead of a preset:

### design (5) — start here if you make UIs

| Skill | Description | External deps |
|---|---|---|
| `claude-design` | Self-contained HTML artifacts (landing pages, decks, prototypes) with verified browser output. CLI port of Anthropic's hosted Claude Design. | browser |
| `design-md` | Author, lint, diff, and export Google's `DESIGN.md` token-spec files. | Node, `npx @google/design.md` |
| `popular-web-designs` | 54 ready-to-paste design systems (Stripe, Linear, Vercel, Notion, Airbnb, …). | Google Fonts CDN |
| `sketch` | 2–3 disposable single-file HTML mockup variants for side-by-side comparison. | browser, Tailwind (optional) |
| `visual-iteration-loop` | Meta-skill for navigating multi-turn design iteration (Fix-vs-Look mode). | none |

### diagrams (3)

| Skill | Description | External deps |
|---|---|---|
| `architecture-diagram` | Dark-themed inline-SVG cloud / infra architecture diagrams. | JetBrains Mono |
| `excalidraw` | Hand-drawn `.excalidraw` JSON files. | `cryptography` (optional upload) |
| `baoyu-infographic` | `infographic.png` from any of 21 layouts × 21 styles. | `image_generate` tool |

### video (3)

| Skill | Description | External deps |
|---|---|---|
| `ascii-video` | Colored ASCII MP4 / GIF. | Python, NumPy, SciPy, Pillow, ffmpeg |
| `manim-video` | 3Blue1Brown-style Manim CE explainer videos. | Manim CE, LaTeX, ffmpeg |
| `touchdesigner-mcp` | Drive a running TouchDesigner instance via MCP. | TouchDesigner, twozero.tox |

### creative-coding (4)

| Skill | Description | External deps |
|---|---|---|
| `p5js` | Single-file HTML p5.js sketches. | p5.js CDN |
| `pretext` | Text-flow and kinetic typography demos. | pretext (esm.sh CDN) |
| `ascii-art` | Terminal ASCII art. | pyfiglet, cowsay, boxes, toilet |
| `comfyui` | ComfyUI image / video / audio generation. | ComfyUI server, GPU |

### writing (2)

| Skill | Description | External deps |
|---|---|---|
| `humanizer` | Rewrites text to strip 29 AI-writing patterns. | none |
| `songwriting-and-ai-music` | Suno custom-mode packages. | Suno AI |

### engineering (10) — the dev workflow

| Skill | Description | External deps |
|---|---|---|
| `test-driven-development` | RED-GREEN-REFACTOR TDD. | none |
| `systematic-debugging` | 4-phase root-cause debugging. | none |
| `simplify-code` | Parallel 3-agent cleanup of recent changes. | none |
| `plan` | Plan mode: write an actionable markdown plan. | none |
| `spike` | Throwaway experiments. | none |
| `requesting-code-review` | Pre-commit review: security, quality, auto-fix. | pre-commit |
| `skill-authoring` | Author in-repo SKILL.md files. | none |
| `node-inspect-debugger` | Debug Node.js via `--inspect` + Chrome DevTools. | Node, Chrome DevTools |
| `python-debugpy` | Debug Python: pdb REPL + debugpy remote. | Python, debugpy |
| `jupyter-live-kernel` | Iterative Python via a live Jupyter kernel. | Python, Jupyter |

### github (6)

| Skill | Description | External deps |
|---|---|---|
| `pr-workflow` | Full PR lifecycle: branch, commit, open, CI, merge. | `gh` CLI |
| `code-review` | Review PRs: diffs, inline comments. | `gh` CLI |
| `issues` | Create, triage, label, assign issues. | `gh` CLI |
| `auth` | GitHub auth setup. | none |
| `repo-management` | Clone, create, fork repos. | `gh` CLI |
| `codebase-inspection` | LOC, language ratios, complexity via pygount. | pygount |

### agents (6)

| Skill | Description | External deps |
|---|---|---|
| `opencode` | Delegate to the OpenCode CLI. | opencode CLI |
| `claude-code` | Delegate to the Claude Code CLI. | claude-code CLI |
| `codex` | Delegate to the OpenAI Codex CLI. | codex CLI |
| `hermes-agent` | Configure Hermes Agent. | hermes CLI |
| `kanban-orchestrator` | Decomposition playbook for an orchestrator. | hermes CLI |
| `kanban-worker` | Pitfalls for Kanban workers. | hermes CLI |

### research (5)

| Skill | Description | External deps |
|---|---|---|
| `arxiv` | Search arXiv papers. | none |
| `llm-wiki` | Karpathy-style interlinked markdown wiki. | none |
| `blogwatcher` | Monitor blogs and RSS/Atom feeds. | blogwatcher CLI |
| `polymarket` | Query Polymarket: markets, prices, orderbooks. | none |
| `research-paper-writing` | ML paper drafting for NeurIPS / ICML / ICLR. | none |

### documents (4)

| Skill | Description | External deps |
|---|---|---|
| `nano-pdf` | Edit PDFs via natural language. | nano-pdf CLI |
| `ocr-and-documents` | Extract text from PDFs / scans. | pymupdf, marker-pdf |
| `youtube-content` | Pull YouTube transcripts. | none |
| `maps` | Geocode, POIs, routes, timezones. | none |

### productivity (7)

| Skill | Description | External deps |
|---|---|---|
| `notion` | Notion API and ntn CLI. | ntn CLI |
| `airtable` | Airtable REST API. | none |
| `google-workspace` | Gmail, Calendar, Drive, Docs, Sheets. | gws CLI |
| `powerpoint` | Create, read, edit `.pptx` decks. | python-pptx |
| `obsidian` | Read, search, edit Obsidian vault notes. | none |
| `himalaya` | IMAP/SMTP email from the terminal. | himalaya CLI |
| `teams-pipeline` | Teams meeting-summary pipeline. | hermes CLI, Teams |

### data (3)

| Skill | Description | External deps |
|---|---|---|
| `huggingface-hub` | HuggingFace hf CLI. | hf CLI |
| `fastmcp` | Build MCP servers in Python. | Python, fastmcp |
| `mcporter` | Call MCP servers and tools. | mcporter CLI |

### crypto (3)

| Skill | Description | External deps |
|---|---|---|
| `evm` | Read-only EVM client across 8 chains. | evm CLI |
| `solana` | Query Solana blockchain data. | solana CLI |
| `hyperliquid` | Hyperliquid market data. | none |

### platform (7) — OS- or device-locked

| Skill | Description | External deps |
|---|---|---|
| `apple-notes` | Apple Notes via memo CLI. | memo CLI, macOS |
| `apple-reminders` | Apple Reminders via remindctl. | remindctl, macOS |
| `findmy` | Track Apple devices and AirTags. | macOS |
| `imessage` | iMessage / SMS via imsg CLI. | imsg CLI, macOS |
| `macos-computer-use` | Drive the macOS desktop in the background. | `computer_use` tool, macOS |
| `openhue` | Philips Hue lights. | OpenHue CLI |
| `xurl` | X / Twitter CLI. | xurl CLI |

---

## How it works

The installer is a single self-contained bash script. When you run `add <target>`, it:

1. Fetches `manifest.json` from the repo via jsDelivr.
2. Resolves `<target>` against presets, then skills, then categories.
3. Downloads the repo tarball once (≈ 2–3 MB, gzipped) from `codeload.github.com`.
4. Extracts every requested skill from the cached tarball.
5. Copies them to `$SUPERCHARGER_INSTALL_DIR/<skill>/`.
6. Cleans up.

No git clone, no npm install, no `node_modules`. One download per `add` call regardless of how many skills you install.

---

## Repo layout

```
.
├── install.sh                 # the installer
├── manifest.json              # canonical skill + preset catalog
├── README.md
├── design/                    # 5 skills
├── diagrams/                  # 3 skills
├── video/                     # 3 skills
├── creative-coding/           # 4 skills
├── writing/                   # 2 skills
├── engineering/               # 10 skills
├── github/                    # 6 skills
├── agents/                    # 6 skills
├── research/                  # 5 skills
├── documents/                 # 4 skills
├── productivity/              # 7 skills
├── data/                      # 3 skills
├── crypto/                    # 3 skills
└── platform/                  # 7 skills
```

---

## Updating a skill

Skills are pulled from `main` on every install. To refresh, remove and re-add:

```bash
./install.sh remove p5js && ./install.sh add p5js
```

If you've cloned the repo, `git pull` first.

---

## Provenance

All 68 skills originated in the [Hermes Agent](https://github.com/just-every/hermes-agent) project's `skills/` and `optional-skills/` collections. They are preserved as-is, with the following frontmatter fields being Hermes-specific and ignored by opencode:

- `metadata.hermes.tags`
- `metadata.triggers`
- `platforms`

Each skill retains its original license (see `LICENSE` in each skill directory; most are MIT).

---

## Adding a new skill or preset

**New skill:**
1. Create `<category>/<skill-name>/SKILL.md` with at minimum:
   ```yaml
   ---
   name: my-skill
   description: One sentence covering what the skill does and when to trigger it.
   ---
   ```
2. Add an entry to the top-level `manifest.json` under `categories.<cat>.skills` and `skills.<skill-name>`.
3. Open a PR.

**New preset:**
1. Add a `presets.<preset-name>` block to `manifest.json`:
   ```json
   "my-preset": {
     "label": "My Preset",
     "tagline": "Short hook for the table.",
     "description": "One paragraph explaining who this is for.",
     "skills": ["skill-1", "skill-2", "skill-3"]
   }
   ```
2. Open a PR.

---

## License

MIT. See [LICENSE](./LICENSE) for details.

Individual skills retain their own licenses — see each `LICENSE` file.
