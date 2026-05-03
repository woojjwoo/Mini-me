# Sprite Production Manifest — Mini Me v1 Widget-First

> **How to use this file:** Each numbered section below contains a self-contained prompt for one missing pixel art sprite. Over the next 4–6 days, paste **one prompt at a time** into the `/art` Claude Design pipeline. Save the resulting PNG with the exact filename listed in the section. Tick the sprite off in the checklist at the bottom of this file when it lands.
>
> **Do not batch.** One sprite → one `/art` invocation → review → next. The widget is the product, so quality bar is "lo-fi album cover."
>
> **Canonical reference for every sprite:** PixelJoint #131408 (http://pixeljoint.com/pixelart/131408.htm) — cozy isometric pixel diorama, warm lamps, lived-in feel.
>
> **Locked palette (11 colors, every sprite must use only these):**
>
> | Role | Hex |
> |---|---|
> | Cream (background / hoodie cuff / pillow / soles) | `#F5E6D3` |
> | Cream shadow | `#D4C0A0` |
> | Warm orange (hoodie / accent / blanket) | `#E8985E` |
> | Gold (highlight / lamp glow / coins) | `#FFD54F` |
> | Sage green (plants / accents) | `#5B8C5A` |
> | Wood light | `#C4874A` |
> | Wood mid | `#A06030` |
> | Wood deep | `#6B3A18` |
> | Fabric/linen mid | `#C9B89A` |
> | Outline (no pure black, ever) | `#2D2040` |
> | Cast shadow (60% pixel density, offset bottom-right) | `#2D2040` |
>
> **Universal rules for every prompt:**
> - Pixel art only. Nearest-neighbor scaling. **No anti-aliasing**. Hard pixel edges.
> - **Light source: top-left.** Highlights on top-left faces, deeper shadows on bottom-right.
> - **Outline: `#2D2040` only** — never pure `#000000`.
> - Transparent PNG background.
> - 8–12 colors used per asset, all drawn from the locked palette above.
> - Cozy, warm, lo-fi YouTube-stream-thumbnail vibe. If it feels clinical or corporate, it's wrong.

---

## Mini Me Avatar — proportions reference (applies to prompts 1–5)

All character poses must match the existing `minime_idle.png` reference:

- **Canvas:** 192×320 px, transparent PNG
- **Anchor:** bottom-center (feet plant on the bottom edge of canvas, centered horizontally)
- **Style:** chibi proportions — head is roughly **70×76 px** (large relative to body), body is short and stout
- **Hoodie:** warm orange `#E8985E` body, cream `#F5E6D3` cuffs and hood interior
- **Pants:** dark warm-purple/outline-tone `#2D2040`
- **Sneakers:** dark uppers with cream `#F5E6D3` soles
- **Skin tone:** neutral warm tone (use cream-shadow `#D4C0A0` mid + outline for shading; renderer can recolor for Light/Warm/Dark variants — leave skin as the "Warm Tone" default)
- **Face:** small dot eyes, soft neutral-friendly smile, subtle warm-orange `#E8985E` cheek tint (1–2 pixels each side)
- **Outline:** `#2D2040`, 1 pixel thick on all silhouettes

---

# 1. `minime_working.png` — sitting at desk, typing

**Filename:** `minime_working.png`
**Dimensions:** 192×320 px transparent PNG
**Anchor:** bottom-center
**Activity mapping:** drives `BlockCategory.work` and `BlockCategory.creative` widget poses.

**Description:** Mini Me seated on a small wooden chair at a desk, hands on a small laptop or keyboard, slightly hunched forward in focus. Soft warm lamp glow on hair from top-left.

**Prompt to paste into `/art`:**

```
Pixel art chibi character sprite, 192×320 transparent PNG, bottom-center anchor.

CHARACTER: A small cozy chibi avatar called "Mini Me," seated at a desk and typing on a laptop. Pose: facing 3/4 toward viewer, body angled slightly left, both forearms resting forward on the desk surface, fingers on laptop keys. Slight forward lean of upper body, head tilted ~10° down toward screen. A small warm-orange highlight in the eyes (focused look). Mouth: small soft neutral-friendly smile. Subtle warm-orange cheek tint, 1–2 pixels each side.

PROPORTIONS (must match minime_idle.png exactly):
- Head ~70×76 px, large relative to body (chibi style)
- Short stout torso
- Hoodie: warm orange #E8985E body, cream #F5E6D3 cuffs and hood interior
- Pants: dark warm-purple #2D2040
- Sneakers: dark upper, cream #F5E6D3 soles
- Skin: warm tone (cream-shadow #D4C0A0 mid, outline #2D2040)
- Face: small dot eyes, soft smile, cheek tint

FURNITURE INCLUDED IN SPRITE (small, supporting the pose):
- Simple wooden desk surface across lower third of canvas, wood-light #C4874A top face, wood-mid #A06030 side, wood-deep #6B3A18 underside
- Small chair back visible behind/beside character
- Small laptop on desk: cream #F5E6D3 base, dark #2D2040 screen, faint gold #FFD54F glow on character's face from screen

PALETTE (LOCKED, 11 colors, no others):
#F5E6D3 cream, #D4C0A0 cream-shadow, #E8985E warm orange, #FFD54F gold,
#5B8C5A sage, #C4874A wood-light, #A06030 wood-mid, #6B3A18 wood-deep,
#C9B89A linen-mid, #2D2040 outline / dark, plus that #2D2040 at ~60% density for cast shadow.

LIGHTING: top-left light source. Top-left planes lighter, bottom-right planes darker. Soft cast shadow under desk and chair, offset bottom-right, #2D2040 at ~60% pixel density.

STYLE: Pixel art, nearest-neighbor, NO anti-aliasing, hard pixel edges. Outline #2D2040 only — never pure black. Cozy lo-fi diorama feel; reference PixelJoint #131408. Transparent PNG background.

OUTPUT: 192×320 PNG, transparent, character feet/desk base aligned to bottom-center of canvas.
```

---

# 2. `minime_exercising.png` — mid jumping-jack or yoga pose

**Filename:** `minime_exercising.png`
**Dimensions:** 192×320 px transparent PNG
**Anchor:** bottom-center
**Activity mapping:** drives `BlockCategory.exercise` widget poses.

**Description:** Mini Me mid-motion in a jumping jack: arms raised in a wide V overhead, legs spread, slight upward bounce. Active, cheerful, non-strenuous.

**Prompt to paste into `/art`:**

```
Pixel art chibi character sprite, 192×320 transparent PNG, bottom-center anchor.

CHARACTER: Mini Me mid jumping-jack. Pose: facing viewer straight-on, both arms raised overhead in a wide V, legs spread shoulder-width apart with toes lightly off the ground (tiny gap of 2–3 px between sneaker soles and the bottom edge to imply hop). Body squashed slightly (1–2 px shorter than idle) to convey upward motion. Mouth: open soft smile, energetic but friendly. Subtle warm-orange cheek tint. Eyes happy/closed-curve or simple dots.

PROPORTIONS (must match minime_idle.png exactly):
- Head ~70×76 px, chibi
- Hoodie: warm orange #E8985E body, cream #F5E6D3 cuffs visible at wrists raised overhead
- Pants: dark warm-purple #2D2040
- Sneakers: dark upper, cream #F5E6D3 soles
- Skin: warm tone, cream-shadow #D4C0A0 mid

EXTRAS:
- Two tiny motion lines (1–2 px each) on either side of the body in cream #F5E6D3 to imply movement — keep minimal, do not clutter
- Small cast shadow ellipse on the ground directly below the feet, #2D2040 at ~60% pixel density, slightly squashed to imply character is airborne

PALETTE (LOCKED, 11 colors):
#F5E6D3, #D4C0A0, #E8985E, #FFD54F, #5B8C5A, #C4874A, #A06030, #6B3A18,
#C9B89A, #2D2040, plus #2D2040 at 60% density for shadow.

LIGHTING: top-left light source. Highlights on top-left of head, hoodie shoulders, and raised arms. Bottom-right of body in slightly deeper orange.

STYLE: Pixel art, nearest-neighbor, NO anti-aliasing. Outline #2D2040 only. Cozy lo-fi feel, reference PixelJoint #131408. Transparent PNG.

OUTPUT: 192×320 PNG, transparent, cast-shadow ellipse on bottom-center of canvas.
```

---

# 3. `minime_eating.png` — sitting at table, fork raised

**Filename:** `minime_eating.png`
**Dimensions:** 192×320 px transparent PNG
**Anchor:** bottom-center
**Activity mapping:** drives `BlockCategory.nutrition` widget poses.

**Description:** Mini Me seated at a small table, plate in front, fork raised mid-bite. Calm, cozy mealtime moment.

**Prompt to paste into `/art`:**

```
Pixel art chibi character sprite, 192×320 transparent PNG, bottom-center anchor.

CHARACTER: Mini Me seated, eating. Pose: facing 3/4 toward viewer, body upright, one hand (the closer-to-viewer arm) raised holding a tiny fork ~halfway between plate and mouth. The other hand resting on the table edge. Mouth slightly open, anticipating bite. Warm-orange cheek tint. Eyes happy soft.

PROPORTIONS (must match minime_idle.png exactly):
- Head ~70×76 px, chibi
- Hoodie: warm orange #E8985E body, cream #F5E6D3 cuffs
- Pants: dark warm-purple #2D2040 (visible only below table line)
- Sneakers: dark upper, cream #F5E6D3 soles, planted on floor below table
- Skin: warm tone

FURNITURE INCLUDED IN SPRITE:
- Small wooden table across lower third: wood-light #C4874A top, wood-mid #A06030 side, wood-deep #6B3A18 leg shadow
- Plate: cream #F5E6D3 disc with cream-shadow #D4C0A0 rim
- A small warm-orange #E8985E food shape (e.g. a single dumpling/onigiri silhouette) and one sage green #5B8C5A garnish dot on the plate
- Tiny fork: gold #FFD54F handle, cream #F5E6D3 tines, in raised hand
- Optional small cup: cream with sage rim, beside plate

PALETTE (LOCKED, 11 colors):
#F5E6D3, #D4C0A0, #E8985E, #FFD54F, #5B8C5A, #C4874A, #A06030, #6B3A18,
#C9B89A, #2D2040, plus 60%-density #2D2040 cast shadow.

LIGHTING: top-left source. Plate top-left bright, table edge highlights upper edge, cast shadow under table to bottom-right.

STYLE: Pixel art, nearest-neighbor, NO anti-aliasing. Outline #2D2040 only. Cozy diorama vibe, reference PixelJoint #131408. Transparent PNG.

OUTPUT: 192×320 PNG, transparent, table base aligned to bottom-center.
```

---

# 4. `minime_reading.png` — sitting cross-legged with book

**Filename:** `minime_reading.png`
**Dimensions:** 192×320 px transparent PNG
**Anchor:** bottom-center
**Activity mapping:** drives `BlockCategory.learning` and `BlockCategory.creative` (when reading) widget poses.

**Description:** Mini Me sitting cross-legged on the floor, open book in lap, head tilted gently down toward pages. Calm, focused, cozy.

**Prompt to paste into `/art`:**

```
Pixel art chibi character sprite, 192×320 transparent PNG, bottom-center anchor.

CHARACTER: Mini Me seated cross-legged on the floor, reading. Pose: facing slightly 3/4 toward viewer, legs crossed in front (visible cream sneaker soles and dark hoodie pants tucked underneath), an open book held in both hands resting in the lap. Head tilted ~15° down toward the pages. Soft neutral smile, eyes calm half-closed reading expression. Subtle warm-orange cheek tint.

PROPORTIONS (must match minime_idle.png exactly):
- Head ~70×76 px, chibi
- Hoodie: warm orange #E8985E body, cream #F5E6D3 cuffs visible holding book
- Pants: dark warm-purple #2D2040, visible tucked under crossed legs
- Sneakers: dark upper, cream #F5E6D3 soles, soles facing viewer in cross-legged pose
- Skin: warm tone

EXTRAS:
- Open book: cover wood-mid #A06030 spine, cream #F5E6D3 pages, two thin sage #5B8C5A horizontal lines for text
- Optional: a tiny gold #FFD54F bookmark ribbon dangling from the spine
- Small cast shadow ellipse beneath seated body, #2D2040 at 60% density, offset bottom-right

PALETTE (LOCKED, 11 colors):
#F5E6D3, #D4C0A0, #E8985E, #FFD54F, #5B8C5A, #C4874A, #A06030, #6B3A18,
#C9B89A, #2D2040, plus 60%-density #2D2040 shadow.

LIGHTING: top-left source. Book pages top-left edge brightest, hood casts soft shadow on forehead pixels. Hoodie left shoulder lighter, right shoulder slightly darker.

STYLE: Pixel art, nearest-neighbor, NO anti-aliasing. Outline #2D2040 only. Cozy lo-fi reference PixelJoint #131408. Transparent PNG.

OUTPUT: 192×320 PNG, transparent, seated base aligned to bottom-center.
```

---

# 5. `minime_socializing.png` — standing, gesturing in conversation

**Filename:** `minime_socializing.png`
**Dimensions:** 192×320 px transparent PNG
**Anchor:** bottom-center
**Activity mapping:** drives `BlockCategory.social` widget poses (and is the slot where friends' mini-mes will composite in v1.5).

**Description:** Mini Me standing, one hand raised in a relaxed open-palm conversational gesture, mouth slightly open mid-sentence. Friendly, social.

**Prompt to paste into `/art`:**

```
Pixel art chibi character sprite, 192×320 transparent PNG, bottom-center anchor.

CHARACTER: Mini Me standing, mid-conversation. Pose: facing 3/4 toward viewer, weight on one leg with the other slightly forward (relaxed contrapposto). One arm raised to chest height with palm open, fingers loosely spread, in a casual "and then…" conversational gesture. Other arm hanging naturally at side. Mouth slightly open in a soft smile (talking). Eyes friendly, looking slightly off-camera at imaginary friend. Warm-orange cheek tint.

PROPORTIONS (must match minime_idle.png exactly):
- Head ~70×76 px, chibi
- Hoodie: warm orange #E8985E body, cream #F5E6D3 cuffs visible at both wrists
- Pants: dark warm-purple #2D2040
- Sneakers: dark upper, cream #F5E6D3 soles, planted on ground
- Skin: warm tone

EXTRAS:
- Tiny optional speech-bubble dot trio (3 small cream #F5E6D3 pixels) above raised hand to imply talking — keep subtle, do not crowd silhouette
- Small cast shadow ellipse beneath feet, #2D2040 at 60% density, offset bottom-right

PALETTE (LOCKED, 11 colors):
#F5E6D3, #D4C0A0, #E8985E, #FFD54F, #5B8C5A, #C4874A, #A06030, #6B3A18,
#C9B89A, #2D2040, plus 60%-density #2D2040 shadow.

LIGHTING: top-left source. Top-left of head and raised arm brightest. Hoodie right side slightly deeper orange.

STYLE: Pixel art, nearest-neighbor, NO anti-aliasing. Outline #2D2040 only. Cozy lo-fi reference PixelJoint #131408. Transparent PNG.

OUTPUT: 192×320 PNG, transparent, feet aligned to bottom-center.
```

---

## Scene Backgrounds — MODERN APARTMENT VISUAL SYSTEM (applies to prompts 6–9)

> Every scene background shares this shell. Copy the SHARED SYSTEM block into every ChatGPT prompt, then append the room-specific PROPS block below it.

```
SHARED SYSTEM — MODERN APARTMENT VISUAL SYSTEM
Canvas: 246×246 px transparent PNG, bottom-center anchor, isometric 2:1 projection.
Character slot: bottom-center floor area MUST stay fully clear for 192×320 sprite compositing.

FEEL: Cozy modern apartment. Soft lo-fi evening atmosphere. Clean silhouettes. Restrained detail.
Contemporary furniture — NOT rustic. More breathing room and negative space. Every room should feel
like a neighboring corner of the same apartment.

ARCHITECTURE (identical across all scenes):
- L-shaped floor, two back walls receding up-left and up-right
- Same wall height, same corner angle, same trim thickness across the set
- Lavender hex-frame perimeter: #9B7EC8

WALLS:
- Primary wall: #F5E6D3 | Soft shade: #C9B89A | Lavender trim: #9B7EC8
- Back-left wall slightly brighter than back-right
- Keep walls quiet and uncluttered

FLOOR:
- Narrow-plank modern wood — #A06030 base, restrained #C4874A highlights, thin #6B3A18 joints
- Avoid heavy rustic contrast — floor should feel flatter and cleaner

PALETTE (LOCKED — 11 colors + lavender trim, no others):
#F5E6D3 cream | #D4C0A0 cream-shadow | #E8985E warm orange | #FFD54F gold
#5B8C5A sage | #C4874A wood-light | #A06030 wood-mid | #6B3A18 wood-deep
#C9B89A linen-mid | #2D2040 outline+shadow | #9B7EC8 lavender trim only

OUTLINES: #2D2040 only, 1 px, never pure black.

LIGHTING: top-left source. Warm ambient room light. Soft cast shadows offset bottom-right,
#2D2040 at ~60% pixel density. No dramatic spotlighting.

MATERIAL LANGUAGE: slim furniture legs, thin shelves, floating storage, rounded modern objects,
small plants/books/ceramics/soft textiles. Furniture feels lighter than rustic versions.

COMPOSITION: furniture only along back walls and corners. Center floor visually open.
No object intrudes into character slot. Balanced left/right density.

DETAIL DENSITY: 3–5 focal props per room. Avoid over-decorating. Readable at small size.

STYLE: Pixel art, nearest-neighbor, NO anti-aliasing, hard pixel edges. Cozy modern lo-fi diorama.
Visual tone: PixelJoint #131408. Transparent PNG.

OUTPUT: 246×246 PNG, transparent, floor anchored to bottom-center, center clear for compositing.
```

---

# 6. `room_study_empty.png` — slim desk, floating shelf, warm lamp, ceramic mug

**Filename:** `room_study_empty.png`
**Dimensions:** 246×246 px transparent PNG
**Anchor:** bottom-center
**Activity mapping:** `BlockCategory.work`, `learning`, `creative` → `RoomType.study`

**Description:** A modern apartment study corner. Slim-legged desk against the back-right wall with a small laptop and a ceramic mug, a floating shelf on the back-left wall with a few book spines and a small ceramic, a warm arc lamp in the back-left corner, and a small potted plant on the floor.

**Prompt to paste into ChatGPT:**

```
Pixel art isometric scene background, 246×246 transparent PNG.

[PASTE THE SHARED SYSTEM BLOCK HERE]

PROPS — STUDY CORNER (place against back walls and corners only, center floor clear):
- Slim-legged desk against back-right wall: thin legs in #2D2040, #C4874A desktop surface,
  #A06030 side edge. On top: small closed cream #F5E6D3 laptop, ceramic mug in #C9B89A
  with 2–3 #D4C0A0 steam pixels.
- Slim arc floor lamp in back-left corner: thin #2D2040 stem curving overhead,
  gold #FFD54F bulb with 1-pixel cream halo, soft warm tint on nearby surfaces.
- Floating wall shelf on back-left wall: thin #A06030 shelf, no visible brackets,
  3–4 book spines (#E8985E, #5B8C5A, #FFD54F, #F5E6D3) varied heights, one small
  cream #F5E6D3 ceramic object.
- Small potted plant on floor back-left corner: slim pot #C4874A + #A06030, sage #5B8C5A leaves.
- Minimal wooden chair with slim legs tucked toward desk (partially suggested, not blocking center).
```

---

# 7. `room_gym_empty.png` — yoga mat, slim dumbbell rack, tall mirror, plant

**Filename:** `room_gym_empty.png`
**Dimensions:** 246×246 px transparent PNG
**Anchor:** bottom-center
**Activity mapping:** `BlockCategory.exercise` → `RoomType.gym`

**Description:** A modern home-gym corner of the apartment. Sage yoga mat along the back-right wall, a slim minimal dumbbell rack in the corner, a tall frameless-style mirror on the back-left wall, and a large leafy plant. Clean, calm, not a commercial gym.

**Prompt to paste into ChatGPT:**

```
Pixel art isometric scene background, 246×246 transparent PNG.

[PASTE THE SHARED SYSTEM BLOCK HERE]

PROPS — HOME GYM CORNER (place against back walls and corners only, center floor clear):
- Sage #5B8C5A yoga mat rolled out along back-right wall edge (parallel to wall, NOT in
  center slot); thin #D4C0A0 stripe lines for texture.
- Slim minimal dumbbell rack in back-right corner: thin #2D2040 frame, two small dumbbells
  with #E8985E weight ends and #6B3A18 grip bars.
- Tall mirror on back-left wall: thin #A06030 frame or near-frameless, mirror surface
  #F5E6D3 with 1–2 diagonal #C9B89A highlight streaks (no character reflection).
- Large leafy plant on floor back-left corner: slim pot #C4874A + #A06030, generous
  #5B8C5A leaves.
- Optional: small folded #F5E6D3 towel on or near the rack.
```

---

# 8. `room_kitchen_empty.png` — slim counter, kettle, mini fridge, hanging utensils, herb

**Filename:** `room_kitchen_empty.png`
**Dimensions:** 246×246 px transparent PNG
**Anchor:** bottom-center
**Activity mapping:** `BlockCategory.nutrition` → `RoomType.kitchen`

**Description:** A modern apartment kitchen nook. Slim-profile counter along the back-right wall with a kettle and inset burners, a compact fridge in the back-left corner, a minimal utensil rail above the counter, and a small herb plant on the countertop.

**Prompt to paste into ChatGPT:**

```
Pixel art isometric scene background, 246×246 transparent PNG.

[PASTE THE SHARED SYSTEM BLOCK HERE]

PROPS — KITCHEN NOOK (place against back walls and corners only, center floor clear):
- Slim counter along back-right wall: thin profile, #C4874A countertop, #A06030 front panel,
  #6B3A18 base. Small inset stove: 2 dark #2D2040 burner circles with #D4C0A0 rings.
  One slim cabinet door in #F5E6D3 with gold #FFD54F handle.
- Kettle on counter: rounded #E8985E body, #FFD54F handle accent, 2–3 #D4C0A0 steam pixels.
- Compact fridge back-left corner: #F5E6D3 body, #D4C0A0 side, #FFD54F slim handle,
  one small #5B8C5A magnet dot.
- Minimal utensil rail on back wall above counter: thin #A06030 rod,
  2–3 hanging utensils (#5B8C5A spatula, #FFD54F ladle, #6B3A18 spoon).
- Small herb pot on counter: #C4874A + #A06030 pot, #5B8C5A leaf sprigs.
```

---

# 9. `room_coffeeshop_empty.png` — round café table, two slim chairs, pendant light, plant

**Filename:** `room_coffeeshop_empty.png`
**Dimensions:** 246×246 px transparent PNG
**Anchor:** bottom-center
**Activity mapping:** `BlockCategory.social` → `RoomType.coffeeShop`
**Note:** v1.5 will composite TWO mini-me sprites here during shared social blocks — leave enough floor space for two characters side by side near the table.

**Description:** A modern apartment café corner. A small round table mid-canvas with two slim chairs facing each other, a warm pendant bulb overhead, a tall plant in the back-left corner, and a small chalkboard menu on the back-right wall.

**Prompt to paste into ChatGPT:**

```
Pixel art isometric scene background, 246×246 transparent PNG.

[PASTE THE SHARED SYSTEM BLOCK HERE]

PROPS — CAFÉ CORNER (bottom 1/3 of canvas must stay clear for TWO character sprites):
- Small round café table placed mid-canvas (NOT near bottom edge): slim pedestal leg
  #2D2040, #C4874A round top, #A06030 pedestal, #6B3A18 base.
  On top: two small #F5E6D3 ceramic mugs, #D4C0A0 rims, 2px steam each.
- TWO slim chairs — one left of table, one right, both angled 3/4 inward:
  thin #2D2040 legs, #A06030 seat, #C4874A seat-top highlight.
- Pendant bulb light above table: thin #2D2040 cord from upper frame,
  #FFD54F bulb, 1px cream halo, faint #E8985E warm tint on tabletop below.
- Tall plant back-left corner: slim #C4874A + #A06030 pot, tall #5B8C5A leaves.
- Small chalkboard back-right wall: #2D2040 board, #A06030 slim frame,
  2–3 thin #F5E6D3 lines for menu text, optional #FFD54F dot accent.
```

---

## Production Checklist

Tick each sprite as it lands in `mini-me/Assets.xcassets/` (or wherever sprite assets live in the project) and is verified at runtime against the widget snapshot pipeline.

### Character Poses (192×320, transparent, bottom-center anchor)
- [x] 1. `minime_working.png` — sitting at desk, typing
- [x] 2. `minime_exercising.png` — mid jumping-jack
- [x] 3. `minime_eating.png` — sitting at table, fork raised
- [x] 4. `minime_reading.png` — sitting cross-legged with book
- [x] 5. `minime_socializing.png` — standing, gesturing in conversation

### Scene Backgrounds (246×246, transparent, bottom-center anchor)
- [ ] 6. `room_study_empty.png` — desk, chair, bookshelves, lamp, mug
- [ ] 7. `room_gym_empty.png` — yoga mat, dumbbells, mirror, plant
- [ ] 8. `room_kitchen_empty.png` — counter, stove, fridge, utensils
- [ ] 9. `room_coffeeshop_empty.png` — café table, two chairs, pendant light, plant

### Definition of Done (per sprite)
- [ ] File saved to the correct asset folder with the exact filename above
- [ ] Palette audit: only the 11 locked hex values appear in the PNG (sample with a color picker; no rogue blacks, blues, or anti-aliased pixels)
- [ ] Light source visibly top-left
- [ ] Bottom-center anchor verified — character feet / scene floor sit on the bottom edge, horizontally centered
- [ ] Compiled into a widget snapshot via `WidgetDataService` and visually inspected on a real iPhone home-screen widget
- [ ] Vibe test passed: "Does this feel like a lo-fi YouTube stream thumbnail?" — yes
