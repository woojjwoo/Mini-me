# Art Generation Pipeline Harness

You are running the pixel art generation pipeline for the Mini Me iOS app.
Art request: **$ARGUMENTS**

Follow this harness exactly. The pixel art aesthetic is the soul of this product.

---

## Step 0 — Classify the Request

First, parse `$ARGUMENTS` to determine which mode you're in:

### Mode A — Pivot sprite (character pose OR scene background)

Triggered when the request matches any of:
- Asset name starts with `minime_` and is one of: `working`, `exercising`, `eating`, `reading`, `socializing`, `idle`, `happy`, `sleeping` (e.g. `minime_working`, `inject minime_working ~/Downloads/foo.png`)
- Asset name starts with `room_` and ends with `_empty` (e.g. `room_study_empty`, `room_gym_empty`, etc.)

→ Skip Step 2 (don't generate a stale prompt). The full, palette-locked, dimension-correct prompt for this asset already exists in `mini-me/docs/SPRITE_PRODUCTION_MANIFEST.md`. Tell the user:

> "Open `mini-me/docs/SPRITE_PRODUCTION_MANIFEST.md` and paste the prompt for `<asset-id>` into your image generator. Save the resulting PNG, then re-run `/art inject <asset-id> <path-to-png>`."

If the request is `inject <asset-id> <path>`, jump to Step 3 (validate) → Step 4 (inject). Note: pivot sprites have **non-standard dimensions** (`minime_*` = 192×320; `room_*_empty` = 246×246). The validator already accepts these.

### Mode B — Furniture / room item

Triggered when the request is a furniture/decor asset ID (e.g. `plant_succulent`, `rug_round`, `desk_gaming`, `bed_cozy`).

→ Continue to Step 1 (the legacy 64×64 flow below).

### Mode C — Inject only (any asset)

If the request literally starts with `inject ` followed by an asset id and a file path, jump straight to Step 3 (validate) then Step 4 (inject) using that path. Skip Step 1 and Step 2.

---

## Step 1 — Identify the Asset (Mode B only)

Parse the request to determine:
- **Asset ID**: e.g. `plant_succulent`, `rug_round`, `desk_gaming`
- **Asset type**: room item | avatar state | outfit overlay | room background
- **Slot type**: which `SlotType` case this item occupies (from App/Models/RoomSlot.swift)
- **Existing entry**: check `ItemCatalog` in `App/Models/ShopItem.swift` — does this item already have a spriteName?

---

## Step 2 — Generate the Exact Prompt (Mode B only)

Output the prompt block below, filled in for this specific asset.
The user will paste this into their image generation tool.

```
STYLE (use exactly):
16-bit pixel art, isometric 3/4 view, transparent PNG background,
warm cozy palette only: cream #F5E6D3, sage green #5B8C5A, warm orange #E8985E,
soft gold #FFD54F, wood brown #8B6F47, dark outline #2D2040.
Exact canvas: 64×64 pixels. Crisp nearest-neighbor scaling.
Absolutely NO anti-aliasing. NO gradients. NO blur.
Light source strictly from TOP-LEFT. Hard pixel shadows only.
Maximum 12 colors total in the image.
Game asset sprite. Must look handcrafted, cozy, lo-fi.

ITEM:
<describe the specific furniture/item with pixel art language>
Isometric angle, viewed from slightly above and to the right.
Scale: fits within a 32×32 visible area at the center of the 64×64 canvas.
Transparent background around the item.

MOOD: Cozy, warm, like a lo-fi YouTube stream thumbnail.
REFERENCE STYLE: Stardew Valley interior items, lo-fi album cover pixel art.
```

Remind the user: generate at 64×64, save as PNG with alpha transparency.

---

## Step 3 — Validate the Generated Image

Once the user provides the file path, run:
```bash
bash mini-me/scripts/validate-art.sh <path-to-image.png>
```

The validator now accepts:
- Furniture: 32×32, 64×64, 128×128
- Character poses: 192×320
- Scene backgrounds: 246×246

Interpret the results:
- **PASS** → proceed to Step 4
- **FAIL** on dimensions → ask user to re-export at correct size
- **FAIL** on color count (>20 colors) → the image has anti-aliasing or gradients; ask user to regenerate with stricter prompt
- **FAIL** on format → convert with: `sips -s format png <file> --out <file>.png`
- **⚠️ alpha channel** → ask user to confirm transparent background was used

Do NOT inject an image that fails validation.

---

## Step 4 — Inject into Xcode Asset Catalog

If validation passes:

1. **Copy PNG** to `mini-me/Assets.xcassets/<asset-id>.imageset/`
   - Filename: `<asset-id>.png`
   - Create the imageset directory if it doesn't exist

2. **Create or overwrite Contents.json** in that imageset folder:
```json
{
  "images": [
    {
      "filename": "<asset-id>.png",
      "idiom": "universal",
      "scale": "1x"
    }
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
```

3. **Catalog wiring (Mode B only)**: Update `ItemCatalog` in `App/Models/ShopItem.swift`:
   - Find the `ShopItem` entry for this asset ID
   - Set `spriteName: "<asset-id>"` to match the new asset
   - **Mode A skips this step** — character poses are referenced by the `textureNameForActivity()` helper in `App/Features/Room/RoomScene.swift` (which already tries the new names first), and scenes are looked up by `RoomScene.setupRoom()`'s background candidate list. Both fall back gracefully, so no code edit is needed when a Mode A sprite lands.

4. **Run syntax check** (Mode B only):
```bash
swiftc -parse mini-me/App/Models/ShopItem.swift
```

5. **Mark the manifest checkbox (Mode A only):** Open `mini-me/docs/SPRITE_PRODUCTION_MANIFEST.md`, find the production checklist at the bottom, and tick the entry for this asset id.

---

## Step 5 — Report

State clearly:
- INJECTED: `<asset-id>` at `Assets.xcassets/<asset-id>.imageset/`
- ItemCatalog updated (Mode B): YES / NO / N/A
- Manifest checkbox ticked (Mode A): YES / NO / N/A
- Validation result: PASS / FAIL
- Any manual steps remaining (e.g. adding to Xcode project file if the imageset is new — `git status` will show it untracked; remind user to drag it into the Xcode project navigator OR use `xcodeproj` ruby gem to script it)
