# Lantern Sage Today Page Handoff - 2026-04-12

## Scope of this handoff

This handoff captures the `Today` page refinement work completed after the earlier `v5` summary.

This round covered the following static exploration files:

- `design-explorations/today-page-ritual-parchment-refined-v6.html`
- `design-explorations/today-page-ritual-parchment-refined-v7.html`
- `design-explorations/today-page-ritual-parchment-refined-v7-1.html`
- `design-explorations/today-page-ritual-parchment-refined-v7-2.html`
- `design-explorations/today-page-ritual-parchment-refined-v7-3.html`

## Current recommended file

The current preferred reference is:

- `design-explorations/today-page-ritual-parchment-refined-v7-3.html`

Why this is the keep for now:

- it preserves the strongest center seal direction
- it removes the top lunar / solar-term / ganzhi source line from the hero
- it keeps the compact `Good for / Avoid`-first lower hierarchy from `v7-2`
- it adds restrained seal-derived visual language so the page feels less plain without becoming noisy

## Design direction confirmed in this thread

### 1. Hero responsibility

The hero now fully carries the page's `Today message` / daily thesis responsibility.

This means the lower manuscript body should **not** repeat a separate visible `Today message` section.

The hero should keep:

- minimal topbar
- center seal
- main title
- supporting copy

The current locked hero copy being used in later files is:

- title: `Move where the day opens.`
- supporting copy: `Keep the pace lighter than instinct. Let order arrive before effort.`

### 2. Top metadata removal

The line showing lunar date / solar term / ganzhi at the top was intentionally removed in `v7-3`.

Reason:

- the user judged that overseas users do not understand this line
- removing it makes the hero cleaner and easier to parse

This is an intentional override of the earlier lighter-day-note direction.

### 3. Seal direction

The center seal direction is now considered a strong result and should be preserved.

Current judgment:

- it should remain the main symbolic anchor
- it should feel carved / day-derived / slightly irregular
- it should not go back to precise geometric rings or cross-axis construction
- it should not be shrunk again casually

### 4. Lower hierarchy

The lower body now follows this intended order:

1. `Good for`
2. `Avoid`
3. collapsed `Timing guidance`
4. collapsed `One practical suggestion`
5. collapsed `Selected almanac base fields`
6. collapsed `Ask invitation`

Key reasoning:

- the hero already states the day's thesis
- the next thing users need is a clear `宜 / 忌` reading
- detailed timing should not be shown by default
- later content should start folded so the page does not feel too long

### 5. Twin structure for Good / Avoid

`Good for` and `Avoid` should feel like a paired manuscript reading, not two separate product cards.

Current intended behavior:

- mobile: stacked but clearly paired
- wider widths: can sit side-by-side within one shared section
- equal visual weight
- shared section feel, not independent card feel

### 6. Progressive reveal

`v7-2` introduced a shorter initial page by collapsing later sections.

That behavior continues in `v7-3`.

Collapsed by default:

- timing windows
- practical suggestion detail
- selected almanac base fields
- ask invitation question list

This should remain a core behavior for now.

## Visual refinements completed across versions

### v6

- restored the PRD-locked hero copy
- corrected the day-note separator
- moved the page toward a single folio reading instead of stacked cards

### v7

- removed more app-shell feeling
- improved the seal away from overly geometric construction
- made the lower body feel more like a continuous folio

### v7-1

- forced the top source note into a single horizontal line
- reduced the manuscript container's premium-card feeling

### v7-2

- removed the duplicate lower `Today message`
- moved the lower body directly into paired `Good for / Avoid`
- collapsed timing and all later sections to shorten the initial read

### v7-3

- removed the top source note entirely
- kept the compact `v7-2` structure
- extended the seal language into:
  - masthead mark
  - disclosure markers
  - title guidance
- added subtle folio texture / wear so the page stays minimal but not too plain

## Active constraints to preserve

- no gradient-based page background
- no gradient-based card or folio surfaces
- warm historical tone
- not generic app UI
- not SaaS-like
- not cosmic / astrology-purple
- topbar remains minimal
- hero remains restrained
- center seal remains the main anchor

## Current caveats

### 1. V7.3 is the preferred direction, but ornament is near the limit

The new title guidance, disclosure marks, and texture additions are currently acceptable.

They should **not** become stronger without good reason.

### 2. Base-field visibility has moved lower in priority

The almanac base fields still exist and remain reachable, but they are no longer part of the hero or top-of-page framing.

This is now intentional.

### 3. The page should remain short on first load

Do not casually re-open all collapsed sections by default.

That would undo one of the main structural wins from this thread.

## Recommended next-thread starting point

Start from:

- `design-explorations/today-page-ritual-parchment-refined-v7-3.html`

Recommended next focus order:

1. Review whether the added title-guidance / texture layer is exactly at the right level or needs a slight reduction.
2. Review the paired `Good for / Avoid` section in rendered form for balance and reading rhythm.
3. Review the collapsed disclosure rows for elegance and whether their markers feel too repetitive.
4. Only after that, consider whether any lower detail section should have a slightly richer preview state.

## Do-not-regress notes

- do not bring back the lower duplicate `Today message`
- do not reopen full timing windows by default
- do not turn the lower body back into separate app cards
- do not weaken the current center seal direction
- do not reintroduce the top almanac line unless the product decision changes explicitly
- do not drift toward black-gold luxury UI, glass, or generic dashboard styling

## Git handoff note

For this round, the files that matter for publishing this work are:

- `design-explorations/today-page-ritual-parchment-refined-v6.html`
- `design-explorations/today-page-ritual-parchment-refined-v7.html`
- `design-explorations/today-page-ritual-parchment-refined-v7-1.html`
- `design-explorations/today-page-ritual-parchment-refined-v7-2.html`
- `design-explorations/today-page-ritual-parchment-refined-v7-3.html`
- `WORK-SUMMARY-2026-04-12-TODAY-V7-3-HANDOFF.md`

Other unrelated modified files in the repo should not be mixed into this handoff publish unless explicitly requested.
