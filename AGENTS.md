# Lantern Sage - Agent Instructions

## Project Context

**Lantern Sage** is a Chinese almanac and feng shui lifestyle app for overseas users. Currently in design exploration phase with HTML prototypes.

### Product Tone
- Calm, direct, brief, never absolute
- Avoid: guaranteed luck, guaranteed wealth, medical claims, fear-based language, generic Western astrology UI tropes

### Core Navigation
- **Today**: Primary value surface (daily guidance)
- **Ask**: Primary conversion surface (Q&A)
- **History**: Past readings
- **Profile**: User settings

## UI/UX Workflow (REQUIRED)

Per `PROJECT-BEHAVIOR.md`, all design adjustments MUST follow this order:

1. **Use ui-ux-pro-max** for design direction and visual decisions
2. **Then implement** HTML/CSS changes
3. **Then verify** against ui-ux-pro-max standards
4. **Iterate** if standards not met

### Quick Commands

```powershell
# Generate design system
.\tools\ui-ux-pro-max.cmd "chinese almanac ritual parchment dark amber" --design-system -p "Lantern Sage" --persist --output-dir .

# Search specific patterns
.\tools\ui-ux-pro-max.cmd "accessibility contrast" --domain ux
```

## Key Directories

```
/design-explorations/     # HTML prototypes (32 versions of today-page)
/design-system/           # Generated design tokens (MASTER.md, pages/)
/docs/                    # Documentation
/tools/                   # ui-ux-pro-max wrappers
```

## Current Design System

**Visual Direction**: Ritual Parchment
- **Background**: `#1C0A00` (deep brown)
- **Accent**: `#CC9544` (amber/gold)
- **Typography**: Iowan Old Style, Palatino Linotype, Georgia, Noto Serif SC
- **Texture**: Folio paper texture (minimal - 6 elements)
- **Mood**: Vintage, calm, ceremonial

### Spacing System
- **Base unit**: 8px
- **Page gap**: 24px
- **Body padding**: 24px 16px 48px
- **Card padding**: 16px-24px

### Contrast Standards
- **text-strong**: 0.96 opacity (7.1:1)
- **text-soft**: 0.8 opacity (5.1:1)  
- **text-faint**: 0.55 opacity (3.5:1)
- **Minimum WCAG AA**: 4.5:1 for normal text

## Design Principles (from PRD)

1. **Better timing, not guaranteed luck**
2. **Light home adjustment, not renovation**
3. **Short practical guidance, not essays**
4. **Rhythm and continuity, not predictions**

## File Naming Convention

- `today-page-ritual-parchment-refined-v{N}.html` - Latest iteration
- `design-explorations/` - All prototypes preserved for reference
- `WORK-SUMMARY-YYYY-MM-DD.md` - Session handoffs

## Important Constraints

- **No production code yet** - Design exploration only
- **Mobile-first** - Target 375px-414px viewport
- **Static HTML** - No frameworks, no build step
- **Single-file prototypes** - All CSS inline, no external deps

## Reference Files

- `PRD.md` - Full product requirements (718 lines)
- `memory.md` - Project decisions and state
- `PROJECT-BEHAVIOR.md` - Design workflow rules
- `design-system/lantern-sage/MASTER.md` - Generated design tokens

## Common Tasks

### Creating a new page variant
1. Copy latest `today-page-ritual-parchment-refined-v{N}.html`
2. Increment version number
3. Apply ui-ux-pro-max guided changes
4. Update `WORK-SUMMARY-*.md` with changes

### Updating design system
```powershell
.\tools\ui-ux-pro-max.cmd "<new direction>" --design-system --persist -p "Lantern Sage"
```

### Reviewing design
- Check contrast ratios (WCAG AA 4.5:1 minimum)
- Verify spacing consistency (8px grid)
- Ensure no emoji icons (use SVG)
- Test responsive at 375px, 768px, 1024px

## Tech Stack

- **Frontend**: Vanilla HTML5, CSS3
- **Design Tool**: ui-ux-pro-max skill
- **Version Control**: Git (design-explorations branch)
- **No build tools** - Direct file editing

## Python Requirement

ui-ux-pro-max requires Python 3.12+:
- Preferred: `python` or `py` command
- Fallback: `C:\Users\MOREFINE\AppData\Local\Programs\Python\Python312\python.exe`
