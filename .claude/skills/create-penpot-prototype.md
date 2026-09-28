---
name: create-penpot-prototype
description: Creates a Penpot prototype for a UI Kit component or screen, using the project's design tokens (palette/typography) as visual reference.
---

# Create Penpot Prototype

## Purpose

Generate a Penpot prototype that serves as a visual reference for a
component, screen template, or flow in UI Kit, before (or after) its
implementation in Godot.

## When to use

- Before implementing a new component/theme, to validate layout and color
  palette.
- After implementing it, to visually document how the component should
  behave across different states (hover/pressed/disabled/focus) or
  breakpoints (mobile/desktop).

## Steps

1. Read the Penpot tools overview (`high_level_overview`) before any call,
   if not already done in this session.
2. Confirm with the user which component/screen will be prototyped and in
   which Penpot file/board (new or existing).
3. Create the shapes/board in Penpot (`execute_code`) reflecting the
   component's layout and states.
4. Export the result (`export_shape`) when the user needs a visual artifact
   (image) for review outside Penpot.
5. Share the prototype's link/file with the user and summarize what was
   created.

## Standards

- Current default size: 1920x1080.
- Always prioritize responsiveness (16:9, 16:10).
- Design focused on desktop games, but which can be prototyped for web
  first.
- Buttons must be represented with background and text grouped into a
  single Penpot component — do not create the text and background as
  loose elements; the same applies if there are icons.

## Notes

- Do not invent color/typography tokens that don't exist in the project —
  use the ones already defined in `UIPalette`/`UITypography` (see
  resources in `addons/ui_kit/`).
- Keep the prototype simple: one board per component/screen, without
  interaction details that Penpot doesn't represent well (that's left for
  the implementation in Godot).
