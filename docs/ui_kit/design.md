# Design Palette

UI Kit's default token set — usable as-is via a `UIPalette` resource (see
[`api_design.md`](api_design.md), Phase 1), or replaced wholesale for a
project's own palette without touching any component code. A 10-step ramp
moving from cool, dark tones into warm, hot ones; useful for a sequential
scale (severity, intensity, progress) as well as general UI theming.

## Colors

| Name              | Hex (RGBA)  | Hex (RGB) | RGB               |
| ----------------- | ----------- | --------- | ----------------- |
| `ink-black`       | `#001219ff` | `#001219` | `rgb(0, 18, 25)`   |
| `dark-teal`       | `#005f73ff` | `#005f73` | `rgb(0, 95, 115)`  |
| `dark-cyan`       | `#0a9396ff` | `#0a9396` | `rgb(10, 147, 150)`|
| `pearl-aqua`      | `#94d2bdff` | `#94d2bd` | `rgb(148, 210, 189)` |
| `vanilla-custard` | `#e9d8a6ff` | `#e9d8a6` | `rgb(233, 216, 166)` |
| `golden-orange`   | `#ee9b00ff` | `#ee9b00` | `rgb(238, 155, 0)` |
| `burnt-caramel`   | `#ca6702ff` | `#ca6702` | `rgb(202, 103, 2)` |
| `rusty-spice`     | `#bb3e03ff` | `#bb3e03` | `rgb(187, 62, 3)`  |
| `oxidized-iron`   | `#ae2012ff` | `#ae2012` | `rgb(174, 32, 18)` |
| `brown-red`       | `#9b2226ff` | `#9b2226` | `rgb(155, 34, 38)` |

## Groups

- **Cool / dark** — `ink-black`, `dark-teal`, `dark-cyan`: base surfaces and
  backgrounds.
- **Neutral / light** — `pearl-aqua`, `vanilla-custard`: light surfaces, text
  or icons placed over the cool/dark group.
- **Warm / accent** — `golden-orange`, `burnt-caramel`, `rusty-spice`,
  `oxidized-iron`, `brown-red`: accents, calls to action, and a
  severity scale (info → warning → error → critical) in that order.

## Mapping to `UIPalette`

| `UIPalette` field | Color             |
| ----------------- | ----------------- |
| `background`      | `ink-black`       |
| `surface`         | `dark-teal`       |
| `text_primary`    | `vanilla-custard` |
| `text_secondary`  | `pearl-aqua`      |
| `accent`          | `golden-orange`   |
| `info`            | `dark-cyan`       |
| `warning`         | `burnt-caramel`   |
| `error`           | `rusty-spice`     |
| `critical`        | `brown-red`       |

## Accessibility notes

- The cool/dark group and warm/accent group have strong contrast against
  each other — pair text from one group with backgrounds from the other.
- Avoid pairing two colors from the same group for text/background (e.g.
  `golden-orange` text on `vanilla-custard`) — contrast is too low to read
  comfortably.
- Verify any final text/background pairing against WCAG AA (4.5:1 for body
  text, 3:1 for large text) before shipping — this matters more here than
  in a single-project palette, since every consumer of UI Kit inherits
  whatever the default gets wrong.
