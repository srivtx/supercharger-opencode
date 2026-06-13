# supercharger-opencode

A curated bundle of high-quality skills for [opencode](https://opencode.ai). Each skill is a self-contained `SKILL.md` (plus optional references, templates, scripts) that opencode's loader picks up from `~/.config/opencode/skill/<name>/`.

Skills are organized by category at the top level of the repo. No npm, no version churn, no auth — just curl.

## Install

You don't need to clone the repo. One command does it all:

```bash
curl -fsSL https://raw.githubusercontent.com/srivtx/supercharger-opencode/main/install.sh | bash -s -- add claude-design
```

That fetches the manifest, downloads `design/claude-design/` from the repo, and copies it to `~/.config/opencode/skill/claude-design/`. Restart opencode and it's loaded.

Or if you prefer a local clone:

```bash
git clone https://github.com/srivtx/supercharger-opencode.git
cd supercharger-opencode
./install.sh add claude-design
```

## Commands

```bash
# install
./install.sh add claude-design                 # one skill
./install.sh add design                        # whole category (5 skills)
./install.sh add claude-design p5js humanizer  # several at once

# browse
./install.sh list                  # all skills, with install status
./install.sh list-categories       # category summary
./install.sh info p5js             # details for one skill

# uninstall
./install.sh remove claude-design  # remove one
./install.sh remove --all          # remove ALL supercharger skills at once
```

The same commands work via curl too:

```bash
curl -fsSL https://raw.githubusercontent.com/srivtx/supercharger-opencode/main/install.sh | bash -s -- list
curl -fsSL .../install.sh | bash -s -- info p5js
```

## What's inside

### design/ — Web & Product Design

| Skill | What it does | External deps |
|---|---|---|
| `claude-design` | One-off self-contained HTML artifacts (landing, deck, prototype) with verified browser output. CLI port of Anthropic's hosted Claude Design. | browser |
| `design-md` | Author / lint / diff / export Google's `DESIGN.md` token-spec files. | Node + `npx @google/design.md` |
| `popular-web-designs` | 54 ready-to-paste design systems (Stripe, Linear, Vercel, Notion, Airbnb, etc.). | Google Fonts CDN |
| `sketch` | 2–3 disposable single-file HTML mockup variants for side-by-side comparison. | browser; Tailwind optional |
| `visual-iteration-loop` | Meta-skill for navigating multi-turn design iteration (Fix-vs-Look mode). | none |

### diagrams/ — Diagrams & Infographics

| Skill | What it does | External deps |
|---|---|---|
| `architecture-diagram` | Dark-themed inline-SVG cloud/infra architecture diagrams as one self-contained HTML file. | JetBrains Mono |
| `excalidraw` | Hand-drawn `.excalidraw` JSON files (arch, flow, sequence, concept maps). | `cryptography` pip (optional upload) |
| `baoyu-infographic` | `infographic.png` from any of 21 layouts × 21 styles. | `image_generate` tool |

### video/ — Video & Animation

| Skill | What it does | External deps |
|---|---|---|
| `ascii-video` | Colored ASCII MP4/GIF (video-to-ASCII, audio-reactive, generative, hybrid, TTS). | Python, NumPy, SciPy, Pillow, ffmpeg |
| `manim-video` | 3Blue1Brown-style Manim CE explainer videos. | Manim CE, LaTeX, ffmpeg |
| `touchdesigner-mcp` | Drive a running TouchDesigner instance via the twozero MCP. | TouchDesigner, twozero.tox |

### creative-coding/ — Creative Coding

| Skill | What it does | External deps |
|---|---|---|
| `p5js` | Single-file HTML p5.js sketches (gen art, shaders, interactive, 3D, audio-reactive). | p5.js, Puppeteer (optional export) |
| `pretext` | Text-flow / reflow / kinetic typography demos with `@chenglou/pretext`. | pretext (esm.sh CDN) |
| `ascii-art` | Terminal ASCII art (pyfiglet, cowsay, boxes, toilet, image-to-ASCII, QR, weather). | pyfiglet, cowsay, boxes, toilet |
| `comfyui` | ComfyUI image generation control and node pipeline authoring. | ComfyUI server, GPU, comfy-cli |

### writing-music/ — Writing & Music

| Skill | What it does | External deps |
|---|---|---|
| `humanizer` | Rewrites text to strip 29 AI-writing patterns and add genuine voice. | none |
| `songwriting-and-ai-music` | Suno custom-mode packages (style description + metatagged lyrics). | Suno AI |

## Requirements

- `curl` and `tar` (universal)
- `jq` — `brew install jq` / `apt install jq` / `winget install jqlang.jq`

## Environment variables

| Var | Default | What it does |
|---|---|---|
| `SUPERCHARGER_INSTALL_DIR` | `~/.config/opencode/skill` | Where skills get installed |
| `SUPERCHARGER_BRANCH` | `main` | Which branch of the repo to pull from |

## Repo layout

```
supercharger-opencode/
├── install.sh                 # the installer
├── manifest.json              # skill catalog (the source of truth)
├── README.md
└── <category>/
    └── <skill>/
        ├── SKILL.md
        └── (optional) references/, templates/, scripts/
```

## Updating a skill

Skills are pulled from `main` on every install. To update a skill you've already installed, remove it then re-add it:

```bash
./install.sh remove p5js && ./install.sh add p5js
```

Or `git pull` and re-run `./install.sh add p5js` from a local clone.

## Provenance

Skills are ported from the [Hermes Agent](https://github.com/just-every/hermes-agent) `creative/` collection. Frontmatter fields specific to Hermes (`metadata.hermes.tags`, `platforms`, `triggers`) are preserved but ignored by opencode. Each skill retains its original license (most are MIT).
