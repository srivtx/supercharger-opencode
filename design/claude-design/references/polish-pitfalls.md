# Polish Pitfalls — Frontend Implementation Fixes

Specific, repeatable fixes for visual-quality issues that come up after the first
round of design work. The pitfalls in SKILL.md cover the high-level decisions
(HTML vs real stack, sibling project vs in-place). This file covers the **layer
below that**: the polish-level issues that surface once the redesign is
rendering but still feels off.

## 1. Scrollable Panels Without Visible Scrollbars

User signal: "when I scroll the left most and right most while scrolling a scroll
bar appears that's the default one I don't want scrollbar".

The default browser scrollbar is ugly on side-rails and inset panels. The user
almost always wants it gone, not "thinner" or "styled". Hide it everywhere by
default.

**Global hide (in `globals.css`):**

```css
::-webkit-scrollbar { width: 0; height: 0; }
::-webkit-scrollbar-thumb { background: transparent; }
::-webkit-scrollbar-track { background: transparent; }
* { scrollbar-width: none; }
*::-webkit-scrollbar { width: 0; height: 0; }
```

That kills scrollbars on the body, the page, and any element that didn't
explicitly opt out. No `overflow: hidden` is needed; the content still scrolls, you
just don't see the bar.

If you ever need to bring it back on a specific element:

```css
.v2-side-scroll { scrollbar-width: none; }
.v2-side-scroll::-webkit-scrollbar { width: 0; height: 0; }
```

## 2. Modal/Overlay Panels of Equal Height

User signal: "design is pretty skewed" — when a modal has a dark reference panel
and a light editor panel, the right panel (usually the editor with the long
textarea) stretches to the natural height of its content, leaving a dark void
in the left panel.

The fix is to **size the parent to a fixed height** (or viewport-bound
max-height) and let both children stretch to fill it.

**Wrong — `maxHeight`:**

```tsx
<div style={{
  display: "grid",
  gridTemplateColumns: "360px 1fr",
  maxHeight: "calc(100vh - 80px)",  // children won't stretch past this
}}>
  <aside className="overflow-y-auto">…</aside>  // short content = short panel
  <div>…</div>                                   // long content = tall panel
</div>
```

**Right — `height` + `min-height: 0` on flex children:**

```tsx
<div style={{
  display: "grid",
  gridTemplateColumns: "360px 1fr",
  height: "min(640px, calc(100vh - 80px))",  // both children fill this
}}>
  <aside
    className="flex flex-col overflow-hidden"   // not overflow-y-auto
    style={{ minHeight: 0 }}                    // critical for flex stretching
  >
    …{/* use flex-1 to push the footer to the bottom */}
  </aside>
  <div className="flex flex-col min-h-0">
    …{/* flex-1 textarea fills remaining space */}
  </div>
</div>
```

The two key changes:
1. `height` instead of `maxHeight` — locks the parent to a single height.
2. `min-height: 0` on the flex children — without this, flex children default to
   `min-content` height and won't shrink below their content.

Verify with `getBoundingClientRect()` in the browser console:

```js
const modal = document.querySelector('.rounded-xl');
const kids = Array.from(modal.children).map(c => c.getBoundingClientRect().height);
// kids[0].height === kids[1].height
```

`browser_vision` screenshots can miss equal-height mismatch if the panels have
similar but not identical content. Use the DOM measurement to be sure.

## 3. Dead-Code Components from the Original Repo

When you copy a real codebase into a sibling project, the inherited components
will reference the old color tokens (`text-emerald-400`, `bg-rose-950/30`, etc.)
and old component APIs. If the new pages don't import them, the TypeScript
build still typechecks them and fails on the missing Tailwind classes.

**Three options, in order of preference:**

1. **Delete the dead files.** Confirm with the user first since `rm` is
   destructive.
2. **Stub their imports.** Replace the file body with a no-op re-export. Ugly
   but works.
3. **Migrate them to the new tokens.** If small or might be reused, rewrite the
   class names.

For a tight rebuild with a hard deadline, **make the shared component APIs
accept BOTH old and new prop types** so the dead files keep typechecking:

```tsx
type AvatarSize = number | "sm" | "md" | "lg";

interface Props { size?: AvatarSize; … }

const legacySizes = { sm: 40, md: 48, lg: 80 };

function resolveSize(s: AvatarSize | undefined): number {
  if (s === undefined) return 40;
  if (typeof s === "number") return s;
  return legacySizes[s];
}
```

The new pages use `size={40}`, the inherited dead files use `size="md"`, both
work, build is clean. Buys you time to decide later what to keep and what to
delete.

## 4. Real Assets from the Data Layer

User signal: "the pics are not visible like we do maybe you haven't copied the
photos as they are".

When profile data references image paths like `/avatars/image1.jpg`:

- **Verify the files exist** in the new project's `public/avatars/` before
  writing any UI. `ls public/avatars/` and confirm.
- **Use `next/image`**, not a `<div>` with letter placeholder. The placeholder is
  fine as a fallback but should not be the default.
- **`next.config.js` requires no changes** for local images in `public/`. The
  default config allows `/avatars/imageN.jpg` automatically.
- For a circular avatar: `border-radius: 9999px` (or `rounded-full`) and
  `object-cover` on the image.

```tsx
<div className="rounded-full overflow-hidden" style={{ width: 36, height: 36 }}>
  <Image src={customer.avatar} alt={customer.firstName}
         width={72} height={72}
         style={{ width: 36, height: 36, objectFit: "cover" }} />
</div>
```

If the avatar field is missing on a profile, show the first letter centered in a
soft gradient fallback — don't render a broken image icon.

## 5. Cramped Person/Profile Cards in Narrow Columns

When a two-column modal has a 360px left panel, splitting it between two person
cards leaves ~170px per card. The row-per-field label-value format (`Age: 23y`,
`City: Surat`, `Comm.: Hindu · Kurmi`) eats up too much width with the labels.

**Fix:** Use a compact key-value grid with tiny labels above the values, not to
the left:

```tsx
<div className="text-[10px] space-y-1.5">
  <div className="flex items-baseline justify-between gap-2">
    <span className="text-white/35 font-mono text-[9px] uppercase tracking-wider">Age</span>
    <span className="text-white font-medium">{age}y</span>
  </div>
  {/* … */}
</div>
```

The label is now a tiny mono caption (8–9px) above the value, not a competing
10px label sitting next to a 10px value.

For long values that still wrap (like "Hindu · Kurmi"), put them on their own
line as a subtitle directly under the name, not as a row. This gives the card a
clear hierarchy: name (large) → community (subtitle) → 4 compact rows.

## 6. The "While Scrolling" Visual Skew

When the user says "while scrolling it looks off", they usually mean one of:

- An element overflows the rail at a specific scroll position
- A sticky header/footer doesn't stay in place
- The animation of new items entering the viewport is jittery
- The page scrolls when only the panel should scroll

Verify with `getBoundingClientRect()` after scrolling programmatically:

```js
const rail = document.querySelector('.v2-side-scroll');
rail.scrollTop = 200;
const r = rail.getBoundingClientRect();
return { scrollTop: rail.scrollTop, scrollHeight: rail.scrollHeight,
         clientHeight: r.clientHeight, hasScroll: rail.scrollHeight > r.height };
```

If `scrollHeight > clientHeight` but no scrollbar shows, the global hide-scrollbar
rule is doing its job. The content still scrolls. That's the desired behavior.

If the user is seeing the body page scroll, that means a panel that's supposed
to be the scroll container has `overflow: visible` or no explicit height. Fix
by adding `overflow-y: auto` and an explicit `maxHeight` or `height` to the
container.

## 7. Empty-State Placeholders for Optional Content Sections

If a side panel has a content block (intake notes, recent activity, etc.) that's
empty for some records, do **not** render an empty `<div />` with `flex-1` and
hope the next section fills the space. Render a meaningful placeholder:

```tsx
<div className="flex-1 min-h-0 flex flex-col">
  <h5 className="v2-detail-eyebrow">
    {customer.notes?.[0] ? "Latest intake note" : "Context"}
  </h5>
  <div className="v2-side-scroll p-3 rounded flex-1 min-h-0"
       style={{ background: "rgba(0,0,0,0.04)", borderLeft: "2px solid var(--accent)" }}>
    {customer.notes?.[0]
      ? `"${customer.notes[0].text}"`
      : <div className="not-italic">
          <span className="v2-eyebrow">matchmaker note</span>
          No notes yet. Add a note from the workspace to see context here.
        </div>}
  </div>
</div>
```

The placeholder is:
- Visually styled to match the filled state (same border, same bg tint)
- A useful prompt to the user about what to do
- Helpful even when empty (suggests the next action)

Don't leave a visible empty void — it makes the design feel unfinished.

## Quick Verification Script

After any visual polish round, run this in the browser console before declaring
done:

```js
// Scrollbar check
const rails = document.querySelectorAll('.v2-side-scroll');
rails.forEach(r => { r.scrollTop = 200; });
const visibleScrollbar = Array.from(rails).some(r => r.offsetWidth - r.clientWidth > 0);
console.log('Visible scrollbar?', visibleScrollbar); // should be false

// Equal-height panel check
const modal = document.querySelector('.rounded-xl');
if (modal) {
  const kids = Array.from(modal.children).map(c => c.getBoundingClientRect().height);
  console.log('Children heights:', kids, 'equal?', new Set(kids).size === 1);
}

// Overflow check
const aside = document.querySelector('aside');
if (aside) {
  const r = aside.getBoundingClientRect();
  console.log('Aside overflow?', aside.scrollHeight > r.height);
}
```

Print this once, look at it, and you'll catch 80% of polish issues before
asking the user to look.

## 8. 3D Bar Charts in CSS (For When "Boring 2D" Won't Cut It)

User signal: "any 3d thing that we can do with it think more" — when the data
has 8+ comparable items and a flat 2D grid feels generic, a real CSS-3D
isometric bar chart is the highest-leverage premium touch.

**The technique (works without any 3D library):**

```tsx
<div style={{ perspective: "1400px", perspectiveOrigin: "50% 20%" }}>
  <div style={{
    transformStyle: "preserve-3d",
    transform: "rotateX(50deg)",     // tilt the floor toward camera
    width: 600, height: 230,
  }}>
    {/* Floor (sits below the bars via translateZ) */}
    <div className="absolute inset-0" style={{
      transform: "translateZ(-30px)",
      background: "linear-gradient(180deg, transparent, var(--bg-inset))",
      border: "1px solid var(--border-strong)",
    }} />

    {/* Floor grid lines (X scale 0/20/40/60/80/100) */}
    {[0, 20, 40, 60, 80, 100].map(v => (
      <div className="absolute" style={{
        left: (v / 100) * 600, top: 0, bottom: 0, width: 1,
        transform: "translateZ(-29px)",
        background: v === 0 || v === 100 ? "var(--border-strong)" : "var(--border)",
      }} />
    ))}

    {/* Each bar is a 3-face extruded box */}
    {dims.map((d, i) => {
      const barW = 36, gap = 14;
      const baseX = ((600 - 10 * barW - 9 * gap) / 2) + i * (barW + gap);
      const barH = (d.score / 100) * 200;
      return (
        <div className="absolute" style={{
          left: baseX, bottom: 30, width: barW, height: barH,
          transformStyle: "preserve-3d",
        }}>
          {/* Right face (depth) */}
          <div className="absolute" style={{
            right: -8, top: 0, bottom: 0, width: 8,
            background: color, filter: "brightness(0.6)",
            transform: "rotateY(90deg) translateZ(-4px)",
            transformOrigin: "right",
          }} />
          {/* Top face (cap) */}
          <div className="absolute" style={{
            left: 0, right: 0, top: 0, height: 8,
            background: "rgba(255,255,255,0.4)",
            transform: "rotateX(-90deg) translateZ(4px)",
            transformOrigin: "top",
          }} />
          {/* Front face */}
          <div className="absolute inset-0" style={{
            background: color,
            transform: "translateZ(0)",
          }} />
        </div>
      );
    })}
  </div>
</div>
```

**Critical sizing math:** With N bars of width W and gap G, the total bar row
width is `N*W + (N-1)*G`. Center it in the chart viewport with
`baseX = (chartWidth - totalW) / 2 + i * (W + G)`. If a bar's rightmost edge
plus the 8px right-face depth exceeds the viewport, the bar gets clipped.
Always verify with `getBoundingClientRect()` that no bar is cut off.

**Score labels need a halo for legibility** — the bars are colored and the
labels are above them in 3D space. Use a 4x layered text-shadow in the
panel's background color so the number reads on top of any bar:

```tsx
<div style={{
  color: barColor,
  fontWeight: 700,
  textShadow: "0 0 4px var(--bg-elevated), 0 0 4px var(--bg-elevated), 0 0 4px var(--bg-elevated), 0 0 4px var(--bg-elevated)",
}}>{d.score}</div>
```

**The "watch-for overrides tier" info-design pattern:** When some bars are
flagged as "watch for the matchmaker" (e.g. bottom 2 scores), color them
*unconditionally* in the alert color, regardless of their tier:

```ts
function tierColor(score: number, isWatch: boolean) {
  if (isWatch) return "var(--ember)";  // always alert color
  if (score >= 85) return "var(--moss)";
  if (score >= 70) return "var(--honey)";
  return "var(--slate)";
}
```

The visual rhythm of "N perfect greens + 1 ember outlier" is more useful than
"all uniform tier coloring" — it tells the matchmaker at a glance *which*
bar is the watch-for without needing to read the numbers.

**Y-axis labels in a 2D overlay, not in 3D:** Trying to rotate the dim names
in 3D space usually makes them unreadable. Put the labels in a normal flex
column on the left side of the chart viewport, then use `pl-[120px]` on the 3D
scene to start the bars *after* the label column. The 2D labels look better
than tilted 3D ones and the 3D bar extrusions still work.

## 9. The User's "No, Prev Was Better" Recursion

User pattern: "no i don't like it prev was better" (often repeated). The user
rejects speculative visual flourishes and wants the conservative version. When
you hear this once, **stop adding visual changes** in the rest of the session.
Don't propose three more "improvements" right after a rollback — the user
clearly wants restraint, not more options.

Concrete signal-to-action mapping when the user pushes back on a design change:

- "i don't like it" / "prev was better" → revert immediately, don't argue, don't
  propose alternatives. Confirm what the previous version was, restore it,
  ask what specifically they want changed (if anything) instead.
- "design is pretty skewed" → a specific layout/visual issue exists, ask which
  element is skewed rather than guessing.
- "scrollbar appears" / "i don't want scrollbar" → use the global hide rule from
  item #1 of this file, do not try to "style" the scrollbar.
- "pics are not visible" → use `next/image` from `public/avatars/`, do not use
  letter placeholders.
- "matchmaker note thing like we had in the old one" → user expects feature
  parity with the original. Check the original for the feature and rebuild it,
  don't ship a stripped-down version.
- "overall thing we can improve around design" → open-ended prompt for honest
  critique. List the weakest 3-5 things with specific names of elements, don't
  do a "polish" tour that's just a "things look good" review.
- "use icons that match the font" or "use icons that match the type" → default
  lucide icons have 1.5px stroke + rounded line caps. They break the moment
  the type becomes editorial. Build a custom inline-SVG icon library tuned to
  the type's voice — see item #10 below.

The pattern to avoid: after a rollback, asking "should I do X or Y?" as if the
rollback never happened. The rollback was the answer — pick the path that
*minimizes further changes*, even if you personally think more changes would
help.

## 10. Icons That Don't Belong to the Same World as the Type

User signal: "use icons and other things that match the font" or "use icons
that match the type." The icons are speaking a different language than the
typography.

Default icon libraries (lucide-react, heroicons, feather) draw with
**1.5px stroke + rounded line caps + geometric shapes**. That's fine for a
generic SaaS product where the type is also geometric (Inter, system-ui).
It breaks the moment the type becomes editorial — Instrument Serif, Playfair,
Cormorant — or hand-drawn — Spectral, Lora. The icons become foreign bodies.

**Fix:** Build a custom inline-SVG icon library tuned to the type's voice.
Concretely:

- **Stroke width = the type's stroke width at the size you render.** For
  Instrument Serif at body size, that's ~1.25px. For Inter at body size,
  1.5px is fine. Match the rendered stroke of the letterforms.
- **`stroke-linecap="square"` and `stroke-linejoin="miter"`** — not round.
  Rounded caps feel friendly; square caps feel editorial.
- **No fills.** Pure line work. The icon should look like a marginal mark in
  ink, not a Material icon.
- **Sized to sit on the body's x-height.** 11–12px for body, 14–16px for
  feature. Bigger icons read as separate elements; smaller read as
  typography ornaments.
- **Reduced opacity (60–80%) when used as a kicker/eyebrow.** Icons that
  accompany a label should feel supporting, not primary.

**Template at `templates/glyph-library.tsx`** — a working library of editorial
glyphs (arrow, chevron, check, cross, clock, hourglass, search, pen, send,
message, phone, spark, warn, dot, loader, plus, trash, mail, document, minus,
arrow left, heart) tuned to 1.25px stroke + square caps. Copy and rename the
glyphs to fit the product, or just import them as-is for any editorial /
premium surface.

**Replace the lib icons, don't add the lib icons to the type.** When the user
says "icons that match the type," they mean the icon family should *belong to
the same hand* as the typography. That almost always means custom inline SVG
tuned to the type, not a tweak to the lucide props.

**When the type is generic sans (Inter / system-ui), the default lucide
icons are fine.** This rule fires when the type is editorial, hand-drawn,
or otherwise distinctive. If you're using `font-serif` in the eyebrow, the
icon next to it should be custom too.

**The swap-in pattern, end-to-end:**

1. Build the custom glyph library as a single file
   (`components/Glyph.tsx`) exporting each icon as a typed React component
   with a `size` and `strokeWidth` prop. Keep them on a 12x12 viewBox so
   the math is consistent. Start with the icons you actually use: arrow,
   chevron, check, cross, clock, hourglass, search, pen, send, message,
   phone, spark, warn, dot, loader. That's enough for ~90% of product UI.
2. In the editorial surfaces (the pages that use the editorial type),
   replace lucide imports with the custom library. Use
   `import { ArrowUpRight } from "@/components/Glyph"`.
3. **Keep lucide in the chrome** — topbar nav buttons, login form, toast
   icons. These are utility surfaces where the editorial voice doesn't
   apply, and lucide is fine. Mixed icon *systems* is OK; mixed icon
   *styles* (1.5px stroke next to 1.25px stroke) is not.
4. Pass `strokeWidth={1}` or `strokeWidth={1.25}` explicitly when you
   need a thinner glyph than the default. Reserve 1.5 for checks and
   other "thicker" icons where 1px feels insubstantial.
5. Reduce opacity (60–80%) on icons that accompany a label so they read
   as supporting, not primary. This is the difference between an icon
   that "sits next to" the label vs "shouts over" it.
6. **Don't mix emoji and glyphs.** If the type is editorial, the icons
   are editorial. Emoji = a different visual language.

A working template is at `templates/glyph-library.tsx` — copy it as the
starting point.

## 11. The "Make It So Good" Quality Bar

User signal: "make it so good that no one can do something like it" or
"design it like nobody else could." This is **not the same as "polish more."**
It's a quality bar, not a polish loop.

When the user raises the quality bar, the work expands to:

- **Real research before designing.** Look at adjacent premium products in
  the same category (Mercury, Linear, Stripe for fintech; Aperture, NYT
  Magazine for editorial). Don't just iterate on the design — *show up
  with references* the user didn't ask for, because the references are
  what make the design step-change instead of incremental.
- **Bold direction changes, not patches.** A user asking for a step-change
  is *not* asking for a 3D bar chart on top of a 2-col dim grid. They're
  asking "what would a real product in this space look like, and how do we
  get there?" If the answer is "the dashboard becomes a morning brief with
  a date masthead and editorial lead stories," that's a different page, not
  a patch.
- **Concrete copy, not placeholders.** A user at this level is going to
  notice the difference between "Values — strong on both sides" and
  "Both vegetarian, both family-first." Every copy block should be
  value-grounded text derived from the actual data, not a template
  sentence that could apply to anyone.
- **Visible priority metadata.** A user at this level wants the *system*
  to surface the next action, not just show data. Big "PRIO 01" numbers,
  "STALLED" / "FAMILY WAITING" stakes badges, "if you skip" warning
  strips — these are the difference between a passive data view and a
  decision-support system.
- **Stop polling and start declaring.** At this quality bar, the user does
  not want a 3-option comparison every turn. Pick the strongest direction,
  execute it end-to-end, and let the user react. Asking for approval on
  every micro-decision wastes the session.

If the user has been saying "now what more" / "what else" / "look more" for
2–3 turns in a row, the signal is: stop patching components, **re-read the
brief from turn 1**, and rebuild the thing as a step-change. The user is
telling you the design is good but not yet *great*. Incremental won't get
there.

## 12. The "If You Skip" / "At Stake" / "By Friday" Consolidation Anti-Pattern

User signal: "the three things card is getting cluttery" / "i asked to remove
the if you skip thing" / "by friday... inshita gets poached... remove them."

The pattern:

1. Original design had a noisy **per-element** warning: "If you skip, Ishita
   will likely be poached by a rival matchmaker" repeated as a sunken warning
   strip on every featured card. Visual noise.
2. User says "remove it."
3. Agent overcorrects. To honor the *spirit* of the request, the agent
   consolidates the warning into a **section-level caption**: "BY FRIDAY —
   Ishita gets poached · Tanvi gets poached · Arjun — engine stays paused."
4. User says "remove them." The consolidation was *also* noise.

**The lesson:** when consolidating per-element noise into a section-level
summary, the summary must add **context the user couldn't derive from the
cards themselves**. If the summary just restates each card in a different
format, it's the same noise in a different shape.

What works:
- A section-level *aggregate* with a specific number ("3 leads will close by
  Friday, average 8 days in stage") — adds info not on any single card.
- A section-level *risk index* ("at current pace, 2 of your matches will
  close before intro") — adds a derived insight.
- A section-level *cause* ("all 3 are from yesterday's batch — the engine
  caught up") — adds a story.

What doesn't work:
- "Ishita — Ishita gets poached" (just the card's stakes with the name
  prefixed).
- "By Friday, 3 leads will go cold" (vague count, no specifics).
- A per-element "if you skip" repeated at section level (still per-element).

**Default move when per-element content is noisy:** delete it. Don't try to
rescue the insight by moving it somewhere else. Trust the position of the
card in the list (leftmost = most important) and the top accent bar color
(ember = hot) to carry the urgency signal. If the user *wants* a section
caption later, they will ask for one.

## 13. Where 3D Belongs (And Where It Doesn't)

User signal: "any 3d thing that we can do with it think more" — but also,
twice in the same session, "no i don't like it prev was better" / "the design
doesn't look good but still out of window something is missing."

The pattern:

1. User asks "any 3D thing?" (open-ended).
2. Agent builds a 3D bar chart in a comparison view, replacing a 2-col dim
   grid.
3. User accepts it briefly, then says "doesn't look good... out of window."
4. Agent pivots to an A/B compare layout (no 3D), user is satisfied.

**The lesson:** 3D is **load-bearing for a few seconds and dead weight
afterward**. It works as:

- A single hero element (a big score ring, a logo, a featured product photo).
- A micro-interaction on hover (an avatar that tilts based on mouse position).
- A 1-second intro animation (a page that "lifts into focus" on mount).
- A background atmosphere (a slowly-rotating gradient mesh, an out-of-focus
  3D shape behind content).

3D **doesn't work as**:

- A complex chart with 8+ elements (the data is harder to read, the
  perspective fights comprehension).
- A persistent feature in a comparison view (where the user is *actively
  reading* data — perspective distortion is a tax).
- A repeated element across many cards (the visual cost compounds; one 3D
  card is interesting, five is exhausting).

**Heuristic for "should this be 3D":**

- Will the user look at this for less than 3 seconds? Yes → 3D adds value
  (visual interest, depth).
- Will the user look at this for more than 10 seconds and parse the data?
  Yes → 3D is a tax. Stay 2D.
- Is there a single moment of delight (a card lift, a hero animation, a
  hover)? Yes → 3D works. If the 3D is "always on," it's a chore.

The user's "doesn't look good" complaint about a complex 3D chart wasn't
about the chart being bad 3D — it was about 3D being the wrong solution for
a content-dense comparison view. The right answer was a 2D A/B compare
view, not a better 3D chart.

## 14. The Photo-Plus-Name Anchor: Don't Strip It For Minimalism

User signal: "the profile pic and some text were really good before" /
"you added too much less" / "i wanted it like that" / "the profile pic and
some text were really good before i asked for that odd if you skip thing".

When pruning a card for "less clutter," the temptation is to remove the
photo + name + meta row and replace it with just a number or a name. The
photo is a **visual anchor** that grounds the card in reality — it tells
the matchmaker "this is a real person, not a number." Removing it makes
the card feel like a generic row, not a portrait of someone.

**Rule:** the photo + name + age/city/designation + stage blurb + days
is the **minimum viable person block**. Stripping any of those for
"cleanliness" makes the card feel abstract and reduces the matchmaker's
emotional connection to the action.

```tsx
// CORRECT — keeps the photo, the name, the meta, the stage, the time
<div className="px-5 pt-2 pb-2 flex items-center gap-4">
  <ProfileAvatar ... size={56} />
  <div>
    <div className="font-serif">{firstName} {lastName}</div>
    <div className="text-[11px]">{age}y · {city} · {designation}</div>
    <div className="flex items-center gap-2">
      <span className="w-1.5 h-1.5 rounded-full" style={{ background: stageDot }} />
      <span className="text-[10px]">{stageBlurb}</span>
      <span>·</span>
      <span className="text-[10px]">{daysInStage}d in stage</span>
    </div>
  </div>
</div>

// WRONG — stripped the photo and meta to "look cleaner"
// Just shows a name and a number. Feels like a notification, not a person.
<div>
  <div className="font-serif">{firstName} {lastName}</div>
  <div className="text-[12px]">{stakesLabel}</div>
</div>
```

**The right way to "look cleaner" is to **keep the person block and remove
noise around it** (per-element warning strips, redundant badges,
duplicate stats). Don't remove the person to look cleaner.

## 18. Dark Mode Is a Separate Design System, Not a CSS Filter

User signal: implicit. The user never asked about dark mode, but the audit
("is there anything else remaining") surfaces dark mode as the weakest
remaining surface. Light mode got the editorial treatment (warm beige,
ink-muted readable, borders visible, custom accent tokens). Dark mode
got pure-black backgrounds and contrast values tuned for a different
design system entirely.

The pattern:

1. Designer spends hours on light-mode design tokens. Warm beige
   background, ink-muted at #7a7669 (legible on beige), borders at
   0.08 alpha (visible on beige), moss/honey/slate accents all named.
2. Dark mode "ships" as `data-theme="dark"` rules that just flip the
   bg to a near-black. The ink colors that worked on beige are kept
   (now too dark on near-black), the border alpha kept (now invisible),
   the moss/honey/slate not redefined (so they fall back to undefined /
   are wrong), the page background not redefined (so the paper texture
   rule produces near-zero contrast). Body text becomes hard to read,
   card borders disappear, status indicators lose their meaning.
3. User eventually switches to dark mode and either complains or
   silently tolerates the regression.

**Fix:** treat dark mode as a separate design system with **its own
audited tokens**. Do not flip light values. Specifically:

- **Background:** warm off-black, not pure black. Pure black (#000) on a
  warm-neutral light design looks like a generic dark theme slapped on.
  Use a dark tone from the same family as the light bg — e.g. light
  `#f5f0e6` (warm beige) → dark `#14110a` (warm off-black). Not `#0d0c08`,
  not `#000`. The background should still feel like the same product.
- **Ink-muted and ink-faint:** lighten, not keep. On dark, what was
  `#7a7669` (readable secondary) needs to become `#948e7d` or similar.
  What was `#45413a` (subtle divider) needs to become `#615c51`. Otherwise
  secondary text becomes illegible and dividers disappear.
- **Borders:** raise the alpha. 0.08 alpha borders on a warm-beige
  background are visible; 0.08 alpha on near-black are invisible. Use
  0.10+ for borders at rest, 0.18+ for borders on hover/strong.
- **Status accents:** redefine every status color in the dark block.
  Moss at `#7fb069` is readable on dark; moss at the light-mode value
  is too bright. Honey `#d4a04a`. Ember `#e8744d` (slightly brighter
  than light mode for legibility on dark). If the light-mode
  `var(--honey)` etc. are referenced in dark mode without dark
  overrides, the colors are technically defined but wrong.
- **Texture overlays:** the body `::before` radial-gradient paper
  texture in light mode uses dark dots on light bg. In dark mode, it
  needs light dots on dark bg with `mix-blend-mode: screen` instead of
  `multiply`. Without the override, the texture disappears or inverts.

**Verification after defining dark tokens:** open the dark mode and
check:
- Body text on background passes contrast (≥4.5:1 for body, ≥3:1 for
  large/UI)
- Card borders visible at rest (not just on hover)
- Status indicators (moss/honey/ember dots, alert icons) read clearly
- The page still feels like the same product, not a different one

If any of those fail, the dark tokens need more care — not a thinner
border or a brighter text, but a re-derivation of the whole system for
the dark substrate. The same rules that produced the light palette
(token names, contrast levels, accent usage) apply to dark — you just
need different *values* to satisfy them.

## 15. Priority Is Invisible If You Don't Surface It

User signal: "where to set priority you didn't set that" / "where to see
the rest of the things" / "now i wanted the priority setting logic and
where to see the rest".

When you add a priority/scoring system behind the scenes, the user can't
see it unless it shows up on the surface. The "best 3 things" cards
looked good, but the user couldn't see **why** they were the best 3 or
**what** the priority order was or **how** to manipulate it.

**Rule:** priority must be:

1. **Computed** with a visible algorithm the user can understand (stage
   urgency + days in stage + note damp + tier color).
2. **Shown** in the card (PRIO 01/02/03 number, or position in row, or
   stakes badge color).
3. **Sortable** as a filter / sort control ("sort by urgency" vs "sort
   by stage" vs "sort by name") AND viewable as different views (active
   / stalled / all).
4. **Grokable** in 2 seconds — the user should be able to point at any
   card and say "this is the 2nd most urgent because it's been in
   Actively Matching for 11 days."

Don't ship a priority system as an internal `priorityScore()` function
and call it done. Surface it in the UI. If the user can't see *how* the
priority was computed, the system is a black box. The "rest" of the
pipeline (the unpicked items, the filtered views) needs its own visible
section with its own filter/sort controls, not a single sorted list
lumped under the featured section.

## 16. The Consolidation Is Just Renaming Trap

User signal: "by friday inshita gets poached and all are adding noise
remove them" (after the agent had earlier moved a per-element warning
to a section-level caption that just listed each card's name + a
near-duplicate of its own stakes text).

If you consolidate per-element noise into a section-level summary, the
summary must add **context the user couldn't derive from the cards
themselves**. If the summary reads "Ishita — Ishita gets poached,
Tanvi — Tanvi gets poached, Arjun — engine stays paused" with each
clause just restating the card next to it, the consolidation was the
*same* noise in a *different shape*. Delete it.

**Heuristic for "is this consolidation adding value or just renaming?":**

- Does the summary give a derived insight (an aggregate, a risk index,
  a count) that the cards don't? → Keep it.
- Does the summary repeat the cards' own content with the names
  prefixed? → Delete it.
- Does the user have to look at the cards AND the summary to understand
  anything? → Delete the summary.

The default move when per-element content is noisy: **delete it**. The
position of the card in the list and the top accent bar color already
carry the urgency signal. Trust them.

## 17. The Same-Surface Glyph Library Is a Force Multiplier

When you build a custom inline-SVG glyph library (item #10) and it
covers the editorial surfaces, **use it everywhere on those surfaces**.
Don't half-convert: leaving some lucide icons in the detail page
because "they're small" or "they don't matter" creates a mixed-style
brand voice the user will feel even if they can't name it. The
detail page, the composer, the notes panel, the match rail — every
editorial surface uses the glyph library. Only the app chrome
(topbar nav, login, toast) keeps lucide. Mixed icon *systems* is OK;
mixed icon *styles* is not.

The minimum useful glyph set, after several sessions of real product
use: ArrowRight, ArrowUpRight, ArrowUp, ArrowDown, ArrowLeft, Chevron,
Check, Cross, Clock, Hourglass, Search, Pen, Send, Message, Phone,
Spark, Warn, Dot, Loader, Plus, Trash, Minus, Mail, Document, Heart.
That's 25 glyphs covering 95%+ of editorial product UI. The full
working library is at `templates/glyph-library.tsx`.

## 19. Replicate The v1's Behavior, Not Your Reinterpretation Of It

User signal: "follow the similar pattern of generation that we have inside
tdc-matchmaker" / "we didn't it replace it completely" — when refactoring a
feature into v2, the user wants v2 to behave like v1, not like the agent's
*imagination* of how v1 might work.

The pattern:

1. User asks for a v2 feature to follow a v1 pattern. The agent reads the
   v2 feature description and starts building what it *thinks* the v1
   does.
2. Agent ships a feature that's a creative reinterpretation — not the
   v1's actual behavior. Usually the agent's version is *more complex*
   (one big call to the LLM where the v1 did two smaller calls; a long
   template where the v1 was a short skeleton; replacing the field
   completely with generated text where the v1 only injected a short
   snippet).
3. User says "we didn't it replace it completely" or "follow the pattern
   inside [v1]". The v1 file is on disk — go read it.

**Fix:** **before writing the v2 implementation of a feature the user
named after a v1, find the v1 source file and read the actual call
chain.** Don't read the v2 description, don't read the v1 spec, don't
read a summary of the v1 — read the v1's *code* and mirror its structure
in v2.

Concrete v1/v2 example from this session — the "Draft with AI" button in
the match composer:

| What the agent built (v2) | What v1 actually did |
|---|---|
| One big call to Groq with a long prompt asking for "warm, brief 2 short paragraphs max" (and the model produced 3+ paragraphs) | Two smaller calls: first a one-sentence seed (max 25 words), then a 2-sentence body using the seed as context |
| `max_tokens: 240` (single call) | `max_tokens: 100` per call |
| Replaces the email body completely with the AI output | Pre-fills a short skeleton (4 lines), then optionally overwrites with the AI body |
| Doesn't reuse the per-match `explanation` (set by `enhanceMatchWithAI` in the detail page) | Uses the existing explanation as the seed if it's already there; only generates a fresh seed if missing |
| Stays generic on failure (silent error) | Bails out with `sounds.error()` and the skeleton stays in place |

The v1's behavior was *right*. The agent's reinterpretation was *wrong*.
The fix: read the v1 source first, copy the call structure (or its
equivalent in the v2 stack), and only deviate if the v2's structure
genuinely doesn't support it.

**Heuristic for "am I about to reinterpret a v1 feature?":**

- Did the user say "follow the pattern" or "do what [v1] does" or "replicate
  the [v1] behavior"? → Yes, read the v1 source file before writing
  anything.
- Does the v1 file have a function I can read in 30 seconds? → Read it.
- Is my v2 version significantly *more complex* than the v1 (more LLM
  calls, more tokens, more side effects, more text generated)? → I am
  probably reinventing. Strip back to the v1's structure.
- Does the v1 use a *field that's already in the model* (like
  `match.explanation` in the example) and my v2 doesn't? → I am
  reinventing. Read the v1 to find the field.

**The mirror-with-edits pattern, end-to-end:**

1. User says "follow the v1 pattern of [feature]". Locate the v1 file.
   Usually `~/path/to/v1/[feature-file].tsx` or
   `~/path/to/v1/lib/[logic].ts`. Read it.
2. Identify the v1's structure: number of LLM calls, what the prompt
   asks for, what fields the v1 reads from the data, what fallback
   exists on error, what the user sees when the feature succeeds vs
   fails.
3. Translate the v1's code to the v2's stack (Next.js, your
   component library, your type names) **without changing the
   structure**. Same number of calls, same `max_tokens`, same
   skeleton-vs-AI-output tradeoff, same bail-out.
4. Ship it. Confirm the v2 now behaves like the v1 (visually or by
   running through the same code path).
5. *Then* — and only if the user wants it — make v2-specific
   improvements (cleaner copy, better animations, an extra metric in
   the prompt). Don't make improvements on the way to mirroring.

The default move when the user names a v1 feature: **read the v1 file
first**. The agent's reinterpretation is almost always wrong in a way
the user can articulate but the agent can't predict.

## 20. When The User Says "Use The Same Local Env Values", Search The Parent Tree

User signal: "don't use ai but use the same local env values for the tdc
match maker. right there must be somewhere in our pc another
tdc-matchmaker we already have the cloneed one in this directory but a
different one find that."

When the user is working on a v2 / fork / sibling project and asks for
"the same env values" or "the keys from the original," the real `.env`
or `.env.local` with actual secret values is almost never inside the
current project — it's in a sibling project in the same parent
directory tree.

The pattern:

1. User is working on `~/Desktop/testing/tdc-matchmaker-v2/`. The repo
   has a `.env.example` (template) but no `.env.local` (real keys).
2. User says "use the same env values from the original" and "find
   that on the pc."
3. Agent checks the current project for `.env.local` — not there.
   Agent gives up and asks the user, wasting a turn.

**Fix:** **when working on a sibling/fork/clone project, search the
parent directory tree for sibling directories with similar names
*before* asking the user.** The user almost always has the original
project (with real env values) sitting in the same parent folder
(`~/Desktop/testing/`, `~/Desktop/assignments/`, `~/Projects/`,
`~/work/`).

Concrete search pattern, run from inside the project that needs the
env:

```bash
# Find sibling repos of similar name
find ~ -maxdepth 4 -type d -name "tdc-matchmaker*" 2>/dev/null
# Find any .env or .env.local that mentions a known key name
find ~ -maxdepth 4 -name ".env*" 2>/dev/null | xargs grep -l "GROQ\|OPENROUTER\|API_KEY" 2>/dev/null
# Confirm the values look populated (not just templates)
for f in $(find ~ -maxdepth 4 -name ".env.local" 2>/dev/null); do
  if grep -q "=[a-zA-Z0-9]\{8,\}" "$f"; then echo "REAL VALUES: $f"; fi
done
```

When you find the sibling's `.env.local`, copy it to your project's
`.env.local` (a single `cp` command). Don't manually re-type the keys —
the user typed them once and the values are the right ones.

**Heuristic for "where is the real env":**

- Working in a v2/fork/sibling project? → Look in the original in the
  same parent directory.
- Working in a fresh clone where `git pull` didn't pull env? → Look for
  the original developer's home directory, or the `~/Desktop/`
  copy. The user often has two working copies.
- Working in a CI environment with secrets in a vault? → Different
  problem, but the principle is the same: find the *real* source, not
  the template.
- The project has a `.env.example`? → That confirms the project
  *expects* env vars, but the real `.env.local` lives elsewhere.

**Always confirm the file has real values before copying.** A
`.env.example` has comments and `***` placeholders. A real
`.env.local` has long alphanumeric strings after `=`. Grep for
`"=[a-zA-Z0-9]\{8,\}"` to confirm.

The default move when working on a sibling project and env is needed:
**search the parent tree first, then ask the user only if the search
fails**. Don't ask the user for keys they expect the agent to find.

## 21. Match Explanations Are Verdicts, Not Paragraphs

User signal: "this one we cannot see this much text and it makes the whole
card cramped" — pointing at the A/B score card's prose explanation.

The default "explain a match" template is a paragraph:

> "Excellent match — strong values alignment, compatible educational
> backgrounds, compatible lifestyle preferences. Anil (30, Delhi) shares
> key compatibility factors with Nandini."

That's 178 characters, two sentences, wraps to 4-5 lines on a 350px A/B
card body. Even with tight line-height, it's a wall of text in a card
that's supposed to be scannable.

**Real magazine compare blocks use a single editorial sentence** for the
verdict. Like a New Yorker blurb:

> "Anil and Nandini share vegetarian values, both family-first."

One sentence, ~12 words. Says what matters. The breakdown is *below* if
the user wants the details.

**The fix as a designer:**

1. **Tighten the explanation template to one short sentence** (~12-18
   words). Lead with the most specific detail (shared city, shared
   dimension). Drop the redundant tier word ("Excellent match — ..."
   is already implied by the big "98" number above the verdict).
2. **Render the verdict in italic serif** (the display typeface) at 13px,
   line-height 1.45. Truncate with `truncate` so it never wraps to 2
   lines; the full text is in the `title=` attribute.
3. **Prioritize concrete over generic in the template.** "shared
   values" beats "strong values alignment." "both in Delhi" beats
   "compatible location." Strip the marketing language.
4. **Use the most concrete highlight first.** Shared city is more
   name-worthy than shared values because it has a specific noun the
   user can picture.

**Code pattern (Tailwind + inline styles):**

```tsx
<p
  className="flex-1 min-w-0 m-0 truncate"
  style={{
    fontSize: 13,
    lineHeight: 1.45,
    color: aiEnhanced ? "var(--ink)" : "var(--ink-soft)",
    fontStyle: "italic",
    fontFamily: "'Instrument Serif', Georgia, 'Times New Roman', serif",
  }}
  title={explanation}
>
  {explanation}
</p>
```

The explanation is now a *verdict line*, not a paragraph. The user gets
the gist in one glance. If they want the full breakdown, it's right
below in the key-factors panel.

## 22. Personal Names Always Use The Display Serif

User signal: "the names are using some normal font should they use our
font or not the originl one that is used throughout."

The body text uses Inter. The editorial type (headlines, big numbers,
display) uses Instrument Serif. **Personal names belong to the display
serif, not the body sans.** This is a hard rule in editorial design:

- *The New Yorker*: every name in italic serif, no exceptions
- *Vogue*: cover names in Didot display
- *Aperture*: contributor names in editorial serif
- *Monocle*: all proper names in the magazine's signature serif

If the body of a card uses `text-[12px] font-medium` (Inter), the name
inherited Inter. Looks generic. Looks like a default SaaS row, not a
person.

**The fix:** any text containing a personal name (the customer, a match,
a contributor) should explicitly use the display serif:

```tsx
<div
  className="font-serif leading-[1.1] truncate"
  style={{ fontSize: 16, letterSpacing: "-0.01em" }}
>
  {firstName} {lastName}
</div>
```

Audit the codebase for any `text-[XXpx] font-medium` (or no font-family
override at all) on a `<span>` that contains `{firstName} {lastName}`.
Those are the violations. Convert to `font-serif` with the right size.

**Hierarchy reminder:** serif for *names*, sans for *body*, mono for
*metadata and numerics*. The same pattern everywhere. Mixing a sans name
next to a serif name on the same screen breaks the editorial voice even
if the user can't articulate why.

## 23. Don't Iterate Publicly On A Logo — Think First, Then Build

User signal: "make it like we had previously but it should actually look
good" / "no i don't like the github logo why u can't do it" / repeated
pushback on each logo revision.

Logo design is high-stakes and personal. The user has taste and can see
when a logo is wrong. **Iterating publicly on a logo ("here's version
2, then 3, then 4") wastes the session** because each version prompts
a new round of feedback, and the user is now comparing your work to
your own previous work instead of evaluating the new design on its
own merits.

The pattern (6 rounds from this session):

1. Agent shows logo v1 (editorial seal with curved text).
2. User: "looks bad."
3. Agent shows logo v2 (italic TDC + mono MATCHMAKER).
4. User: "no."
5. Agent shows logo v3 (T-tile + wordmark).
6. User: "this is ugly together."
7. Agent shows logo v4 (no tile, just wordmark).
8. User: "still don't like."
9. Agent shows logo v5 (asymmetric T path + monospace).
10. User: "doesn't look good... make it similar to our page."

Six rounds. The user is now frustrated and the agent is guessing.

**The right move as a designer when the user says "make the logo":**

1. **Stop. Read the in-app brand mark first.** Look at the actual
   product (topbar nav, login page) to see what visual language the
   rest of the app uses. The README logo should be a horizontal
   lockup of the same mark + wordmark that already exists in the app.
2. **Make a single decision and ship it.** No "here are three options,
   which do you prefer?" Just pick the strongest direction and commit.
3. **If the user says "no," restore the previous version immediately.**
   Don't propose alternatives. Don't argue. The user's taste is the
   truth. Confirm what was good about the previous version and ask
   what specifically they want changed (if anything).
4. **Treat logo and favicon as separate artifacts.** The README logo
   is for GitHub documentation; the favicon is for browser tabs. The
   user may want them to look the same OR they may want them to be
   completely different (e.g., logo = horizontal lockup, favicon = just
   the mark). Don't change the favicon when asked to change the logo.

**The "don't try to read the SVG" rule:**

User signal: "what you doing why you stopped" / "don't try to read svg
read the page not the svg otherwise you'll stuck in loop."

When iterating on an SVG file, **don't try to render it to inspect it
during the iteration loop.** The agent's image tools will often fail on
SVG content (or render it generically), and the agent will keep asking
the user "is this right?" trying to read the rendering. The user can't
easily describe what they see in the SVG; they can describe what they
see on the GitHub README page.

**The fix:** commit + push the SVG change, tell the user "refresh the
GitHub README to see the new version," and wait for the user's
reaction. The user will see the actual rendered SVG in their browser
and give real feedback.

**Audit at the end of the logo work:** if the agent has shipped 4+
versions, that's a failure. Future agents should aim for 1-2 versions
max: first attempt, one revision, done. The user values restraint over
variety in design.

## 24. Default To Light Mode On First Visit

User signal: "by default make it ll alwasy open in light mode."

The "default theme = OS preference" pattern is the standard JS pattern:

```js
const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
const initial = prefersDark ? "dark" : "light";
```

But for a product that has been *deliberately* designed around a
light-mode aesthetic (warm beige, paper texture, ink-muted at a
specific legibility value), defaulting to dark mode when the OS says so
shows the user a half-finished dark mode. They have to find the toggle
to get to the design they were shown.

**The fix:** default to light on first visit. The user can still toggle
to dark, and the choice persists in localStorage. The OS preference is
irrelevant to the design intent.

```ts
useEffect(() => {
  try {
    const stored = localStorage.getItem("theme") as Theme | null;
    if (stored === "light" || stored === "dark") {
      setThemeState(stored);
      applyTheme(stored);
    } else {
      // First visit: always light. Override OS preference.
      setThemeState("light");
      applyTheme("light");
    }
  } catch {}
  setMounted(true);
}, []);
```

**When this rule applies:** any product where light mode is the
*deliberate primary design* (editorial, banking, healthcare, premium
consumer). When the product is dark-mode-first (developer tools, code
editors, security dashboards), invert the rule: default to dark.

## 25. Mobile-Fit Modals: Scrollable, Not Stretchable

User signal: "the modal is not fitting inside the mobile screen."

Modals with `height: 640px` (or any fixed pixel height) on a phone with a
568px viewport get clipped. The user can't reach the action buttons at
the bottom.

**The fix (4 changes that work together):**

1. **Outer modal: `max-height: calc(100vh - 24px)`, `overflow-y-auto`
   on mobile, `overflow: hidden` on desktop.** The whole modal scrolls
   on mobile if content is taller than the viewport. On desktop,
   inner panels scroll independently.
2. **Padding: `py-5` on the outer container, not `py-0` or `py-2`.**
   The user needs at least 12px on top and bottom of breathing room
   even on small phones.
3. **Hide redundant content on mobile.** If the modal has a stats
   panel that's already shown elsewhere in the page, hide it on
   mobile (`hidden md:grid`). The user can re-enable it by clicking
   a "more details" toggle if needed.
4. **Line-clamp long prose on mobile.** Notes, context blocks, and
   explanations should `line-clamp-3` on mobile and `line-clamp-none`
   on desktop. The user can tap to expand (if you have that
   affordance) or just scroll to see the rest.

**Code pattern:**

```tsx
<motion.div
  className="w-full max-w-[1080px] rounded-xl overflow-y-auto md:overflow-hidden
             grid relative grid-cols-1 md:grid-cols-[minmax(360px,400px)_1fr]"
  style={{
    maxHeight: "calc(100vh - 24px)",
    height: "min(640px, calc(100vh - 80px))",
  }}
>
  {/* hidden md:block for redundant stats */}
  <div className="hidden md:grid grid-cols-4 gap-2">
    <Stat ... />
  </div>
  
  {/* line-clamp on mobile for prose */}
  <span className="line-clamp-3 md:line-clamp-none">
    "{longNote}"
  </span>
</motion.div>
```

**Verify after implementing:**

```js
const modal = document.querySelector('[role="dialog"]') || document.querySelector('.rounded-xl');
const r = modal.getBoundingClientRect();
// On mobile: r.height should be close to (window.innerHeight - 24)
// If r.height < window.innerHeight - 24, modal is too short (content could be bigger)
// If r.height > window.innerHeight - 24, modal is being clipped
```

If on a real iPhone the modal still gets clipped, the user is probably
in landscape orientation — consider a different layout (bottom sheet
vs centered modal) for that orientation specifically.