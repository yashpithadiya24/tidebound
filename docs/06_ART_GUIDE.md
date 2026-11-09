# 06 ART AND AUDIO GUIDE

Version 1.2 | 2026-11-06 | Owner: Chat 00
Used mainly in C03 (placeholders) and C06 (polish). A full art pass is parked (D-034). Keep one style across all assets.

---

## 1. Look

- **Style:** 2D cartoon, bright and clean, soft outlines, slight top-down angle (like a farm or town builder). Not realistic.
- **Mood:** Warm, cozy, friendly ocean world. Soft light. Small funny details.
- **Tile size:** 64 x 64 px. Buildings are multiples of 64 (a 2x2 building is 128 x 128 art, plus height above the footprint).
- **Outline:** 2 px, darker tone of the fill (no pure black).
- **Light:** From top-left. Soft shadow to bottom-right.

## 2. Palette (starter)

| Use | Color |
|---|---|
| Deep water | `#1d5d9b` |
| Shallow water | `#4fb3d9` |
| Foam | `#f4fbff` |
| Sand / shore | `#e8d9a8` |
| Mud | `#8a7455` |
| Reef | `#e07a6f` |
| Grass | `#7cc46a` |
| Wood | `#b9824f` |
| UI panel | `#fff6e0` |
| UI accent | `#ff9f43` |
| Text dark | `#3a2f2a` |

Lock a final palette of 24 colors in C17 and log it in `STATE.md`.

## 3. Tide visual language

| State | Look |
|---|---|
| LOW | Reef and mud exposed. Wet sand shine. Small crabs or birds on flats. |
| RISING | Foam line moves in. Water tint grows. |
| HIGH | Mud and reef covered. Water sparkles. Boats float high. |
| FALLING | Foam line moves out. Wet marks on sand. |

- Tide icons: LOW (sun over flat), RISING (up arrow wave), HIGH (full wave), FALLING (down arrow wave). Each icon also has a **color** and a **text label** (color-blind safe).
- Buildings that are paused show a small "zzz wave" icon, never red warning colors.
- Water is a shader or tinted overlay with a slow wave scroll. It must stay cheap on old phones.

## 4. Asset sizes

| Asset | Size |
|---|---|
| Terrain tile | 64 x 64 |
| Building 1x1 / 2x2 / 3x3 | 64 / 128 / 192 footprint, art may be taller |
| Boat (skiff / trader) | 96 x 96 / 160 x 160 |
| Crew portrait | 256 x 256 |
| Crew map sprite | 64 x 64 |
| Icons (resources, tide, UI) | 128 x 128 |
| Favicon and share image | Favicon 512 x 512, share image 1200 x 630 |

Import settings: PNG, filter linear, mipmaps off for 2D, pack into atlases in C17. Web: the player downloads all art before play, so keep atlases small and audio short.

## 5. Naming

```
assets/
  tiles/tile_<type>_<state>.png        tile_reef_dry.png
  buildings/bld_<id>_l<level>.png      bld_farm_l1.png
  boats/boat_<id>.png                  boat_skiff.png
  crew/crew_<id>_portrait.png          crew_captain_portrait.png
  icons/ico_<name>.png                 ico_tide_high.png
  ui/ui_<name>.png
  audio/sfx_<name>.ogg                 sfx_collect.ogg
  audio/mus_<name>.ogg
```
Names use `snake_case`, lowercase. The `<id>` matches the JSON id exactly.

## 6. AI art workflow

1. Make a **style sheet** first: 6 images (a tile set, a building, a boat, a crew face, an icon set, a UI panel). Pick the best. Save them in `assets/_style/`.
2. For every new asset, give the AI image tool the style sheet as reference and use the **prompt template** below. Keep the same tool and model for the whole game.
3. Generate on a plain background. Remove the background. Check size and edges.
4. Log each asset in `STATE.md` > ASSET LEDGER (tool, prompt, date, license note).

**Prompt template**
```
[subject], cute cartoon game asset, soft 2px outline, top-down slight angle,
bright warm colors, light from top-left, clean flat shading, simple shapes,
isolated on plain white background, no text, no shadow on background,
consistent with reference style sheet
```
**Negative:** `realistic, photo, 3d render, dark, gritty, text, watermark, blurry, busy background`

## 7. UI style

- Rounded panels, cream background, orange accent buttons, big readable text.
- One font family (rounded sans). Check the font license first (SIL OFL is fine).
- Buttons at least 48 dp. Main buttons in the bottom 40% of the screen.

## 8. Audio

| Type | List |
|---|---|
| SFX (v1) | tap, place, collect, build done, level up, boat horn, wave, error (soft), reward, crew skill |
| Music | 1 calm home loop, 1 sea map loop, event jingle |
| Rules | Short files. `.ogg`. Normalize volume. Provide mute and volume in Settings. Use free licensed or AI-licensed sound; log in ledger. |
