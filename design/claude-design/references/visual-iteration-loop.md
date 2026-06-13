# The Visual Iteration Loop With The User

The `polish-pitfalls.md` file covers specific layout bugs that come up after
the first render. The `redesign-parallel-project.md` file covers the overall
flow for a sibling-project redesign. This file covers the **iteration loop
itself** — what to do on turns 2, 3, 4 when the user is reacting to your work
and asking for the next thing.

The pattern that came out of repeated sessions: the user gives short,
targeted signals ("scrollbar", "pics not visible", "matchmaker note thing we
missed", "design is skewed", "now what more"). Each signal is a chance to
either fix a specific bug, or to look at the whole system for the next
weakest thing. The trap is doing only the former.

## The Two Modes: Fix vs. Look

On every iteration turn, decide explicitly which mode you're in:

- **Fix mode** — the user named a specific thing. Fix that specific thing, then
  stop. Don't propose "while I'm at it, also fix X." Stay narrow. The user
  already has the next thing in mind; let them bring it up.
- **Look mode** — the user said "now what more" or "what else can we improve"
  or "still off" without naming a thing. This is permission to look at the
  whole system and identify the next weakest element. List 3-5 things, then
  pick the highest leverage and fix it.

The mistake is treating a "look mode" turn as a "fix mode" turn (just patch
the most obvious bug) or treating a "fix mode" turn as a "look mode" turn
(propose 3-5 improvements when the user only wanted the one).

## "Now What More" Turns — Look Mode Protocol

When the user says "now what more" or "what else" or "still feels off" or
"what's still wrong":

1. **Stop the current work.** If you just shipped a component, the next
   weakness is *not* in that component. It's elsewhere on the page or in the
   system.
2. **Take a fresh screenshot and ask `browser_vision` to be brutally honest
   about the WHOLE page**, not the last component you worked on. The prompt
   template:
   ```
   Be brutally honest. What's the single biggest issue with the WHOLE
   [page/component] right now? Look at proportions, alignment, what
   feels amateur, what would a real [Linear / Stripe / Vercel / Mercury /
   Arc] designer change immediately? Don't be polite.
   ```
3. **List 3-5 specific weaknesses.** Name the element ("the KPI strip" not
   "the top part"). For each, say what's wrong and what a premium version
   would do.
4. **Pick the highest leverage one and do it.** Don't do all 5 in one turn —
   the user wants to react to each. "I'd recommend A, then B, then C, in
   that order."
5. **Do that one** and stop. Wait for the user to say "more" or "yes next"
   before doing the next.

A real example from the TDC matchmaker v2 session:
- After polishing the compare canvas, the user said "now what more".
- I took a fresh screenshot and asked `browser_vision` for a brutal
  critique of the *dashboard* (not the compare canvas I just polished).
- `browser_vision` returned: "KPI strip is a data tombstone", "0 in
  Meetings looks broken", "Good evening Priya has nothing under it", "all
  rows look the same", "row info is too flat".
- I picked 3 (KPI as 1 hero + 3 satellites, hide 0 with opacity, add an
  "Up next" call-to-action) as the highest leverage, did them, and
  waited for the next signal.

## "This Is Skewed" Turns — Fix Mode Protocol

When the user says "design is pretty skewed" or "X is off" or names a
specific element:

1. **Take a screenshot and look at exactly the element they named.** Don't
   try to "improve" the whole screen — fix the thing they pointed at.
2. **Use `browser_console` to measure the element.** `getBoundingClientRect()`,
   `offsetWidth`, `offsetHeight`, scroll position. The screenshot might miss
   a 5px misalignment that the DOM measurement catches. The most common
   culprits:
   - Two columns of a grid aren't actually the same height (use
     `min-height: 0` on the flex children, switch `maxHeight` to `height` on
     the parent)
   - A bar in a chart is clipped at the right edge (the row's total
     width exceeds the viewport)
   - A label is overlapping an icon (z-index or padding issue)
   - A sticky rail's scroll position doesn't match the active item
3. **Fix the specific thing.** Don't list other things that might be wrong
   — they didn't ask. After the fix, ask "is that better?" or just
   screenshot and let them react.

## "Prev Was Better" / Rollback Signals

User signals that mean "revert the last visual change, stop adding more":

- "no i don't like it"
- "prev was better"
- "you added too much"
- "this is too busy"
- "i wanted it simpler"
- "this looks shit"
- "stp the loop" (casual "stop the loop")

When you hear one:

1. **Revert immediately.** Don't argue, don't propose alternatives, don't
   ask "do you want A or B instead?". Revert.
2. **Don't repeat-fix the same area.** After a rollback, the user has told
   you the conservative version is correct. Pick a different part of the
   system for the next change. If the user wanted that area changed, they
   would have said "fix X" not "prev was better."
3. **Don't immediately propose a third option.** "What if I tried C?"
   after "no I don't like B" is annoying. The user is tired of seeing
   options in that area. Move on.
4. **"Stop the loop" is a meta-signal.** When the user says to stop
   iterating, they've decided the current area is good enough (or the
   work is wasting their time). Do not interpret this as a request for
   one more attempt with a different angle. Revert to the version the
   user implicitly accepted and move to a *different* part of the
   system. Real example: in a TDC v2 session, the user said "stp the
   loop" after 4 logo iterations. The right move was to revert to the
   last good version (a T-tile lockup that matched the in-app brand
   mark) and stop touching the logo. Pushing "but here's a 5th option"
   would have just delayed the work.

A real example: the 3D bar chart was built, the user said "no i don't like
it prev was better". I reverted the 3D chart to the previous 2-col
dim grid. After the revert, the user did not ask for the 3D chart
back, nor did they ask for any other chart-related change. The "prev
was better" was the end of the chart discussion.

## The Logo / Brand-Mark Iteration Trap

Logo design is the most common area where an agent falls into the
iteration trap, because the user often can't articulate what they want
("make it look better" / "the current one looks shit" / "make it
simpler") and the agent keeps generating variants of the same idea
until both sides are frustrated. Rules:

1. **First ask: does the brand have an in-app mark?** If the product
   has a nav logo, favicon, or any internal T-tile / wordmark, *the
   README logo and favicon should reuse that mark* in a horizontal
   lockup. Don't invent a new mark. "Make it similar to our page"
   means: keep the mark the same, just compose it for the README's
   aspect ratio.

2. **The mark should be drawn as `<path>`, not `<text>`.** A logo that
   says `<text font-family="Playfair Display">T</text>` depends on
   the web font loading, which is unreliable in README image previews
   on GitHub. Draw the letter as a polygon path with hardcoded
   coordinates. The path renders identically everywhere, even when
   the font doesn't load. See `templates/logo-mark.svg` for a known-
   good starting mark (a serif T with an extended crossbar that
   doubles as a horizon / meeting line).

3. **If you cannot render the output, you cannot iterate on it.**
   `vision_analyze` does not work on SVG files (it needs raster
   images). If the only output is an SVG and you cannot `curl` the
   rendered image, do not loop on "does it look right?" — describe
   the path coordinates in plain text ("a T with cap 48px wide,
   stem 10px wide, 48px tall, crossbar 8px tall") and trust the
   design. Trying to use `vision_analyze` on an SVG file in a loop
   is wasted effort — the user has to tell you each time what's
   wrong, which makes the loop feel endless.

4. **Stop after 2 iterations on the same area** unless the user is
   giving specific feedback ("the crossbar is too long"). Generic
   feedback ("make it better", "looks shit", "still bad") means the
   user has not articulated a concrete change — generating a 5th
   variant is a coin flip, not design. Revert to the version that
   was the closest to in-app and move on.

## "The Design Is Pretty Skewed" / "It Feels Off" — Diagnostic Pattern

When the user says "X is off" or "X feels off" but doesn't name the
specific issue:

1. **Don't guess.** Open the page in `browser_vision` and ask it to be
   brutal: "What is specifically wrong with this modal/page? Name the
   element, what feels off, what a real designer would change."
2. **`browser_vision` will often give you a list of 3-5 things.** Identify
   the *single biggest* one and fix that. Don't try to address all 5 in
   one turn.
3. **If the screenshot is fine but the page still feels off**, the issue
   is probably structural — page rhythm, section spacing, type hierarchy —
   not a single element. Use `browser_console` to measure: section
   heights, gap between elements, the proportion of empty space. Compare
   to what a premium product does.

## "Now What More" After Multiple Turns

If the user has been saying "now what" for 2-3 turns in a row, you've been
picking the wrong scope. The signal is:

- They've stopped naming specific elements
- They keep saying "more" / "next" / "what else"
- Each fix is correct but doesn't move the needle

This means the issue is at the **system level**, not the component level.
Stop tweaking components. Re-read the brief from turn 1. What's the
*one thing* the user really wants this product to be that you haven't
delivered yet? It might be:

- A core information architecture decision (where things live, how
  they're grouped, what the primary action is)
- A interaction model (how the user moves through the work — keyboard
  nav, command palette, drag-and-drop)
- An empty state or zero-data state (does the app degrade gracefully)
- A meta-decision (is this even the right scope — should it be a
  redesign or a smaller targeted change?)

Ask the user directly. "I've been polishing the same areas. The page
is still feeling off to you. Is the design itself wrong, or is it the
structure / IA / what we're actually building?" They'll tell you
whether to keep polishing or pivot.

## Tooling Notes For The Iteration Loop

- **`browser_vision` with a specific question beats `browser_vision` with
  a generic "does this look good".** "Be brutally honest about the WHOLE
  dashboard, name the weakest 3 things" gets a useful answer. "How does
  this look?" gets a useless answer.
- **Reload the page in the browser before screenshotting.** Hot-reload
  sometimes leaves the page in a stale state where the new component
  hasn't actually mounted. `browser_navigate` to the same URL forces a
  fresh load.
- **`browser_console` for measurements, not `browser_vision`.** A
  screenshot is good for "does it look right" and bad for "is the
  width 380px or 360px". When you need a number, use
  `getBoundingClientRect()` via `browser_console` with an `expression`
  argument.
- **If `browser_navigate` clears localStorage and bounces you back to
  the login page**, log in via the snapshot's "Enter workspace" button
  (the auth state is in `localStorage`, which gets cleared on URL
  change), or pre-set it via a one-off `browser_console` expression.
