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

## Scene Backgrounds — proportions reference (applies to prompts 6–9)

All scene backgrounds must match the existing `room_bedroom_empty.png` reference:

- **Canvas:** 246×246 px, transparent PNG
- **Anchor:** bottom-center (the floor plane of the room rests on the bottom edge, centered horizontally)
- **Projection:** isometric (2:1 pixel ratio for 30°-style iso), viewed from a cozy diagonal angle
- **Composition:** an L-shaped floor in the foreground, two back walls receding upward-left and upward-right, lavender-tone hex frame border style consistent with `room_bedroom_empty.png`
- **Floor:** wood-mid `#A06030` planks with wood-light `#C4874A` highlights and wood-deep `#6B3A18` joints
- **Walls:** cream `#F5E6D3` with linen-mid `#C9B89A` shading, lavender `#9B7EC8`-style frame trim if used
- **Activity slot:** leave the bottom-center floor area clear so the character sprite (192×320) can composite cleanly, anchored to bottom-center of the scene
- **Light source:** top-left across all furniture, casting shadows down-right onto floor

---

# 6. `room_study_empty.png` — pixel desk, chair, bookshelves, warm lamp, coffee mug

**Filename:** `room_study_empty.png`
**Dimensions:** 246×246 px transparent PNG
**Anchor:** bottom-center
**Activity mapping:** scene for `BlockCategory.work`, `learning`, `creative` (`RoomType.study`).

**Description:** Cozy isometric study corner. Wooden desk against the back-right wall with a closed laptop and a steaming coffee mug, a bookshelf along the back-left wall with a few colored book spines, a small warm desk lamp glowing gold, and a sage-green potted plant on the floor.

**Prompt to paste into `/art`:**

```
Pixel art isometric scene background, 246×246 transparent PNG, bottom-center anchor.

SUBJECT: A cozy lo-fi isometric "study" room corner — empty of any character, will be composited with a 192×320 chibi character sprite anchored bottom-center of this scene.

LAYOUT:
- L-shaped wooden floor occupying the lower portion: wood-mid #A06030 planks, wood-light #C4874A plank highlights, wood-deep #6B3A18 joint lines
- Two back walls receding upward-left and upward-right, cream #F5E6D3 with linen-mid #C9B89A subtle shading, lavender #9B7EC8-style hex frame trim consistent with room_bedroom_empty.png
- Bottom-center floor area MUST be clear (no furniture) so a character sprite can stand there

FURNITURE (placed against back walls and corners only, leaving the center floor open):
- Wooden desk against the back-right wall: wood-light #C4874A top, wood-mid #A06030 side, wood-deep #6B3A18 underside; on top: a small closed cream #F5E6D3 laptop, and a cream #F5E6D3 coffee mug with a tiny sage #5B8C5A heart/leaf emblem and 2–3 cream-shadow #D4C0A0 steam pixels rising
- Small warm desk lamp on the desk: wood-mid stem, gold #FFD54F bulb glow with a 1–2 pixel cream #F5E6D3 highlight halo
- Bookshelf against the back-left wall: 3 shelves, wood-mid frame, with book spines in warm orange #E8985E, sage #5B8C5A, gold #FFD54F, and cream #F5E6D3 — varied heights, hand-placed feel
- Small potted plant on the floor in the back-left corner: terracotta-tone pot using #C4874A + #A06030, leaves sage green #5B8C5A
- A small wooden chair tucked partially under the desk (suggested, not blocking the center)

PALETTE (LOCKED, 11 colors only):
#F5E6D3, #D4C0A0, #E8985E, #FFD54F, #5B8C5A, #C4874A, #A06030, #6B3A18,
#C9B89A, #2D2040 (outline + 60%-density cast shadows), and lavender frame accent in #9B7EC8 IF needed for trim consistency with room_bedroom_empty.png.

LIGHTING: top-left light source. Back-left wall slightly brighter than back-right. Lamp bulb glows gold #FFD54F with subtle 1-pixel ambient warm tint on nearby desk surface. Cast shadows from each piece of furniture in #2D2040 at 60% pixel density, offset bottom-right onto floor.

STYLE: Isometric (2:1 ratio), pixel art, nearest-neighbor, NO anti-aliasing. Outline #2D2040 only — never pure black. Cozy lo-fi album-cover diorama vibe; canonical reference PixelJoint #131408. Transparent PNG. Same proportions and frame style as room_bedroom_empty.png.

OUTPUT: 246×246 PNG, transparent, floor anchored to bottom-center of canvas, center floor space clear for character compositing.
```

---

# 7. `room_gym_empty.png` — small home gym corner: yoga mat, dumbbells, mirror, plant

**Filename:** `room_gym_empty.png`
**Dimensions:** 246×246 px transparent PNG
**Anchor:** bottom-center
**Activity mapping:** scene for `BlockCategory.exercise` (`RoomType.gym`).

**Description:** Tiny home-gym corner. Sage-green rolled-out yoga mat on the floor (clear of center), small wooden rack with two warm-orange dumbbells, a tall narrow wall mirror, and a leafy plant.

**Prompt to paste into `/art`:**

```
Pixel art isometric scene background, 246×246 transparent PNG, bottom-center anchor.

SUBJECT: A cozy lo-fi isometric "home gym" corner — small, warm, lived-in (NOT a clinical commercial gym). Empty of any character, will be composited with a 192×320 chibi sprite anchored bottom-center of this scene.

LAYOUT:
- Same L-shaped wood floor as room_bedroom_empty.png: wood-mid #A06030 planks, wood-light #C4874A highlights, wood-deep #6B3A18 joints
- Two back walls receding up-left and up-right, cream #F5E6D3 with linen-mid #C9B89A shading, lavender #9B7EC8-style hex frame trim
- Bottom-center floor area MUST stay clear for character compositing

FURNITURE (placed in corners and along walls only):
- Sage green #5B8C5A rolled-out yoga mat on the floor along the back-right edge (parallel to the right wall, NOT under the center character slot); cream-shadow #D4C0A0 stripe details to suggest texture
- Small wooden dumbbell rack tucked into the back-right corner: wood-mid #A06030 frame, two short dumbbells with warm-orange #E8985E weight plates and wood-deep #6B3A18 grips
- Tall narrow wall mirror on the back-left wall: wood-mid #A06030 frame, mirror surface a soft cream #F5E6D3 with 1–2 linen-mid #C9B89A diagonal highlight streaks (no actual reflection of the character — keep generic)
- Leafy potted plant on the floor in the back-left corner: terracotta pot in #C4874A + #A06030, big sage green #5B8C5A leaves
- Optional: small folded cream #F5E6D3 towel on the dumbbell rack

PALETTE (LOCKED, 11 colors only):
#F5E6D3, #D4C0A0, #E8985E, #FFD54F, #5B8C5A, #C4874A, #A06030, #6B3A18,
#C9B89A, #2D2040, plus #9B7EC8 lavender for frame trim only.

LIGHTING: top-left light source. Mirror frame top-left highlight in #C4874A, dumbbell plates highlight on top-left of each plate. Cast shadows under mat, rack, plant in #2D2040 at 60% density, offset bottom-right.

STYLE: Isometric (2:1), pixel art, nearest-neighbor, NO anti-aliasing. Outline #2D2040 only. Cozy lo-fi diorama vibe — reference PixelJoint #131408. Same frame and proportions as room_bedroom_empty.png. Transparent PNG.

OUTPUT: 246×246 PNG, transparent, floor anchored to bottom-center, center stage clear for character compositing.
```

---

# 8. `room_kitchen_empty.png` — small kitchen counter with stove, fridge, hanging utensils

**Filename:** `room_kitchen_empty.png`
**Dimensions:** 246×246 px transparent PNG
**Anchor:** bottom-center
**Activity mapping:** scene for `BlockCategory.nutrition` (`RoomType.kitchen`).

**Description:** A cozy lo-fi kitchen nook. A wooden counter along the back wall with a small stove and a kettle, a cream-colored fridge in the back-left corner, a few utensils hanging from a small wood rail, and a sage potted herb on the counter.

**Prompt to paste into `/art`:**

```
Pixel art isometric scene background, 246×246 transparent PNG, bottom-center anchor.

SUBJECT: A cozy lo-fi isometric kitchen nook — small, warm, hand-built feel (NOT a sterile modern kitchen). Empty of any character, will be composited with a 192×320 chibi sprite anchored bottom-center.

LAYOUT:
- L-shaped wood floor: wood-mid #A06030 planks, wood-light #C4874A highlights, wood-deep #6B3A18 joints
- Two back walls (cream #F5E6D3 with linen-mid #C9B89A shading), lavender #9B7EC8-style hex frame trim
- Bottom-center floor MUST stay clear for character compositing

FURNITURE (against back walls / in corners only):
- Wooden counter spanning the back-right wall: wood-light #C4874A countertop face, wood-mid #A06030 side, wood-deep #6B3A18 underside, with a small cream #F5E6D3 cabinet door shape and a single gold #FFD54F handle
- Small stove top inset into the counter: dark #2D2040 burner circles (2 burners), with a cream-shadow #D4C0A0 ring around each
- Small kettle on the stove: warm-orange #E8985E body, gold #FFD54F handle, 2–3 pixels of cream-shadow #D4C0A0 steam rising
- Cream-colored mini fridge in the back-left corner: cream #F5E6D3 body, cream-shadow #D4C0A0 side panel, gold #FFD54F handle, 1 small sage #5B8C5A magnet/sticker dot on the door
- Tiny wood rail above the counter on the back wall (wood-mid #A06030) with 2–3 utensils hanging: a sage #5B8C5A spatula, a gold #FFD54F ladle, a wood-deep #6B3A18 spoon
- Small terracotta pot of sage green herbs on the countertop (terracotta = #C4874A + #A06030, leaves #5B8C5A)

PALETTE (LOCKED, 11 colors only):
#F5E6D3, #D4C0A0, #E8985E, #FFD54F, #5B8C5A, #C4874A, #A06030, #6B3A18,
#C9B89A, #2D2040, plus #9B7EC8 lavender for frame trim only.

LIGHTING: top-left source. Top-left counter face brighter, cream fridge face top-left brightest. Cast shadows under counter, fridge, and herb pot in #2D2040 at 60% density, offset bottom-right.

STYLE: Isometric (2:1), pixel art, nearest-neighbor, NO anti-aliasing. Outline #2D2040 only — never pure black. Cozy lo-fi diorama vibe, canonical reference PixelJoint #131408. Same frame and proportions as room_bedroom_empty.png. Transparent PNG.

OUTPUT: 246×246 PNG, transparent, floor anchored to bottom-center, center stage clear for character compositing.
```

---

# 9. `room_coffeeshop_empty.png` — cozy café table, two chairs, hanging bulb light, plant

**Filename:** `room_coffeeshop_empty.png`
**Dimensions:** 246×246 px transparent PNG
**Anchor:** bottom-center
**Activity mapping:** scene for `BlockCategory.social` (`RoomType.coffeeShop`). This scene will host a friend's mini-me sprite alongside the user's during shared social blocks (v1.5), so the layout needs room for two chair positions.

**Description:** A cozy isometric café corner. A small round wooden table with TWO chairs (one facing 3/4 each side of the table) under a warm hanging-bulb pendant light, a sage potted plant in the back corner, and a chalkboard menu on the back wall.

**Prompt to paste into `/art`:**

```
Pixel art isometric scene background, 246×246 transparent PNG, bottom-center anchor.

SUBJECT: A cozy lo-fi isometric café / coffee-shop corner — warm and intimate, NOT a busy commercial café. Empty of any character (the scene must accommodate up to two chibi sprites anchored near bottom-center, one user mini-me and one friend mini-me, in v1.5).

LAYOUT:
- L-shaped wood floor: wood-mid #A06030 planks, wood-light #C4874A highlights, wood-deep #6B3A18 joints
- Two back walls cream #F5E6D3 with linen-mid #C9B89A shading, lavender #9B7EC8 hex frame trim
- Bottom-center floor area MUST stay clear; the table is centered slightly UP-and-back from the bottom-center (placed mid-canvas) so two character sprites can stand on either side of it without overlap

FURNITURE:
- Small round café table near the visual center of the scene (NOT touching the bottom edge — leave bottom 1/3 of canvas clear for character compositing): wood-light #C4874A round top, wood-mid #A06030 pedestal, wood-deep #6B3A18 base
- TWO small wooden chairs, one on the left side of the table and one on the right side, both 3/4-facing inward toward the table. Wood-mid #A06030 frames, wood-light #C4874A seat tops
- On the table: two cream #F5E6D3 coffee mugs with cream-shadow #D4C0A0 rims and 2 pixels each of cream-shadow #D4C0A0 steam rising
- Hanging pendant bulb light directly above the table: wood-mid #A06030 cord descending from the upper frame edge, gold #FFD54F bulb with a 1-pixel cream halo and faint warm-orange #E8985E glow tint on the table top below
- Tall sage green plant in the back-left corner: terracotta pot #C4874A + #A06030, leaves #5B8C5A
- Small chalkboard menu on the back-right wall: dark #2D2040 board, wood-mid #A06030 frame, 2–3 cream #F5E6D3 pixel-thin lines suggesting menu text, optional 1 gold #FFD54F dot price highlight

PALETTE (LOCKED, 11 colors only):
#F5E6D3, #D4C0A0, #E8985E, #FFD54F, #5B8C5A, #C4874A, #A06030, #6B3A18,
#C9B89A, #2D2040, plus #9B7EC8 lavender for frame trim only.

LIGHTING: top-left source PLUS warm pendant bulb glow over the table. Pendant casts a soft gold #FFD54F highlight on the table top and a faint warm-orange #E8985E ambient tint on the chairs nearby. Cast shadows under table, chairs, plant, chalkboard in #2D2040 at 60% density, offset bottom-right.

STYLE: Isometric (2:1), pixel art, nearest-neighbor, NO anti-aliasing. Outline #2D2040 only. Cozy lo-fi album-cover diorama vibe, reference PixelJoint #131408. Same frame and proportions as room_bedroom_empty.png. Transparent PNG.

OUTPUT: 246×246 PNG, transparent, floor anchored to bottom-center; bottom 1/3 of canvas clear of furniture so two character sprites can stand on either side of the centered table.
```

---

## Production Checklist

Tick each sprite as it lands in `mini-me/Assets.xcassets/` (or wherever sprite assets live in the project) and is verified at runtime against the widget snapshot pipeline.

### Character Poses (192×320, transparent, bottom-center anchor)
- [ ] 1. `minime_working.png` — sitting at desk, typing
- [ ] 2. `minime_exercising.png` — mid jumping-jack
- [ ] 3. `minime_eating.png` — sitting at table, fork raised
- [ ] 4. `minime_reading.png` — sitting cross-legged with book
- [ ] 5. `minime_socializing.png` — standing, gesturing in conversation

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
