---
name: visual-iteration-loop
description: How to handle design iteration across turns 2, 3, 4+ when the user is reacting to visual work. Covers Fix-vs-Look mode, when to ask vs when to declare, when to stop tweaking components and ask about scope.
---

# Visual iteration loop

This is a meta-skill about how to handle the *iteration loop itself* when the user is reacting to design work across multiple turns. Not about producing one good design — about navigating the back-and-forth.

## The 1st-turn rule (Fix mode vs Look mode)

When the user gives the first reaction to a design, you don't know if they mean:
- "Fix this specific thing" — they want a targeted patch
- "This is wrong, rethink the direction" — they want a bold reframe
- "I don't have words yet, just look" — they want me to keep iterating with judgment

Default to **Fix mode** (smallest viable change) and watch their tone. If they escalate ("doesn't feel right", "try again", "more"), step up to **Look mode** (full reframe, change direction not parameters).

## The escalation ladder

Read the user's tone carefully:

| Tone | Signal | Action |
|---|---|---|
| Single specific complaint | "the X is too Y" | Targeted fix to that one thing |
| Multiple complaints in one turn | "the Y is bad, the Z is ugly, the W is missing" | Fix mode but address all in one pass |
| Repeated rephrasing of same complaint | "doesn't look good", "is still wrong", "feels missing" | The user is sensing a deeper problem they can't articulate. **Step up to Look mode.** Re-evaluate the design at a higher level. Don't just tweak parameters. |
| Impatient | "just do it", "do it buddy", "what you doing" | Don't ask questions. Declare and execute. Move fast. |
| Direct comparison | "v1 was better", "this is like the old one" | They want the original back, or they want a new direction. Don't compromise — pick one and commit. |

## When to declare vs when to ask

Default to **declaring and executing**. The user wants momentum. Asking questions at this stage is friction.

**Ask only if:**
- Two genuinely different design directions are possible and the choice is a real tradeoff
- A specific piece of information is needed (target audience, scope of change)
- The user explicitly asks "what do you think"

**Never ask:**
- "Should I keep the X or remove it?" — pick one based on the design, defend the choice
- "What about Y?" — propose Y if it's better, don't poll
- "Do you want me to do this?" — if it's the obvious next step, just do it

## When to stop tweaking components and ask about scope

If 3+ iterations in a row have been tweaks to small things (a font size here, a color there, a padding value), the design is probably right and the *user* might be looking at the wrong thing. Stop and ask:

"Looking at this fresh — what specifically feels off? The overall direction, or a particular element?"

If they say "the overall direction", it's time to Look mode (reframe). If they say "this specific thing", go back to Fix mode.

## The "did you check X" pattern

The user often asks "did you check the previous commits" or "did you check the original" — this is a tell that they think I missed something. Always:
1. Actually go check (git log, file diff, original repo)
2. Report back briefly: "I checked, found [X]. Current state: [Y]."
3. If I missed something, fix it. If I didn't, defend briefly and move on.

Don't argue. Don't lecture about what I did find. Just answer the question.

## Honesty about what didn't work

When a previous design decision was wrong and the user is reacting to it:
- Acknowledge it directly in one sentence
- Don't repeat the original reasoning
- Propose the new direction
- Execute

Bad: "Looking back at my earlier analysis, I considered X and Y, and based on the constraints..."
Good: "Yeah, the floating wordmark doesn't work without an anchor. Bringing back the T tile at smaller scale."

## The "no it doesn't look good" loop

If the user keeps saying "no" or "still wrong" without specifying what, it's a sign of:
- Visual fatigue (they've been looking at the same screen too long)
- The actual design being fine but the framing being wrong
- A missing element they can't articulate

Best move: do one bold change in a new direction, not another small tweak. If they keep rejecting small changes, the answer is usually a direction change, not a parameter change.
