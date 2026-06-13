# Redesign As A Sibling Project

## When This Pattern Applies

The user says one of:
- "redesign X"
- "build a v2 of X"
- "rebuild X with a different look"
- "make a totally redesigned version of X"

…where X is an existing product with its own repo (or just a local folder). The user wants to **see the redesign next to the original** so they can A/B them. They do not want the original touched.

## Why A Sibling Project, Not In-Place Edits

| Approach | What happens |
|---|---|
| Edit the original repo in place | Original is lost, can’t A/B, risky merges |
| Single HTML file alongside | Loses animations, theme system, data, sound — feels like a Figma mock |
| Branch in same repo | The user has to checkout to compare; both versions pollute each other’s git |
| **Sibling project at `…/X-v2/`** | Both projects run independently, can be A/B-ed in two browser tabs, easy to delete one |

Sibling is the right shape for almost every "redesign of an existing product" brief.

## Flow

1. **Read the original first.** Before writing anything, inspect the source files: `package.json`, `app/globals.css` (or equivalent token system), the layout, the auth/theme providers, the data model, the matching/scoring engine, and the components. The file tree is the menu; the actual files are the food.
2. **Copy, don’t link.** `cp -r original ./X-v2` — copy the entire folder, including assets, data, and infra. Delete `.next`, `node_modules`, and `.git` from the copy. Keep the original untouched.
3. **List the job, not the layout.** Before touching code, write out who uses the product, what jobs they do all day, what wastes their time, and what the redesign should change about the *IA* (not just the colors). The new layout follows from the job, not from the old screen.
4. **Design the new token system on paper first.** Pick:
   - type (3 families max — e.g. sans for body, mono for numerics/labels, serif for editorial moments)
   - palette (one warm-neutral base, one human-warmth accent, 2–3 tier colors for score/health)
   - radii, shadows, spacing
   - motion posture (instant vs spring, what animates, what doesn’t)
5. **Rebuild the system tokens, not just the pages.** The CSS variables (or Tailwind theme) are the foundation. Replacing them is what makes the redesign feel different everywhere. The old token names (e.g. `--bg-primary`, `--accent-rose`) almost never carry over.
6. **Reuse the data and infra.** Don’t re-implement the matching engine, the AI integration, the auth, or the sound provider. Import them from the original. You’re redesigning the *surface*, not the *engine*.
7. **Throw away the old components when they reference the old tokens.** Don’t try to migrate `text-rose-400` and `bg-rose-950/30` to the new palette one by one — rewrite them. If an old component isn’t used by the new pages, either delete it or stub its imports so the build is clean.
8. **Wire the new topbar / nav to include a "V2 Preview" link if the user wants to compare** — gives them an obvious way to switch back to the original.
9. **Verify in two browsers side-by-side.** Run the dev server for both the original (`PORT=3000`) and the redesign (`PORT=3199` or similar). Log into both. The user can alt-tab to compare the same screen at the same data state.

## What Gets Carried Over (Don’t Rewrite)

- Data model and seed data
- Matching / scoring engine
- AI integration and prompt templates
- Auth provider
- Theme provider structure (just replace the token values)
- Sound provider
- Real assets (profile photos, illustrations, anything in `public/`)
- Utility helpers (currency formatting, age calculation, etc.)
- Authenticated routes and middleware

## What Gets Replaced

- The CSS token system (`globals.css`, `tailwind.config.ts`) — full rewrite
- The theme provider implementation — keep the API, swap the values
- The type system (fonts) — full rewrite
- The topbar / nav — usually a new component
- The dashboard hero and KPI strip
- The customer card / list row
- The customer detail layout (3-column vs 2-column vs modal)
- The match card / match list
- The send-match composer (modal vs side-by-side overlay)
- The login screen

## What You Build First vs Last

**First** (so you can run the app end-to-end as early as possible):
1. New token system in `globals.css` and `tailwind.config.ts`
2. New theme provider implementation
3. New root layout using the new tokens
4. New topbar / nav
5. New login page (the simplest end-to-end flow)

**Then** the high-leverage screens:
6. Dashboard (the entry point and triage hub)
7. Customer detail (the most-used screen)

**Last** the polish screens:
8. Send-match composer
9. Toast / modal / shared component refreshes

This ordering means every commit is runnable. You never have a broken state for more than a few minutes.

## Common Pitfalls

- **Using a sibling project when the user just wanted a tweak.** If the user says "make the buttons blue," that’s an in-place edit, not a v2. Use the sibling pattern only when the redesign is a real redesign — new IA, new system, new screens.
- **Copying a single HTML file "for speed."** Almost always wrong when the source is a real product. A standalone HTML file with no framer-motion, no real data, and no theme toggle will look like a Figma export and miss the entire point. If the user really wants a quick visual mock, do that — but confirm first.
- **Importing from the original repo via path alias.** Tempting (`import { foo } from '../../../original/lib/foo'`) but creates brittle coupling. Copy what you need.
- **Inheriting the original's Tailwind config colors.** They bake in a brand identity. The new design has its own palette; the new config should reflect that.
- **Forgetting to delete `.next` after the copy.** Carries over a build that references the old `public` paths and crashes on first dev-server start.
- **Editing the original by accident.** Use absolute paths to the v2 folder for every `patch`/`write_file` call. The skill prompt should always refer to `<project>-v2/`, never the original.

## Verification Loop (Run In Parallel)

```bash
# original
cd ~/path/to/original && PORT=3000 npm run dev

# v2 (in a separate terminal/process)
cd ~/path/to/X-v2 && PORT=3199 npm run dev
```

Then `browser_navigate` to `http://localhost:3000/dashboard` and `http://localhost:3199/dashboard` and use `browser_vision` to compare. Use `browser_console` on each to check for uncaught errors.

For each screen, ask: does the new one feel like a real product (responsive, themed, animated) or like a Figma mock (flat, no motion, broken fonts)? Iterate until it feels real.

## Reference Implementation

A real session followed this pattern: tdc-matchmaker-v2 (a redesigned TDC Matchmaker app) was built at `~/Desktop/testing/tdc-matchmaker-v2/` next to the original. The redesign replaced the original’s rose-gold / Fira Code / block-hero aesthetic with a warm-neutral / Instrument Serif + JetBrains Mono / triage-first layout (KPI strip as filter chips, 3-column compare canvas, side-by-side composer). Reused: matching engine, data, AI integration, sound provider, assets, auth. Threw away: every component that referenced the old color tokens.
