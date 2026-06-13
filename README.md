# supercharger-opencode

> A curated bundle of **68 production-grade skills** across **14 categories** for [opencode](https://opencode.ai). One curl command to install. No npm, no auth, no version churn.

![Skills](https://img.shields.io/badge/skills-68-purple)
![Categories](https://img.shields.io/badge/categories-14-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Installs](https://img.shields.io/badge/installs-curl--only-orange)

---

## Why

opencode's skill loader reads `SKILL.md` files from a small set of well-known locations. The hard part isn't installing — it's **finding skills worth installing**.

`supercharger-opencode` is a hand-picked bundle of 68 skills ported from the [Hermes Agent](https://github.com/just-every/hermes-agent) `creative/`, `engineering/`, `github/`, `research/`, and other collections, re-shelved for opencode and organized by **what a user is trying to do**, not by source-of-origin.

No npm registry. No version bumps. No 2FA prompts. The repo IS the package.

---

## Quick start

```bash
curl -fsSL https://raw.githubusercontent.com/srivtx/supercharger-opencode/main/install.sh | bash -s -- add claude-design
```

Restart opencode. Done.

Install a whole category at once:

```bash
curl -fsSL https://raw.githubusercontent.com/srivtx/supercharger-opencode/main/install.sh | bash -s -- add engineering
```

---

## Starter combo

New to opencode? Run these three commands and you have the essentials:

```bash
# 1) day-to-day engineering: TDD, debugging, code review
curl -fsSL https://raw.githubusercontent.com/srivtx/supercharger-opencode/main/install.sh | bash -s -- add engineering

# 2) GitHub workflow: PRs, code review, issues
curl -fsSL https://raw.githubusercontent.com/srivtx/supercharger-opencode/main/install.sh | bash -s -- add github

# 3) visual polish when you need it
curl -fsSL https://raw.githubusercontent.com/srivtx/supercharger-opencode/main/install.sh | bash -s -- add design diagrams
```

That's 28 skills loaded with three commands. Browse the rest:

```bash
curl -fsSL https://raw.githubusercontent.com/srivtx/supercharger-opencode/main/install.sh | bash -s -- list
```

---

## Commands

| Command | What it does |
|---|---|
| `add <skill> [...]` | Install one or more skills |
| `add <category>` | Install every skill in a category |
| `remove <skill> [...]` | Uninstall one or more skills |
| `remove --all` | Uninstall every supercharger-installed skill |
| `list` | Show all available skills with install status |
| `list-categories` | Show category summary |
| `info <skill>` | Show description and dependencies for one skill |
| `help` | Show usage |

All commands work the same whether invoked locally (after `git clone`) or piped from curl.

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

## Skills

### design — Web & Product Design (5)

| Skill | Description | External deps |
|---|---|---|
| `claude-design` | Self-contained HTML artifacts (landing pages, decks, prototypes) with verified browser output. CLI port of Anthropic's hosted Claude Design. | browser |
| `design-md` | Author, lint, diff, and export Google's `DESIGN.md` token-spec files. | Node, `npx @google/design.md` |
| `popular-web-designs` | 54 ready-to-paste design systems (Stripe, Linear, Vercel, Notion, Airbnb, …). | Google Fonts CDN |
| `sketch` | 2–3 disposable single-file HTML mockup variants for side-by-side comparison. | browser, Tailwind (optional) |
| `visual-iteration-loop` | Meta-skill for navigating multi-turn design iteration (Fix-vs-Look mode). | none |

### diagrams — Diagrams & Infographics (3)

| Skill | Description | External deps |
|---|---|---|
| `architecture-diagram` | Dark-themed inline-SVG cloud / infra architecture diagrams as a single self-contained HTML file. | JetBrains Mono |
| `excalidraw` | Hand-drawn `.excalidraw` JSON files (arch, flow, sequence, concept maps). | `cryptography` (optional upload) |
| `baoyu-infographic` | `infographic.png` from any of 21 layouts × 21 styles. | `image_generate` tool |

### video — Video & Animation (3)

| Skill | Description | External deps |
|---|---|---|
| `ascii-video` | Colored ASCII MP4 / GIF (video-to-ASCII, audio-reactive, generative, hybrid, TTS). | Python, NumPy, SciPy, Pillow, ffmpeg |
| `manim-video` | 3Blue1Brown-style Manim CE explainer videos with optional voiceover. | Manim CE, LaTeX, ffmpeg |
| `touchdesigner-mcp` | Drive a running TouchDesigner instance via the twozero MCP. | TouchDesigner, twozero.tox |

### creative-coding — Creative Coding (4)

| Skill | Description | External deps |
|---|---|---|
| `p5js` | Single-file HTML p5.js sketches (gen art, shaders, interactive, 3D, audio-reactive). | p5.js CDN |
| `pretext` | Text-flow, reflow, and kinetic typography demos with `@chenglou/pretext`. | pretext (esm.sh CDN) |
| `ascii-art` | Terminal ASCII art (pyfiglet, cowsay, boxes, toilet, image-to-ASCII, QR, weather). | pyfiglet, cowsay, boxes, toilet |
| `comfyui` | ComfyUI image, video, and audio generation: install, manage nodes/models, run workflows. | ComfyUI server, GPU, comfy-cli |

### writing — Writing & Music (2)

| Skill | Description | External deps |
|---|---|---|
| `humanizer` | Rewrites text to strip 29 AI-writing patterns and inject genuine voice. | none |
| `songwriting-and-ai-music` | Suno custom-mode packages (style description + metatagged lyrics). | Suno AI |

### engineering — Day-to-day dev workflow (10)

| Skill | Description | External deps |
|---|---|---|
| `test-driven-development` | Enforce RED-GREEN-REFACTOR TDD: write failing tests first, then make them pass. | none |
| `systematic-debugging` | 4-phase root-cause debugging methodology: understand the bug before fixing it. | none |
| `simplify-code` | Parallel 3-agent cleanup of recent code changes for clarity and simplicity. | none |
| `plan` | Plan mode: write an actionable markdown plan with bite-sized tasks. No execution. | none |
| `spike` | Throwaway experiments to validate an idea before committing to a build. | none |
| `requesting-code-review` | Pre-commit review: security scan, quality gates, auto-fix. | pre-commit |
| `skill-authoring` | Author in-repo SKILL.md files with correct frontmatter, structure, and validator. | none |
| `node-inspect-debugger` | Debug Node.js via `--inspect` and Chrome DevTools Protocol CLI. | Node, Chrome DevTools |
| `python-debugpy` | Debug Python: pdb REPL and debugpy remote (DAP) attach. | Python, debugpy |
| `jupyter-live-kernel` | Iterative Python via a live Jupyter kernel. | Python, Jupyter |

### github — GitHub workflow (6)

| Skill | Description | External deps |
|---|---|---|
| `pr-workflow` | Full PR lifecycle: branch, commit, open, watch CI, merge. | `gh` CLI |
| `code-review` | Review PRs: diffs, inline comments via `gh` or REST. | `gh` CLI |
| `issues` | Create, triage, label, and assign issues via `gh` or REST. | `gh` CLI |
| `auth` | GitHub auth setup: HTTPS tokens, SSH keys, `gh` CLI login. | none |
| `repo-management` | Clone, create, fork repos. Manage remotes and releases. | `gh` CLI |
| `codebase-inspection` | Inspect codebases: LOC, language ratios, complexity via pygount. | pygount |

### agents — Multi-agent orchestration (6)

| Skill | Description | External deps |
|---|---|---|
| `opencode` | Delegate coding tasks to the OpenCode CLI. | opencode CLI |
| `claude-code` | Delegate coding to the Claude Code CLI. | claude-code CLI |
| `codex` | Delegate coding to the OpenAI Codex CLI. | codex CLI |
| `hermes-agent` | Configure, extend, or contribute to Hermes Agent itself. | hermes CLI |
| `kanban-orchestrator` | Decomposition playbook for an orchestrator routing work through Hermes Kanban. | hermes CLI |
| `kanban-worker` | Pitfalls and examples for Hermes Kanban workers executing individual tasks. | hermes CLI |

### research — Research & learning (5)

| Skill | Description | External deps |
|---|---|---|
| `arxiv` | Search arXiv papers by keyword, author, category, or paper ID. | none |
| `llm-wiki` | Karpathy-style LLM Wiki: build and query an interlinked markdown knowledge base. | none |
| `blogwatcher` | Monitor blogs and RSS/Atom feeds for new posts. | blogwatcher CLI |
| `polymarket` | Query Polymarket: markets, prices, orderbooks, trade history. | none |
| `research-paper-writing` | Write ML papers for NeurIPS / ICML / ICLR: design, experiments, submission. | none |

### documents — Documents & Media (4)

| Skill | Description | External deps |
|---|---|---|
| `nano-pdf` | Edit PDF text, typos, and titles via natural-language prompts. | nano-pdf CLI |
| `ocr-and-documents` | Extract text from PDFs and scans using pymupdf and marker-pdf. | pymupdf, marker-pdf |
| `youtube-content` | Pull YouTube transcripts and turn them into summaries, threads, or blog posts. | none |
| `maps` | Geocode, POIs, routes, timezones via OpenStreetMap and OSRM. | none |

### productivity — Productivity integrations (7)

| Skill | Description | External deps |
|---|---|---|
| `notion` | Notion API and ntn CLI: pages, databases, markdown, Workers. | ntn CLI |
| `airtable` | Airtable REST API via curl: records CRUD, filters, upserts. | none |
| `google-workspace` | Gmail, Calendar, Drive, Docs, Sheets via the gws CLI. | gws CLI |
| `powerpoint` | Create, read, and edit `.pptx` decks. | python-pptx |
| `obsidian` | Read, search, create, and edit notes in an Obsidian vault. | none |
| `himalaya` | Himalaya CLI: read and send IMAP/SMTP email from the terminal. | himalaya CLI |
| `teams-pipeline` | Operate the Teams meeting-summary pipeline via Hermes CLI. | hermes CLI, Teams |

### data — Data & ML (3)

| Skill | Description | External deps |
|---|---|---|
| `huggingface-hub` | HuggingFace hf CLI: search, download, and upload models and datasets. | hf CLI |
| `fastmcp` | Build, test, inspect, install, and deploy MCP servers in Python. | Python, fastmcp |
| `mcporter` | Use the mcporter CLI to list, configure, auth, and call MCP servers and tools. | mcporter CLI |

### crypto — Crypto (3)

| Skill | Description | External deps |
|---|---|---|
| `evm` | Read-only EVM client: wallets, tokens, gas across 8 chains. | evm CLI |
| `solana` | Query Solana blockchain data with USD pricing. | solana CLI |
| `hyperliquid` | Hyperliquid market data, account history, trade review. | none |

### platform — Platform-locked (7)

| Skill | Description | External deps |
|---|---|---|
| `apple-notes` | Manage Apple Notes via the memo CLI (macOS only). | memo CLI, macOS |
| `apple-reminders` | Apple Reminders via remindctl (macOS only). | remindctl, macOS |
| `findmy` | Track Apple devices and AirTags via FindMy.app (macOS only). | macOS |
| `imessage` | Send and receive iMessages / SMS via the imsg CLI (macOS only). | imsg CLI, macOS |
| `macos-computer-use` | Drive the macOS desktop in the background: screenshots, mouse, keyboard. | `computer_use` tool, macOS |
| `openhue` | Control Philips Hue lights, scenes, and rooms. | OpenHue CLI |
| `xurl` | X / Twitter via the xurl CLI: post, search, DM, media. | xurl CLI |

---

## How it works

The installer is a single self-contained bash script. When you run `add <skill>`, it:

1. Fetches `manifest.json` from the repo.
2. Looks up the skill's category.
3. Downloads the repo tarball (≈ 2–3 MB, gzipped) from `codeload.github.com`.
4. Extracts only the requested skill folder.
5. Copies it to `$SUPERCHARGER_INSTALL_DIR/<skill>/`.
6. Cleans up.

No git clone, no npm install, no `node_modules`. Just curl and tar.

---

## Repo layout

```
.
├── install.sh                 # the installer
├── manifest.json              # canonical skill catalog
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

Each skill is a self-contained directory:

```
<category>/<skill>/
├── SKILL.md                   # required
├── LICENSE                    # usually MIT
├── references/                # optional
├── templates/                 # optional
└── scripts/                   # optional
```

---

## Updating a skill

Skills are pulled from `main` on every install. To refresh an installed skill, remove and re-add it:

```bash
./install.sh remove p5js && ./install.sh add p5js
```

If you've cloned the repo locally, `git pull` first.

---

## Provenance

All 68 skills originated in the [Hermes Agent](https://github.com/just-every/hermes-agent) project's `skills/` and `optional-skills/` collections. They are preserved as-is, with the following frontmatter fields being Hermes-specific and ignored by opencode:

- `metadata.hermes.tags`
- `metadata.triggers`
- `platforms`

Each skill retains its original license (see `LICENSE` in each skill directory; most are MIT).

---

## Adding a new skill

1. Create `<category>/<skill-name>/SKILL.md` with at minimum:

   ```yaml
   ---
   name: my-skill
   description: One sentence covering what the skill does and when to trigger it.
   ---
   ```

2. Add an entry to the top-level `manifest.json` under `categories.<cat>.skills` (and add the category if new) and `skills.<skill-name>`.

3. Open a PR.

---

## License

MIT. See [LICENSE](./LICENSE) for details.

Individual skills retain their own licenses — see each `LICENSE` file.
