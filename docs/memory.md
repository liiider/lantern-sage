# Lantern Sage Memory

## Project State

- Project name finalized as `Lantern Sage`.
- Current phase is product and visual design exploration only.
- No production code has been implemented.
- Workspace is not yet a Git repository.

## Product Direction

### Positioning

- `Lantern Sage` is a Chinese almanac and feng shui lifestyle app for overseas users.
- Product tone is calm, direct, brief, and never absolute.
- The product should avoid:
  - guaranteed luck
  - guaranteed wealth
  - medical claims
  - fear-based language
  - generic Western astrology UI tropes

### Commercial Direction

- Revenue strategy chosen:
  - subscription
  - low-priced one-time packs
  - limited daily usage leading to conversion
- Recommended first paid product:
  - `Important Date Pack`
- Working subscription concept:
  - `Lantern Sage Plus`

### Product Structure Decisions

- Onboarding should be lightweight:
  - choose timezone
  - choose city
  - continue as guest
- Core navigation intent:
  - Today
  - Ask
  - History
  - Profile
- Today page is the primary value surface.
- Ask page is the primary conversion surface.

## Content System Decisions

### Today Card

- Required content fields:
  - today message
  - good for
  - avoid
  - best time to go out
  - time to avoid
  - one practical suggestion
- Content must be short, practical, and non-theatrical.

### Quick Ask

- Fixed question entry points:
  - Is this a good time to go out?
  - Is this a good time to meet someone?
  - Is this a good time to discuss important matters?
  - What should I adjust first at home today?
- Output structure should stay concise:
  - short answer
  - recommended time window
  - caution
  - reason

### Evening Feedback

- Daily one-tap feedback:
  - Accurate
  - Neutral
  - Inaccurate

### History

- History should feel like a rhythm record, not a data archive.
- Default concept:
  - free: 7 days
  - plus: 30 days

## Visual Design Conclusions

### Rejected Directions

- Generic card-heavy dashboard layouts.
- Western astrology cosmic-purple aesthetics.
- Ordinary product-style serif plus utility UI treatment.
- Overly SaaS-like panel stacks and feature-card layouts.

### Competitive Reading

- Chani-like references are useful for:
  - editorial pacing
  - personality-rich typography
  - premium whitespace
  - worldbuilding before utility
- Chani-like references are not appropriate for:
  - color palette
  - celestial symbolism
  - astrology-first semantics

### Chosen Visual Language

- Core direction selected:
  - `manuscript ritual with carved accents`
- Key qualities:
  - archival
  - inherited
  - mysterious
  - not cosmic
  - not generic product UI

### Typography Direction

- Typography should not rely on ordinary UI fonts.
- Direction should combine:
  - manuscript hand / copied-text energy
  - carved inscription accents
  - symbolic sigil marks
- Most useful conclusion:
  - manuscript first
  - inscription second
  - sigil as supporting system

### Line Language

- Lines should feel:
  - scored
  - broken
  - slightly ceremonial
  - non-digital
- Useful line types established:
  - thin faded rule
  - broken inscription line
  - mystic wave line
  - chiselled frame geometry

### Color Direction

- Final selected palette direction:
  - `Ritual Parchment`
- Why it was chosen:
  - strongest literary / almanac feeling
  - most aligned with manuscript-based brand identity
  - less generic than product neutrals
  - avoids astrology purple while retaining warmth

## Visual Exploration Files

- `today-page.html`
  - early high-fidelity dark mystic version
- `today-page-v2.html`
  - brighter editorial paper direction
- `today-page-v3.html`
  - living almanac page-first composition
- `today-page-v4.html`
  - single-screen mystical hero exploration
- `today-typography-study.html`
  - first typography comparison pass
- `title-system-board-v2.html`
  - title system comparison pass
- `visual-theme-direction.html`
  - first visual theme board
- `visual-theme-direction-v2.html`
  - narrowed visual theme board
- `color-study.html`
  - four palette comparison study
- `today-page-ritual-parchment.html`
  - current best Today page draft using selected color direction

## Current Best Design

- Current working reference:
  - `today-page-ritual-parchment.html`
- Why it is the current best:
  - carries the selected parchment palette
  - preserves manuscript + sigil language
  - starts to hold actual Today content
  - avoids falling back into dashboard card stacks

## Work Completed

- Clarified monetization approach for MVP.
- Defined product positioning and content architecture.
- Defined Today / Ask / Feedback / History information structure.
- Explored multiple high-fidelity visual directions.
- Rejected several unsuitable visual directions.
- Chosen:
  - visual language
  - typography direction
  - line language
  - color direction
- Produced a current best static Today page draft.

## Planned Next Work

- Refine the current Today page typography and spacing.
- Rework Quick Ask so it feels less button-like and more native to the design system.
- Design Ask page in the same manuscript ritual system.
- Design History page in the same manuscript ritual system.
- Convert the chosen visual language into reusable component rules.
- After visual lock, begin implementation planning.

## Important Clarifications

- The user explicitly prefers a design that feels:
  - more mysterious
  - less like a tool website
  - more historically rooted
  - more like an inherited object than an app dashboard
- The user explicitly rejected designs that felt:
  - too card-heavy
  - too form-like
  - too product-generic
  - too close to Western astrology aesthetics
- The current design process should focus on visual quality before engineering.

## Tooling Notes

- Local skill `ui-ux-pro-max` exists at:
  - `C:\Users\MOREFINE\.codex\skills\ui-ux-pro-max\SKILL.md`
- It was not included in the session's injected `Available skills` snapshot.
- Work still proceeded using the local skill file as the design reference standard.
