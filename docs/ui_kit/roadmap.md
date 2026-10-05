# Roadmap

Plan for building UI Kit: a UI kit for Godot you can drop into any new
project. It gives you themed components, ready-made menu screens, and
automatic keyboard/gamepad switching, so you don't rebuild your UI
from zero every time.

## How It Works

> UI Kit leans on what Godot already does and only fills the gaps.

The first goal is to reuse the same UIs across N projects, taking advantage of the main menu,
settings menu, level select screen, and automatic keyboard/gamepad visual indicator switching.
I will create the prototype frames in Penpot, and through the MCP connection you will replicate
them in the project.

### Acceptance Criteria
- [ ] Does it switch automatically from keyboard to gamepad?
- [ ] Does it recognize PlayStation and Xbox controllers?
- [ ] Does the screen flow work?
- [ ] Can I click a button and open another screen?
- [ ] Can I move the plugin to another project and keep working?
