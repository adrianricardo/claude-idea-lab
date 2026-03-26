# Demo Style Guide

Design standards for auto-generated idea demos and prototypes.

## Core Principles

1. **It's a pitch, not a prototype** — the demo should sell the idea in 10 seconds of interaction
2. **Single compelling moment** — capture the "aha" moment, not the whole product
3. **Looks real** — someone who sees it should immediately understand the idea
4. **Interactive** — the user should be able to click, type, drag, or otherwise engage
5. **Self-contained** — single HTML file, no dependencies, no build step

## Design Standards

### Aesthetic
- Dark theme: deep navy backgrounds, subtle borders, amber accent
- Font: Inter (Google Fonts), system-ui fallback
- Frosted glass for overlays (backdrop-filter: blur on dark surfaces)
- Generous whitespace
- Colored accents for emphasis (amber primary, green/purple/coral secondary)

### Simplicity
- One primary interaction per view
- Progressive disclosure — don't show everything at once
- Clear visual hierarchy

### Fluidity
- Animate all transitions (no instant show/hide)
- Use `cubic-bezier(0.4, 0, 0.2, 1)` for standard easing
- Use `cubic-bezier(0.34, 1.56, 0.64, 1)` for spring/bounce
- Stagger animations when showing multiple items (50-80ms delay between)

### Delight
- Micro-interactions: hover states, button presses, satisfying clicks
- Typed text animations for showing content
- Subtle color transitions on state changes
- The interaction should be satisfying enough that users want to play with it

## Quality Bar

- Does it look like a real product screenshot? If not, it's not done.
- Can someone understand the idea in 10 seconds? If not, simplify.
- Is the core interaction satisfying? If not, add polish.
- Does it work with just `open file.html`? If not, simplify.

## CSS Variable Reference

Use the same CSS variables as the showcase template (`showcase-template.html`) for consistency when the demo is loaded in the iframe.

## What NOT to Include

- No real API calls or data fetching
- No server-side logic
- No build steps or dependencies
- No complex state management
- No responsive design (demos are viewed in the showcase iframe at desktop width)
