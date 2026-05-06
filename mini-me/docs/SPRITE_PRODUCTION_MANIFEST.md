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

## Animation Frame Variants — Widget Cycling (f1 / f2 / f3)

> **Why these exist:** The widget timeline cycles three PNG files (`_f1`, `_f2`, `_f3`) at 1.5-second intervals per block. iOS delivers each entry on schedule, producing the appearance of continuous motion. Each frame must be a **subtle pixel delta** from the base pose — enough to read as motion at widget scale (~80 pt), not so extreme it looks like a different character.
>
> **Naming convention:** `minime_<activity>_f1.png`, `_f2.png`, `_f3.png` — saved into `Assets.xcassets/` alongside the base sprite. The bakery falls back to the base (un-suffixed) PNG when frame variants don't exist yet, so you can ship frames as art is ready without breaking anything.
>
> **Loop logic:** f1 → f2 → f3 → f1. Frame f1 should be the same pose as (or closest to) the base sprite so the transition is smooth if the widget ever shows the base and then starts the cycle.
>
> **Dimensions and palette:** identical to the base sprite for each activity (192×320, same 11-color locked palette, same anchor). The ONLY thing that changes between frames is the animated element — fingers, arm, fork, etc.

---

# 10. `minime_working_f1/f2/f3.png` — typing animation (3 frames)

**Base reference:** `minime_working.png` (seated at desk, hands on laptop)
**Animation:** Screen text grows + cursor blinks across frames. The laptop display shows a line of text building up — this reads clearly at widget scale even when character hands are too small to show individual keystrokes. Arms also lift and drop slightly to reinforce typing motion.

> **Why screen text instead of just hand movement:** At ~80 pt widget size, a 2–3 px hand shift is sub-pixel and invisible. The laptop screen is ~12–14 px wide — text appearing on it is the largest readable motion signal in the frame.

### Frame 1 — `minime_working_f1.png` (screen: empty / cursor only)

Both arms resting on desk, hands on keys. Laptop screen: dark `#2D2040` background, faint gold `#FFD54F` cursor block (2×3 px) at the left edge of a text line — like a terminal waiting. Screen emits a subtle gold glow upward onto character's chin. This is the "about to type" frame.

**Prompt:**
```
Pixel art chibi character animation frame, 192×320 transparent PNG.
BASE: minime_working.png — seated at desk, 3/4 view, both forearms on desk, hands on laptop keys.
FRAME 1 (cursor ready): Both arms resting flat on desk, hands on keyboard. Laptop screen:
dark #2D2040 background, one small gold #FFD54F cursor block (2×3 px) sitting at the far left
of a text line on the screen — blinking ready position, no text yet. Screen casts a faint
#FFD54F warm glow on the underside of character's chin and nose (1–2 px upward gradient).
Mouth: focused closed soft smile. Eyes: small warm-orange #E8985E highlight dot (screen glow).
Everything else (desk, chair geometry, proportions) identical to base.
PALETTE LOCKED: #F5E6D3 #D4C0A0 #E8985E #FFD54F #5B8C5A #C4874A #A06030 #6B3A18 #C9B89A #2D2040
STYLE: Pixel art, nearest-neighbor, NO anti-aliasing. Transparent PNG.
OUTPUT: 192×320 PNG.
```

### Frame 2 — `minime_working_f2.png` (screen: half a line typed, right arm up)

Right forearm lifted 4–5 px off desk (visible arm raise — the wrist pops up clearly above the keyboard edge). Laptop screen: a short cream `#F5E6D3` pixel row — roughly 6 px wide — has appeared to the left of the cursor, representing half a line of typed text. Cursor has moved 6 px right. Screen glow slightly brighter. Head tilts 2–3 px further down toward screen.

**Prompt:**
```
Pixel art chibi character animation frame, 192×320 transparent PNG.
BASE: minime_working.png — seated at desk, 3/4 view, both forearms on desk.
FRAME 2 (typing mid-line): Right forearm (closer to viewer) lifted 4–5 px above desk surface —
wrist clearly above keyboard edge, fingers curled mid-keystroke. Left arm remains resting flat.
Laptop screen: a 6-px-wide row of cream #F5E6D3 pixels at the left of a text line (typed text),
with a gold #FFD54F cursor block 6 px further right (cursor advanced). Screen glow #FFD54F
slightly brighter on chin and nose — 2–3 px upward tint. Head tilted 2–3 px more toward screen
than frame 1. Eyes: warm-orange #E8985E screen-glow dot slightly larger.
PALETTE LOCKED: #F5E6D3 #D4C0A0 #E8985E #FFD54F #5B8C5A #C4874A #A06030 #6B3A18 #C9B89A #2D2040
STYLE: Pixel art, nearest-neighbor, NO anti-aliasing. Transparent PNG.
OUTPUT: 192×320 PNG.
```

### Frame 3 — `minime_working_f3.png` (screen: full line, left arm up, cursor wraps)

Left forearm lifted 4–5 px (mirroring frame 2 but opposite arm — alternating keystroke). Laptop screen: the text row now spans the full width of the screen (~12 px of cream pixels). Cursor has wrapped to a new line below (gold block at far left, second row). This "line finished → new line" moment reads as a satisfying typing beat. Head returns to frame 1 angle.

**Prompt:**
```
Pixel art chibi character animation frame, 192×320 transparent PNG.
BASE: minime_working.png — seated at desk, 3/4 view, both forearms on desk.
FRAME 3 (line complete): Left forearm (farther from viewer) lifted 4–5 px above desk surface —
wrist above keyboard edge, fingers curled. Right arm resting flat. Laptop screen: top text row
is now full — cream #F5E6D3 pixels spanning the full screen width (~12 px). A gold #FFD54F
cursor block sits at the far LEFT of a new (second) text line below — cursor has wrapped.
Screen glow same as frame 1 (not as bright as frame 2). Head angle back to frame 1 tilt
(relaxed). Eyes normal soft glow dot. Mouth: same focused closed smile.
PALETTE LOCKED: #F5E6D3 #D4C0A0 #E8985E #FFD54F #5B8C5A #C4874A #A06030 #6B3A18 #C9B89A #2D2040
STYLE: Pixel art, nearest-neighbor, NO anti-aliasing. Transparent PNG.
OUTPUT: 192×320 PNG.
```

---

# 11. `minime_exercising_f1/f2/f3.png` — jumping-jack animation (3 frames)

**Base reference:** `minime_exercising.png` (arms in wide V overhead, legs spread, feet barely airborne)
**Animation:** Bounce cycle — arms and legs move through the arc of a jumping jack.

### Frame 1 — `minime_exercising_f1.png` (mid-air peak, same as base)

Arms fully raised in V overhead, legs spread, feet 2–3 px off ground — identical to base. This is the apex.

**Prompt:**
```
Pixel art chibi character animation frame, 192×320 transparent PNG.
BASE: minime_exercising.png — mid jumping-jack, arms in wide V overhead, legs spread,
feet 2–3 px off ground.
FRAME 1 (apex): Identical to base pose — arms fully raised V overhead, legs spread shoulder-width,
tiny gap between sneaker soles and ground edge. Cast shadow ellipse at 60% density below.
Output must closely match minime_exercising.png.
PALETTE LOCKED: #F5E6D3 #D4C0A0 #E8985E #FFD54F #5B8C5A #C4874A #A06030 #6B3A18 #C9B89A #2D2040
STYLE: Pixel art, nearest-neighbor, NO anti-aliasing. Transparent PNG.
OUTPUT: 192×320 PNG.
```

### Frame 2 — `minime_exercising_f2.png` (descent — arms mid-lowering)

Arms now at shoulder height (roughly 45° from apex), elbows slightly bent, palms facing down. Legs partially closing — feet 4–5 px apart instead of spread. Body dropped 2 px toward ground (feet closer to bottom edge, shadow ellipse slightly wider/darker to imply landing imminent). Mouth transitions from open smile to a softer shape.

**Prompt:**
```
Pixel art chibi character animation frame, 192×320 transparent PNG.
BASE: minime_exercising.png — mid jumping-jack, arms in wide V overhead, legs spread.
FRAME 2 (descent): Arms now lowering — hands at shoulder height (~45° below apex), elbows
slightly bent, palms angled downward. Legs partially closing — feet 4–5 px apart (not fully
spread). Body 2 px lower overall (feet closer to bottom canvas edge). Cast shadow ellipse
slightly wider and darker (#2D2040 at ~70% density) to suggest landing approach. Mouth smaller
soft closed smile. Same motion lines at sides (slightly less prominent).
PALETTE LOCKED: #F5E6D3 #D4C0A0 #E8985E #FFD54F #5B8C5A #C4874A #A06030 #6B3A18 #C9B89A #2D2040
STYLE: Pixel art, nearest-neighbor, NO anti-aliasing. Transparent PNG.
OUTPUT: 192×320 PNG.
```

### Frame 3 — `minime_exercising_f3.png` (push-off — arms mid-rising from sides)

Arms at roughly 45° rising from body sides (not yet to shoulder height). Legs together, feet flat on ground. Body slightly squashed vertically (1–2 px shorter than base — compression of push-off). Shadow ellipse full-width, boldest (landing moment, pre-launch). This transitional frame creates the illusion of a bounce when followed by f1.

**Prompt:**
```
Pixel art chibi character animation frame, 192×320 transparent PNG.
BASE: minime_exercising.png — mid jumping-jack, arms in wide V overhead.
FRAME 3 (push-off): Arms low, rising from body sides — hands at roughly 45° upward from
hanging position, elbows slightly bent, palms facing up (ascending). Legs fully together,
feet flat on ground (no gap at bottom edge). Body 1–2 px squashed vertically (compression
at moment of jump launch). Cast shadow ellipse widest and most opaque (~75% density),
centered under feet. Eyes: happy closed-curve (effort/glee). No motion lines yet (pre-launch).
PALETTE LOCKED: #F5E6D3 #D4C0A0 #E8985E #FFD54F #5B8C5A #C4874A #A06030 #6B3A18 #C9B89A #2D2040
STYLE: Pixel art, nearest-neighbor, NO anti-aliasing. Transparent PNG.
OUTPUT: 192×320 PNG.
```

---

# 12. `minime_eating_f1/f2/f3.png` — fork-to-mouth animation (3 frames)

**Base reference:** `minime_eating.png` (seated at table, fork raised mid-way between plate and mouth)
**Animation:** Fork arc — traces from plate up to mouth and back down.

### Frame 1 — `minime_eating_f1.png` (fork low, over plate)

Fork hand in the low position — tip of fork just above the plate, forearm nearly parallel to table surface. Same pose as the start of a bite, mouth closed neutral-friendly smile. Identical to base or only 1–2 px lower.

**Prompt:**
```
Pixel art chibi character animation frame, 192×320 transparent PNG.
BASE: minime_eating.png — seated at table, 3/4 view, one hand raising fork.
FRAME 1 (fork low): Fork hand in lowest position — forearm nearly parallel to table, fork tip
hovering just 2–3 px above the plate (about to scoop). Mouth: closed soft smile. Other hand
resting flat on table edge. Same table, plate, food dot, cup geometry as base.
PALETTE LOCKED: #F5E6D3 #D4C0A0 #E8985E #FFD54F #5B8C5A #C4874A #A06030 #6B3A18 #C9B89A #2D2040
STYLE: Pixel art, nearest-neighbor, NO anti-aliasing. Transparent PNG.
OUTPUT: 192×320 PNG.
```

### Frame 2 — `minime_eating_f2.png` (fork mid-rise, mouth opening)

Fork raised to the mid-point (identical to or very close to the base sprite). Mouth slightly open in anticipation. This matches the base `minime_eating.png` pose closely — can reuse base as f2 if art budget is tight.

**Prompt:**
```
Pixel art chibi character animation frame, 192×320 transparent PNG.
BASE: minime_eating.png — seated at table, 3/4 view, fork raised halfway between plate and mouth.
FRAME 2 (fork mid): This is essentially the base pose. Fork raised to mid-height between plate
and mouth, elbow at natural angle. Mouth slightly open (anticipating bite). Eyes soft happy.
Output should closely match minime_eating.png — same table, plate, fork geometry.
PALETTE LOCKED: #F5E6D3 #D4C0A0 #E8985E #FFD54F #5B8C5A #C4874A #A06030 #6B3A18 #C9B89A #2D2040
STYLE: Pixel art, nearest-neighbor, NO anti-aliasing. Transparent PNG.
OUTPUT: 192×320 PNG.
```

### Frame 3 — `minime_eating_f3.png` (fork at mouth, eating expression)

Fork tip at mouth level (forearm raised higher, fork nearly vertical). Mouth closed around fork (small "o" or pursed smile — eating). Eyes closed-curved in a happy "mmm" expression. One tiny warm-orange cheek tint pixel slightly larger/brighter. Fork food dot (the small orange item from f1) now absent from plate (it's been eaten), replaced by a tiny cream dot at mouth corner.

**Prompt:**
```
Pixel art chibi character animation frame, 192×320 transparent PNG.
BASE: minime_eating.png — seated at table, 3/4 view, fork raised.
FRAME 3 (bite taken): Fork raised fully — tip at mouth height, forearm more vertical, elbow up.
Mouth: small closed "o" or pursed smile shape (eating moment). Eyes: closed-curve happy "mmm"
expression. Cheek tint 1 px larger than usual (satisfaction). Food dot on plate now smaller
or absent (it was eaten). Small 1-px cream #F5E6D3 dot at corner of mouth (crumb detail).
PALETTE LOCKED: #F5E6D3 #D4C0A0 #E8985E #FFD54F #5B8C5A #C4874A #A06030 #6B3A18 #C9B89A #2D2040
STYLE: Pixel art, nearest-neighbor, NO anti-aliasing. Transparent PNG.
OUTPUT: 192×320 PNG.
```

---

# 13. `minime_reading_f1/f2/f3.png` — page-turn animation (2 unique + 1 repeat)

**Base reference:** `minime_reading.png` (cross-legged, book in lap, head tilted down)
**Animation:** Page-turn gesture — book stays in lap, one hand lifts to turn a page. f3 repeats f1 to keep the 3-frame cycle structure the bakery expects.

### Frame 1 — `minime_reading_f1.png` (reading, both hands on book)

Both hands gripping the open book at the sides, head tilted ~15° down — identical to base. This is the steady reading position.

**Prompt:**
```
Pixel art chibi character animation frame, 192×320 transparent PNG.
BASE: minime_reading.png — seated cross-legged, open book in lap, both hands on book sides.
FRAME 1 (reading): Identical to base — both hands holding book at sides, head tilted ~15° down
toward pages. Calm half-closed reading eyes. Soft neutral smile.
Output must closely match minime_reading.png.
PALETTE LOCKED: #F5E6D3 #D4C0A0 #E8985E #FFD54F #5B8C5A #C4874A #A06030 #6B3A18 #C9B89A #2D2040
STYLE: Pixel art, nearest-neighbor, NO anti-aliasing. Transparent PNG.
OUTPUT: 192×320 PNG.
```

### Frame 2 — `minime_reading_f2.png` (page-turn hand raised)

Right hand lifts off the book — forearm raised 5–6 px, reaching across toward the top-right corner of the open book (about to turn a page). Left hand still holds the spine. Head lifts 4–5 px (glancing toward the page edge before turning). Eyes slightly wider.

**Prompt:**
```
Pixel art chibi character animation frame, 192×320 transparent PNG.
BASE: minime_reading.png — seated cross-legged, book in lap, both hands on book.
FRAME 2 (page-turn): Right hand (far side from viewer) lifts off book — forearm raised 5–6 px,
reaching toward upper-right corner of open page (about to flip). Left hand still holds book
spine steady. Head lifts 4–5 px (glancing up toward page edge). Eyes slightly wider than base
(anticipating turn). Mouth same soft neutral. Book geometry otherwise unchanged.
PALETTE LOCKED: #F5E6D3 #D4C0A0 #E8985E #FFD54F #5B8C5A #C4874A #A06030 #6B3A18 #C9B89A #2D2040
STYLE: Pixel art, nearest-neighbor, NO anti-aliasing. Transparent PNG.
OUTPUT: 192×320 PNG.
```

### Frame 3 — `minime_reading_f3.png` (same as frame 1 — repeat)

> **Production note:** Save a duplicate of `minime_reading_f1.png` as `minime_reading_f3.png`. The bakery always requests frames 1–3; this avoids a missing-file fallback and keeps the cycle length consistent with other poses. No new art needed.

```
Copy minime_reading_f1.png → save as minime_reading_f3.png. No new art required.
```

---

# 14. `minime_socializing_f1/f2/f3.png` — conversation gesture animation (3 frames)

**Base reference:** `minime_socializing.png` (standing, one hand raised in open-palm conversational gesture)
**Animation:** Gesture arc — the raised hand moves through a small talking gesture loop.

### Frame 1 — `minime_socializing_f1.png` (hand mid-gesture, same as base)

Raised hand at chest height, palm open — identical to base. This is the neutral talking position.

**Prompt:**
```
Pixel art chibi character animation frame, 192×320 transparent PNG.
BASE: minime_socializing.png — standing, one hand raised at chest height, palm open,
mid-conversation gesture.
FRAME 1 (neutral gesture): Identical to base — raised hand at chest height, palm open fingers
loosely spread. Weight on one leg. Mouth slightly open soft smile. Speech-bubble dots above
hand (optional, match base). Output must closely match minime_socializing.png.
PALETTE LOCKED: #F5E6D3 #D4C0A0 #E8985E #FFD54F #5B8C5A #C4874A #A06030 #6B3A18 #C9B89A #2D2040
STYLE: Pixel art, nearest-neighbor, NO anti-aliasing. Transparent PNG.
OUTPUT: 192×320 PNG.
```

### Frame 2 — `minime_socializing_f2.png` (hand raised higher, emphatic point)

Raised hand lifted 4–5 px above frame 1 position — forearm angled upward, index finger extended pointing (making a point in conversation). Other arm has shifted forward slightly at the elbow (lean-in). Mouth opens slightly wider. Eyes widen 1 px (enthusiastic). Speech-bubble dots slightly higher/more prominent.

**Prompt:**
```
Pixel art chibi character animation frame, 192×320 transparent PNG.
BASE: minime_socializing.png — standing, raised hand mid-conversation gesture.
FRAME 2 (emphatic point): Raised hand 4–5 px higher than base — forearm angled upward,
index finger extended forward/up (making a conversational point). Other arm elbow shifted
4–5 px forward (slight lean-in). Mouth opens 1–2 px wider (speaking with emphasis). Eyes
1 px wider than base (enthusiasm). Speech-bubble dots 3–4 px higher and slightly larger.
Body weight/stance same as base, no foot change.
PALETTE LOCKED: #F5E6D3 #D4C0A0 #E8985E #FFD54F #5B8C5A #C4874A #A06030 #6B3A18 #C9B89A #2D2040
STYLE: Pixel art, nearest-neighbor, NO anti-aliasing. Transparent PNG.
OUTPUT: 192×320 PNG.
```

### Frame 3 — `minime_socializing_f3.png` (hand lowered, listening lean)

Raised hand dropped to near-resting — forearm lowered so hand is at waist height, palm facing down (winding down a point). Weight shifts to opposite leg (1–2 px body tilt). Head tilts 3–4 px toward imaginary friend (listening now). Mouth returns to closed soft smile. Speech-bubble dots gone (silent moment).

**Prompt:**
```
Pixel art chibi character animation frame, 192×320 transparent PNG.
BASE: minime_socializing.png — standing, raised hand mid-conversation gesture.
FRAME 3 (listening beat): Raised hand lowered — forearm down so hand is at waist height,
palm facing down (gesture winding down). Body shifts 1–2 px toward opposite leg (weight
change). Head tilts 3–4 px toward the viewer's right (leaning toward imaginary friend).
Mouth: closed soft smile (listening). No speech-bubble dots. Other arm still at natural
rest beside body. Eyes soft, attentive.
PALETTE LOCKED: #F5E6D3 #D4C0A0 #E8985E #FFD54F #5B8C5A #C4874A #A06030 #6B3A18 #C9B89A #2D2040
STYLE: Pixel art, nearest-neighbor, NO anti-aliasing. Transparent PNG.
OUTPUT: 192×320 PNG.
```

---

## Production Checklist

Tick each sprite as it lands in `mini-me/Assets.xcassets/` (or wherever sprite assets live in the project) and is verified at runtime against the widget snapshot pipeline.

### Character Poses — Base Sprites (192×320, transparent, bottom-center anchor)
- [x] 1. `minime_working.png` — sitting at desk, typing
- [x] 2. `minime_exercising.png` — mid jumping-jack
- [x] 3. `minime_eating.png` — sitting at table, fork raised
- [x] 4. `minime_reading.png` — sitting cross-legged with book
- [x] 5. `minime_socializing.png` — standing, gesturing in conversation

### Animation Frame Variants (192×320, same palette + anchor as base — widget cycling)
- [ ] 10a. `minime_working_f1.png` — rest position (≈ base)
- [ ] 10b. `minime_working_f2.png` — right hand key-press up
- [ ] 10c. `minime_working_f3.png` — left hand key-press up
- [ ] 11a. `minime_exercising_f1.png` — apex (≈ base)
- [ ] 11b. `minime_exercising_f2.png` — arms descending, legs closing
- [ ] 11c. `minime_exercising_f3.png` — push-off, feet on ground
- [ ] 12a. `minime_eating_f1.png` — fork low, over plate
- [ ] 12b. `minime_eating_f2.png` — fork mid-rise (≈ base)
- [ ] 12c. `minime_eating_f3.png` — fork at mouth, bite taken
- [ ] 13a. `minime_reading_f1.png` — both hands on book (≈ base)
- [ ] 13b. `minime_reading_f2.png` — page-turn hand raised
- [ ] 13c. `minime_reading_f3.png` — duplicate of f1 (no new art needed)
- [ ] 14a. `minime_socializing_f1.png` — neutral gesture (≈ base)
- [ ] 14b. `minime_socializing_f2.png` — emphatic point, hand raised
- [ ] 14c. `minime_socializing_f3.png` — listening lean, hand lowered

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

### Definition of Done (animation frame sets, additional checks)
- [ ] All 3 frames for an activity added to `Assets.xcassets/` before considering that pose "animated"
- [ ] `RoomScene.hasFrameVariants(for:)` returns `true` for the activity (confirms `minime_<activity>_f1` loaded)
- [ ] Widget observed to cycle visibly on a home screen widget during an active block (watch for 5 seconds — should see 3 distinct poses loop)
- [ ] Motion reads as continuous at 1.5s intervals — no jarring jump between frames
- [ ] Fallback verified: delete `_f1` from xcassets → widget gracefully shows base sprite instead of crashing
