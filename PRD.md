# Lantern Sage PRD

## 1. Document Purpose

This PRD is the execution standard for subsequent product development, frontend implementation, backend implementation, and content generation for `Lantern Sage`.

It consolidates the current decisions across:
- product design logic
- business logic
- content logic
- data logic
- visual design logic
- implementation boundaries

If a later change conflicts with this document, the newer explicit user instruction wins.

---

## 2. Product Summary

### 2.1 Product Name
- `Lantern Sage`

### 2.2 Positioning
- A Chinese almanac and feng shui lifestyle app for overseas users.
- The product provides calm, practical daily guidance based on Chinese almanac logic and light home-adjustment logic.
- The product is not positioned as fortune telling, guaranteed luck, or mystical prediction.

### 2.3 Product Goal
- Deliver a usable overseas mobile MVP that can validate:
  - daily retention
  - paid conversion
  - willingness to buy lightweight timing guidance
  - willingness to buy one-time event guidance

### 2.4 Core Value Proposition
- Better timing for the day
- Light home adjustment suggestions
- Short, practical decision support
- A feeling of rhythm, continuity, and inherited wisdom

---

## 3. Business Logic

### 3.1 Commercial Objective
MVP must be designed to support monetization early, without depending on ads or heavy operations.

### 3.2 Revenue Model
The product uses a mixed revenue model:
- subscription
- one-time purchase packs
- limited daily usage leading to conversion

### 3.3 Main Commercial Offers
#### Free Layer
- Today page access
- limited daily Quick Ask usage
- evening feedback
- recent history access

#### Subscription Layer
- product name: `Lantern Sage Plus`
- unlocks:
  - more daily Quick Ask usage
  - longer history window
  - deeper rhythm summaries
  - more detailed timing guidance
  - richer home-adjustment guidance

#### One-Time Purchase Layer
- first priority product: `Important Date Pack`
- purpose:
  - focused guidance for a specific upcoming date or event

### 3.4 Current Business Judgment
The business logic should prioritize:
1. habit formation through Today
2. conversion through Ask limits
3. early one-time purchase through Important Date Pack
4. retention through History and rhythm summaries

### 3.5 Explicit Non-Goals for MVP
Do not build in phase 1:
- ads
- payments infrastructure beyond placeholder planning
- subscriptions implementation if not yet wired
- human reader marketplace
- community
- heavy onboarding profiling
- room photo analysis
- course platform
- admin backend
- RAG
- LangChain
- LangGraph
- vector database

---

## 4. Target Users

### 4.1 Primary Audience
- English-speaking overseas users
- astrology-adjacent / self-reflection / lifestyle users
- users open to Chinese almanac and feng shui framing
- mobile-first audience

### 4.2 Product Expectations
These users are expected to prefer:
- short answers
- calm tone
- practical daily guidance
- premium atmosphere
- discoverable but not overwhelming content

### 4.3 Users We Are Not Designing For First
- expert traditional metaphysics practitioners
- users seeking religious tools
- users expecting guaranteed life outcomes
- users wanting long-form spiritual essays

---

## 5. Product Principles

### 5.1 Tone Principles
All product language must be:
- calm
- direct
- brief
- non-absolute
- practical

### 5.2 Prohibited Tone
Never use:
- guaranteed luck
- guaranteed wealth
- medical claims
- fear-based or threatening copy
- manipulative mystical language
- exaggerated promises

### 5.3 Interaction Principles
- show value quickly
- keep inputs light
- avoid open-ended complexity in MVP
- reduce cognitive load on first use
- preserve mystery without reducing usability

### 5.4 Design Principles
- editorial over dashboard
- page-first over card-first
- premium over busy
- inherited artifact over generic app UI
- Chinese almanac logic, not Western astrology imitation

---

## 6. Core Product Structure

### 6.1 Main Navigation
Bottom navigation order:
1. Today
2. Ask
3. History
4. Profile

### 6.2 Onboarding
Lightweight onboarding only:
1. choose timezone
2. choose city
3. continue as guest

Do not ask for:
- birth chart details
- home details
- belief questions
- long profile setup

### 6.3 Guest Mode
Guest mode is allowed by default.
Identity can initially be:
- device_id
- anonymous session

---

## 7. Page-Level Product Requirements

## 7.1 Today
### Purpose
The Today page is the primary value surface and the daily habit anchor.

### Required Content
- daily thesis / today message
- good for
- avoid
- best time to go out
- time to avoid
- one practical suggestion
- selected almanac base fields

### Product Role
Today should feel like:
- a daily folio
- a living almanac page
- a premium object with utility

### Current Locked Topline for Current Static Design
Current static Today reference keeps:
- `April 10, 2026 - Friday`
- `Lunar March 3  Clear and Bright`

### Current Hero Copy Lock
- title: `Move where the day opens.`
- supporting copy: `Keep the pace lighter than instinct. Let order arrive before effort.`

## 7.2 Ask
### Purpose
Ask is the focused interaction page and the main conversion surface.

### Fixed Question Entries
- Is this a good time to go out?
- Is this a good time to meet someone?
- Is this a good time to discuss important matters?
- What should I adjust first at home today?

### Output Structure
- short answer
- recommended time window
- caution
- reason

### Product Constraint
Do not make Ask a free-form chatbot in MVP.

## 7.3 Evening Feedback
### Purpose
Feedback supports:
- habit formation
- perceived personalization
- future tuning logic

### Options
- Accurate
- Neutral
- Inaccurate

## 7.4 History
### Purpose
History should feel like a rhythm record, not a raw archive.

### Current Scope
- free: recent 7 days
- plus: 30 days

### Each day can include
- daily card
- ask records
- feedback status

## 7.5 Profile
### Purpose
- guest state
- settings entry
- subscription entry
- important date product entry
- app info

---

## 8. Content Logic

### 8.1 Content Strategy
The product content should be built in layers:
1. base almanac facts
2. product-readable interpretation
3. practical action guidance

### 8.2 Today Content Structure
Today content should be expressed as:
- one thesis line
- practical good-for list
- practical avoid list
- timing windows
- one small action suggestion

### 8.3 Quick Ask Content Structure
Ask responses must stay concise and structured.
Do not generate long essays.

### 8.4 Home Adjustment Logic
Home guidance in MVP must stay lightweight.
Allowed directions:
- clear the entrance
- simplify a visible surface
- soften one area
- improve airflow or light
- reduce visible clutter

Do not imply:
- expert diagnosis
- exact compass-level instruction
- guaranteed feng shui transformation

### 8.5 AI Output Rules
- frontend must never call model APIs directly
- backend must produce structured facts first
- then generate constrained copy from those facts
- copy output must follow fixed schema
- no free-form long generation

---

## 9. Visual Design Logic

### 9.1 Chosen Visual Direction
Locked direction:
- `manuscript ritual with carved accents`

### 9.2 Selected Palette Direction
Locked palette:
- `Ritual Parchment`

### 9.3 Visual Characteristics
The design should feel:
- archival
- inherited
- mysterious
- calm
- premium
- not cosmic
- not SaaS-like

### 9.4 Rejected Visual Directions
Do not drift back into:
- card-heavy dashboards
- generic app utility layouts
- western astrology cosmic-purple design
- ordinary serif + product UI combos
- over-form-like sections

### 9.5 Typography Logic
Typography should combine:
- manuscript hand energy
- carved inscription accents
- sigil support marks

Typography should not feel like:
- default app typography
- generic landing page serif
- ordinary blog UI

### 9.6 Line Language
Lines should feel:
- scored
- faded
- ceremonial
- slightly imperfect
- non-digital

Use patterns like:
- thin faded rule
- broken inscription line
- wave divider
- carved frame geometry

### 9.7 Current Static References
Primary static references currently in project:
- `D:\Lantern Sage\design-explorations\today-page-ritual-parchment-refined-v4.html`
- `D:\Lantern Sage\design-explorations\ask-page-ritual-parchment.html`
- `D:\Lantern Sage\design-explorations\history-page-ritual-parchment.html`

These are design references, not production code.

---

## 10. Frontend Logic

### 10.1 Frontend Stack Requirement
- Flutter

### 10.2 Frontend Rules
- UI language must be English
- frontend must not directly call AI providers
- use a clean structure but keep it readable and small
- do not overcomplicate first version interactions

### 10.3 Static-to-Implementation Translation
The current HTML explorations define:
- hierarchy
- rhythm
- surface treatment
- typography attitude
- panel structure

Flutter implementation should preserve the same product logic and visual hierarchy, not necessarily duplicate raw HTML.

---

## 11. Backend Logic

### 11.1 Backend Stack Requirement
- FastAPI
- PostgreSQL
- Redis
- object storage placeholder only

### 11.2 Backend Architecture Principle
- clean architecture
- small and readable
- schema-first at API boundaries
- structured facts before copy generation

### 11.3 AI Provider Strategy
Provider abstraction required.
Current provider plan:
- DeepSeekProvider first
- GeminiVisionProvider placeholder
- QwenVisionProvider placeholder

### 11.4 Backend Boundary Rules
- every interface must have Pydantic schema
- validate all external inputs
- cache user daily read
- same-day revisit should hit cache

---

## 12. API Requirements

Required endpoints:
- `POST /day/facts`
- `POST /day/read`
- `POST /ask`
- `POST /feedback`
- `GET /history`

### 12.1 POST /day/facts
#### Input
- user_id
- timezone
- city
- current_date

#### Output
- date
- timezone
- city
- lunar_date
- solar_term
- day_ganzhi
- hour_blocks
- today_tags
- advisory_flags

### 12.2 POST /day/read
#### Input
- facts JSON
- user profile summary

#### Output
- today_message
- good_for[]
- avoid[]
- best_outgoing_time
- avoid_time
- practical_tip

### 12.3 POST /ask
#### Input
- user_id
- question_type
- current facts

#### Output
- short_answer
- recommended_time_window
- caution
- reason

### 12.4 POST /feedback
#### Input
- user_id
- date
- rating

#### Behavior
- persist one feedback record per user per day

### 12.5 GET /history
#### Output
- recent daily cards
- question records
- feedback records
- up to 30-day window depending on product tier

---

## 13. Data Logic

### 13.1 Core Data Entities
Required database tables:
- users
- daily_facts
- daily_reads
- questions
- feedbacks

### 13.2 Recommended Table Roles
#### users
Stores user identity and lightweight profile context.
Possible fields:
- id
- anonymous_device_id
- city
- timezone
- tier
- created_at
- updated_at

#### daily_facts
Stores structured almanac facts for a user and date.
Possible fields:
- id
- user_id
- date
- city
- timezone
- lunar_date
- solar_term
- day_ganzhi
- facts_json
- created_at

#### daily_reads
Stores rendered Today interpretation.
Possible fields:
- id
- user_id
- date
- facts_id
- today_message
- good_for_json
- avoid_json
- best_outgoing_time
- avoid_time
- practical_tip
- created_at

#### questions
Stores Quick Ask history.
Possible fields:
- id
- user_id
- date
- question_type
- answer_json
- created_at

#### feedbacks
Stores evening feedback.
Possible fields:
- id
- user_id
- date
- rating
- created_at

### 13.3 Cache Logic
Redis cache requirement:
- cache same-user same-day daily read
- repeated Today page visits should use cached daily read

Suggested cache key shape:
- `daily_read:{user_id}:{date}`

### 13.4 Structured Data Rule
Facts and generated interpretation must remain separable.
Do not store only final prose.

---

## 14. AI and Generation Logic

### 14.1 Generation Flow
1. build structured facts
2. validate facts schema
3. pass facts into constrained generation prompt
4. receive structured output
5. validate output schema
6. persist and cache result

### 14.2 Prompting Constraints
- short outputs only
- fixed schema only
- no dramatic mystical over-generation
- no high-stakes claims
- no medical, legal, or financial advice

### 14.3 Output Style Constraints
Generated copy should sound like:
- practical guidance
- calm observation
- timing-aware editorial note

Generated copy should not sound like:
- prophecy
- guru monologue
- threat or warning sermon

---

## 15. Design-to-Development Rules

### 15.1 Mandatory Design Workflow
Per project behavior spec:
1. use `ui-ux-pro-max` first for design judgment and visual direction
2. use `gpt-5.3-codex` for implementation
3. use `mini` for review
4. continue iterating until the result meets `ui-ux-pro-max` standard

### 15.2 Change Control Rule
- do not modify any area the user did not explicitly request
- keep changes narrow
- when reverting, revert only the specified area

Reference:
- `D:\Lantern Sage\PROJECT-BEHAVIOR.md`

---

## 16. Current Development Boundaries

### 16.1 Current Phase
Current phase is still:
- product definition
- static page design
- implementation planning

### 16.2 Not Yet Done
- no production Flutter app
- no production FastAPI service
- no database implementation
- no Redis implementation
- no payment implementation
- no CI or deployment implementation

---

## 17. Recommended Next Development Sequence

1. lock static design system rules from current Today / Ask / History pages
2. define Flutter app structure and page skeletons
3. define backend folder structure and schemas
4. implement `/day/facts` and `/day/read`
5. implement Today page first
6. implement Ask page and usage limits
7. implement Feedback and History
8. add caching and persistence verification

---

## 18. Success Criteria for MVP

The MVP should be able to demonstrate:
- a coherent daily reading experience
- at least one repeat-use path
- a credible Ask conversion path
- a one-time paid product narrative
- a premium, differentiated visual identity
- a clear distinction from generic astrology apps

---

## 19. File Role

This file is the current product standard for `Lantern Sage`.
Use it as the default reference for:
- frontend implementation
- backend implementation
- data modeling
- API design
- future feature scoping
- design consistency