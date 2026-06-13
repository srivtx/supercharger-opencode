# supercharger-opencode

> A curated bundle of production-grade skills for [opencode](https://opencode.ai). One curl command to install. No npm, no auth, no version churn.

![GitHub stars](https://img.shields.io/github/stars/srivtx/supercharger-opencode)
![License](https://img.shields.io/badge/license-MIT-blue)
![Skills](https://img.shields.io/badge/skills-17-purple)

---

## Why

opencode's skill loader reads `SKILL.md` files from a small set of well-known locations. The hard part isn't installing — it's **finding skills worth installing**.

`supercharger-opencode` is a hand-picked bundle of 17 skills (5 categories) ported from the [Hermes Agent](https://github.com/just-every/hermes-agent) `creative/` collection and re-shelved for opencode. Each skill is self-contained, MIT-licensed, and tested.

No npm registry. No version bumps. No 2FA prompts. The repo IS the package.

---

## Quick start

```bash
curl -fsSL https://raw.githubusercontent.com/srivtx/supercharger-opencode/main/install.sh | bash -s -- add claude-design
```

Restart opencode. Done.

To install a whole category at once:

```bash
curl -fsSL https://raw.githubusercontent.com/srivtx/supercharger-opencode/main/install.sh | bash -s -- add design
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

### Examples

```bash
# install
./install.sh add claude-design
./install.sh add design
./install.sh add claude-design p5js humanizer

# browse
./install.sh list
./install.sh info p5js

# uninstall
./install.sh remove claude-design
./install.sh remove --all
```

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

### design — Web & Product Design

| Skill | Description | External deps |
|---|---|---|
| [`claude-design`](./design/claude-design) | Self-contained HTML artifacts (landing pages, decks, prototypes) with verified browser output. CLI port of Anthropic's hosted Claude Design. | browser |
| [`design-md`](./design/design-md) | Author, lint, diff, and export Google's `DESIGN.md` token-spec files. | Node, `npx @google/design.md` |
| [`popular-web-designs`](./design/popular-web-designs) | 54 ready-to-paste design systems (Stripe, Linear, Vercel, Notion, Airbnb, …). | Google Fonts CDN |
| [`sketch`](./design/sketch) | 2–3 disposable single-file HTML mockup variants for side-by-side comparison. | browser, Tailwind (optional) |
| [`visual-iteration-loop`](./design/visual-iteration-loop) | Meta-skill for navigating multi-turn design iteration (Fix-vs-Look mode). | none |

### diagrams — Diagrams & Infographics

| Skill | Description | External deps |
|---|---|---|
| [`architecture-diagram`](./diagrams/architecture-diagram) | Dark-themed inline-SVG cloud / infra architecture diagrams as a single self-contained HTML file. | JetBrains Mono |
| [`excalidraw`](./diagrams/excalidraw) | Hand-drawn `.excalidraw` JSON files (arch, flow, sequence, concept maps). | `cryptography` (optional upload) |
| [`baoyu-infographic`](./diagrams/baoyu-infographic) | `infographic.png` from any of 21 layouts × 21 styles. | `image_generate` tool |

### video — Video & Animation

| Skill | Description | External deps |
|---|---|---|
| [`ascii-video`](./video/ascii-video) | Colored ASCII MP4 / GIF (video-to-ASCII, audio-reactive, generative, hybrid, TTS). | Python, NumPy, SciPy, Pillow, ffmpeg |
| [`manim-video`](./video/manim-video) | 3Blue1Brown-style Manim CE explainer videos with optional voiceover. | Manim CE, LaTeX, ffmpeg |
| [`touchdesigner-mcp`](./video/touchdesigner-mcp) | Drive a running TouchDesigner instance via the twozero MCP. | TouchDesigner, twozero.tox |

### creative-coding — Creative Coding

| Skill | Description | External deps |
|---|---|---|
| [`p5js`](./creative-coding/p5js) | Single-file HTML p5.js sketches (gen art, shaders, interactive, 3D, audio-reactive). | p5.js CDN |
| [`pretext`](./creative-coding/pretext) | Text-flow, reflow, and kinetic typography demos with `@chenglou/pretext`. | pretext (esm.sh CDN) |
| [`ascii-art`](./creative-coding/ascii-art) | Terminal ASCII art (pyfiglet, cowsay, boxes, toilet, image-to-ASCII, QR, weather). | pyfiglet, cowsay, boxes, toilet |
| [`comfyui`](./creative-coding/comfyui) | ComfyUI image-generation control and node-pipeline authoring. | ComfyUI server, GPU, comfy-cli |

### writing-music — Writing & Music

| Skill | Description | External deps |
|---|---|---|
| [`humanizer`](./writing-music/humanizer) | Rewrites text to strip 29 AI-writing patterns and inject genuine voice. | none |
| [`songwriting-and-ai-music`](./writing-music/songwriting-and-ai-music) | Suno custom-mode packages (style description + metatagged lyrics). | Suno AI |

---

## How it works

The installer is a single self-contained bash script. When you run `add <skill>`, it:

1. Fetches `manifest.json` from the repo.
2. Looks up the skill's category.
3. Downloads the repo tarball (≈ 2.8 MB, gzipped) from `codeload.github.com`.
4. Extracts only the requested skill folder.
5. Copies it to `$SUPERCHARGER_INSTALL_DIR/<skill>/`.
6. Cleans up.

No git clone, no npm install, no node_modules. Just curl and tar.

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
└── writing-music/             # 2 skills
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

All 17 skills originated in the [Hermes Agent](https://github.com/just-every/hermes-agent) project's `creative/` collection. They are preserved as-is, with the following frontmatter fields being Hermes-specific and ignored by opencode:

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
