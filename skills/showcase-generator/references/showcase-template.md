# Showcase Template Reference

This defines the design system and HTML structure for the Idea Lab showcase. The showcase-generator skill uses this as the reference when building the output HTML.

## CSS Variables

```css
:root {
  --bg: #FAFAF9;
  --white: #FFFFFF;
  --text: #1A1A1A;
  --text-secondary: #7A7A78;
  --text-tertiary: #A8A8A5;
  --border: #EBEBEA;
  --border-light: #F3F3F2;
  --accent: #E8553A;
  --accent-light: #FFF0ED;
  --accent-hover: #D44A31;
  --green: #2D9F6F;
  --green-light: #EDFAF3;
  --amber: #D4880F;
  --amber-light: #FFF8EB;
  --purple: #7C5CFC;
  --purple-light: #F3F0FF;
  --radius: 12px;
  --radius-sm: 8px;
  --radius-lg: 16px;
  --shadow-sm: 0 1px 3px rgba(0,0,0,0.04), 0 1px 2px rgba(0,0,0,0.03);
  --shadow: 0 2px 8px rgba(0,0,0,0.05), 0 1px 3px rgba(0,0,0,0.04);
  --shadow-lg: 0 8px 24px rgba(0,0,0,0.08), 0 2px 8px rgba(0,0,0,0.04);
  --transition: 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  --transition-spring: 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
}
```

## Typography

- **Font:** Inter from Google Fonts (`wght@300;400;500;600;700`)
- **Body:** 14px, -apple-system fallback
- **Headings:** font-weight 700, negative letter-spacing (-0.3px to -0.5px)
- **Labels:** 11px uppercase, letter-spacing 0.8px, text-tertiary color
- **Secondary text:** 12-13px, text-secondary color

## Layout Structure

```
┌─────────────────────────────────────────────────────────┐
│ ┌──────────┐  ┌──────────────────────────────────────┐  │
│ │ SIDEBAR  │  │           MAIN AREA                  │  │
│ │ 340px    │  │                                      │  │
│ │          │  │  • Idea detail view (default)         │  │
│ │ Header   │  │  • Demo iframe view                  │  │
│ │ ───────  │  │  • Empty state                       │  │
│ │ List     │  │                                      │  │
│ │  • idea  │  │                                      │  │
│ │  • idea  │  │                                      │  │
│ │  • idea  │  │                                      │  │
│ └──────────┘  └──────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

- Body: `display: flex; height: 100vh; overflow: hidden`
- Sidebar: `width: 340px; min-width: 340px; border-right: 1px solid var(--border)`
- Main: `flex: 1; overflow-y: auto; padding: 40px`

## Stage Badge Colors

| Stage | Background | Text Color | CSS Class |
|-------|-----------|------------|-----------|
| seedling | `var(--amber-light)` | `var(--amber)` | `.badge-amber` |
| exploring | `var(--amber-light)` | `var(--amber)` | `.badge-amber` |
| spec | `var(--purple-light)` | `var(--purple)` | `.badge-purple` |
| mock | `var(--purple-light)` | `var(--purple)` | `.badge-purple` |
| building | `var(--accent-light)` | `var(--accent)` | `.badge-accent` |
| launched | `var(--green-light)` | `var(--green)` | `.badge-green` |

## Component Styles

### Sidebar Header
```css
.sidebar-header {
  padding: 24px 20px 16px;
  border-bottom: 1px solid var(--border);
}
.sidebar-header h1 {
  font-size: 18px;
  font-weight: 700;
  letter-spacing: -0.3px;
  display: flex;
  align-items: center;
  gap: 8px;
}
/* Red dot accent before title */
.sidebar-header h1 .dot {
  width: 8px;
  height: 8px;
  background: var(--accent);
  border-radius: 50%;
}
```

### Idea List Item
```css
.idea-item {
  border-radius: var(--radius);
  cursor: pointer;
  transition: all var(--transition);
  margin-bottom: 2px;
  padding: 12px 14px;
  display: flex;
  align-items: flex-start;
  gap: 10px;
}
.idea-item:hover { background: var(--bg); }
.idea-item.active { background: var(--accent-light); }
.idea-item.active .idea-name { color: var(--accent); }
```

### Main Content Area
```css
.main {
  flex: 1;
  overflow-y: auto;
  padding: 40px;
  display: flex;
  justify-content: center;
}
.demo-container {
  max-width: 680px;
  width: 100%;
  animation: fadeUp 0.35s ease;
}
@keyframes fadeUp {
  from { opacity: 0; transform: translateY(12px); }
  to { opacity: 1; transform: translateY(0); }
}
```

### Buttons
```css
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  padding: 10px 18px;
  border-radius: var(--radius-sm);
  font-family: inherit;
  font-size: 13px;
  font-weight: 600;
  border: none;
  cursor: pointer;
  transition: all var(--transition);
}
.btn-primary { background: var(--text); color: var(--white); }
.btn-primary:hover { background: #333; transform: translateY(-1px); box-shadow: var(--shadow); }
.btn-accent { background: var(--accent); color: var(--white); }
.btn-accent:hover { background: var(--accent-hover); transform: translateY(-1px); }
.btn-outline { background: var(--white); color: var(--text); border: 1px solid var(--border); }
.btn-outline:hover { background: var(--bg); border-color: var(--text-tertiary); }
```

### Badge
```css
.badge {
  display: inline-flex;
  align-items: center;
  padding: 4px 10px;
  border-radius: 100px;
  font-size: 11px;
  font-weight: 600;
}
```

### Iframe Mode (for demos)
```css
.main.iframe-mode {
  padding: 0;
  overflow: hidden;
  position: relative;
}
.main.iframe-mode iframe {
  width: 100%;
  height: 100%;
  border: none;
}
.iframe-back-btn {
  position: absolute;
  top: 12px;
  left: 12px;
  z-index: 10;
  background: rgba(255,255,255,0.9);
  backdrop-filter: blur(8px);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  padding: 6px 12px;
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
}
```

### Flesh Out Button (Copy Command)
```css
.flesh-out-btn {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  background: var(--bg);
  border: 1px dashed var(--border);
  border-radius: var(--radius-sm);
  font-family: 'Inter', monospace;
  font-size: 13px;
  color: var(--text-secondary);
  cursor: pointer;
  transition: all var(--transition);
}
.flesh-out-btn:hover {
  background: var(--accent-light);
  border-color: var(--accent);
  color: var(--accent);
}
.flesh-out-btn .copy-icon { opacity: 0.5; transition: opacity var(--transition); }
.flesh-out-btn:hover .copy-icon { opacity: 1; }
```

### Toast Notification
```css
.toast {
  position: fixed;
  bottom: 24px;
  left: 50%;
  transform: translateX(-50%) translateY(100px);
  background: var(--text);
  color: var(--white);
  padding: 10px 20px;
  border-radius: var(--radius);
  font-size: 13px;
  font-weight: 500;
  opacity: 0;
  transition: all 0.3s ease;
  z-index: 100;
}
.toast.show {
  transform: translateX(-50%) translateY(0);
  opacity: 1;
}
```

## Scrollbar Styling
```css
::-webkit-scrollbar { width: 4px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb { background: var(--border); border-radius: 4px; }
```
