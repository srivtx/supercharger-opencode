# supercharger-opencode

A curated bundle of high-quality skills for [opencode](https://opencode.ai), ported from the [Hermes Agent](https://github.com/just-every/hermes-agent) creative skills collection and repackaged for opencode's skill loader.

Each skill is self-contained: a `SKILL.md` plus optional `references/`, `templates/`, and `scripts/` directories. opencode's loader picks them up from any of these locations:

- `.opencode/skill/<name>/SKILL.md` (project)
- `~/.config/opencode/skill/<name>/SKILL.md` (global)
- `~/.claude/skills/<name>/SKILL.md` (auto-loaded)
- `skills.paths` / `skills.urls` in `opencode.json`

## Quick start

```bash
# Install all skills globally
./install.sh

# Or install just a few
./install.sh claude-design humanizer design-md

# Restart opencode
```

`install.sh` copies each skill directory into `~/.config/opencode/skill/<name>/`. Remove with `./uninstall.sh`.

## What's inside

### Web & Product Design

| Skill | Purpose | External deps |
|---|---|---|
| `claude-design` | One-off self-contained HTML artifacts (landing, deck, prototype) with verified browser output. CLI port of Anthropic's hosted Claude Design. | browser |
| `design-md` | Author / lint / diff / export Google's `DESIGN.md` token-spec files. | Node + `npx @google/design.md` |
| `popular-web-designs` | 54 ready-to-paste design systems — Stripe, Linear, Vercel, Notion, Airbnb, and more. | Google Fonts CDN |
| `sketch` | 2–3 disposable single-file HTML mockup variants for side-by-side design comparison. | browser; Tailwind optional |
| `visual-iteration-loop` | Meta-skill for navigating multi-turn design iteration (Fix-vs-Look mode). | none |

### Diagrams & Infographics

| Skill | Purpose | External deps |
|---|---|---|
| `architecture-diagram` | Dark-themed inline-SVG cloud/infra architecture diagrams as one self-contained HTML file. | JetBrains Mono |
| `excalidraw` | Hand-drawn `.excalidraw` JSON files (arch, flow, sequence, concept maps). | `cryptography` pip (optional upload) |
| `baoyu-infographic` | `infographic.png` from any of 21 layouts × 21 styles. | `image_generate` tool |

### Video & Animation

| Skill | Purpose | External deps |
|---|---|---|
| `ascii-video` | Colored ASCII MP4/GIF (video-to-ASCII, audio-reactive, generative, hybrid, TTS). | Python, NumPy, SciPy, Pillow, ffmpeg |
| `manim-video` | 3Blue1Brown-style Manim CE explainer videos. | Manim CE, LaTeX (texlive-full / mactex), ffmpeg |
| `touchdesigner-mcp` | Drive a running TouchDesigner instance via the twozero MCP. | TouchDesigner (commercial), twozero.tox |

### Creative Coding

| Skill | Purpose | External deps |
|---|---|---|
| `p5js` | Single-file HTML p5.js sketches (gen art, shaders, interactive, 3D, audio-reactive). | p5.js, Puppeteer (optional export) |
| `pretext` | Text-flow / reflow / kinetic typography demos with `@chenglou/pretext`. | pretext (esm.sh CDN) |
| `ascii-art` | Terminal ASCII art (pyfiglet, cowsay, boxes, toilet, image-to-ASCII, QR, weather). | pyfiglet, cowsay, boxes, toilet |

### Writing & Music

| Skill | Purpose | External deps |
|---|---|---|
| `humanizer` | Rewrites text to strip 29 AI-writing patterns and add genuine voice. | none |
| `songwriting-and-ai-music` | Suno custom-mode packages (style description + metatagged lyrics). | Suno AI |

## Curation notes

These skills originated in the Hermes Agent project. They've been preserved as-is for fidelity. A few frontmatter fields are Hermes-specific and ignored by opencode:

- `metadata.hermes.tags` — Hermes taxonomy
- `metadata.triggers` — Hermes invocation hints
- `platforms` — Hermes platform gating (opencode is cross-platform)

The `name` and `description` frontmatter fields, which opencode requires, are present in every skill.

## Manual install

```bash
# Single skill, project-local
mkdir -p .opencode/skill/claude-design
cp -r skills/claude-design/. .opencode/skill/claude-design/

# Single skill, global
mkdir -p ~/.config/opencode/skill/claude-design
cp -r skills/claude-design/. ~/.config/opencode/skill/claude-design/

# Point opencode at this repo via opencode.json
# (then `skills.paths` can point to the cloned repo directly)
```

```json
{
  "$schema": "https://opencode.ai/config.json",
  "skills": {
    "paths": ["./skills"]
  }
}
```

## License

Each skill retains its original license (see `LICENSE` in each skill directory). Most are MIT.
