# Art Generation Pipeline Harness

You are running the pixel art generation pipeline for the Mini Me iOS app.
Art request: **$ARGUMENTS**

Follow this harness exactly. The pixel art aesthetic is the soul of this product.

---

## Step 1 — Identify the Asset

Parse the request to determine:
- **Asset ID**: e.g. `plant_succulent`, `rug_round`, `desk_gaming`
- **Asset type**: room item | avatar state | outfit overlay | room background
- **Slot type**: which `SlotType` case this item occupies (from App/Models/RoomSlot.swift)
- **Existing entry**: check `ItemCatalog` in `App/Models/ShopItem.swift` — does this item already have a spriteName?

---

## Step 2 — Generate the Exact Prompt

Output the prompt block below, filled in for this specific asset.
The user will paste this into their image generation tool.

```
STYLE (use exactly):
16-bit pixel art, isometric 3/4 view, transparent PNG background,
warm cozy palette only: cream #F5E6D3, sage green #5B8C5A, warm orange #E8985E,
soft gold #FFD54F, wood brown #8B6F47, dark outline #3D3D3D.
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

Interpret the results:
- **PASS** → proceed to Step 4
- **FAIL** on dimensions → ask user to re-export at correct size
- **FAIL** on color count (>20 colors) → the image has anti-aliasing or gradients; ask user to regenerate with stricter prompt
- **FAIL** on format** → convert with: `sips -s format png <file> --out <file>.png`
- **⚠️ alpha channel** → ask user to confirm transparent background was used

Do NOT inject an image that fails validation.

---

## Step 4 — Inject into Xcode Asset Catalog

If validation passes:

1. **Copy PNG** to `mini-me/Assets.xcassets/<asset-id>.imageset/`
   - Filename: `<asset-id>.png`

2. **Create Contents.json** in that imageset folder:
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

3. **Update ItemCatalog** in `App/Models/ShopItem.swift`:
   - Find the `ShopItem` entry for this asset ID
   - Set `spriteName: "<asset-id>"` to match the new asset

4. **Run syntax check** on ShopItem.swift:
```bash
swiftc -parse mini-me/App/Models/ShopItem.swift
```

---

## Step 5 — Report

State clearly:
- INJECTED: `<asset-id>` at `Assets.xcassets/<asset-id>.imageset/`
- ItemCatalog updated: YES / NO
- Validation result: PASS / FAIL
- Any manual steps remaining (e.g. adding to Xcode project file if needed)
