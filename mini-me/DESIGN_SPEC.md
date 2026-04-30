# Mini Me — Design Specification

## One-Liner

**A home-screen widget where a pixel version of you lives your day** — working when you work, exercising when you exercise, hanging out with your friends' mini-mes when you're being social. The phone app exists to configure the widget; **the widget IS the product.**

## The Wedge

The market is saturated with habit trackers and static-pet widgets. Pixel Pals puts a *static* pet on the widget. Widgetable is co-parenting a Tamagotchi. Finch is app-only. **No competitor owns "your day, animated on your home screen."** That's our wedge.

| Competitor | What they do | What's missing |
|---|---|---|
| Pixel Pals (id6444085825) | Static pixel pet on widget | Pet doesn't *do anything*. No social. |
| Widgetable Pixel Pet | Co-parent a pet with friend | A Tamagotchi with a partner — not "you" |
| Finch | Self-care bird, app-only | No widget presence; bird is a metaphor, not you |
| **Mini Me (us)** | **Your activity → reflected live on your widget; friends visible during shared activity** | This combination is uncontested |

---

## Decisions Log (Finalized)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Character concept | **Mini Me** — a pixel avatar of YOU, not a pet | Deeper emotional connection; mirrors your real life |
| Target audience | Students & young adults (16-27): high school, college, young professionals | Pixel aesthetic resonates, routine-forming life stage, social sharing culture |
| Room perspective | Isometric (lo-fi cozy aesthetic) | Gives that lo-fi album cover warmth; top-down feels like a game, isometric feels like a vibe |
| Furniture placement | Pre-set slots (not free grid) | Kills 80% of isometric rendering complexity; no z-sorting, collision, or free grid math needed |
| Art pipeline | AI-generated pixel art (v1), custom art later | Fast iteration, low cost; clean up and curate AI output |
| Architecture | Option C: solo-first, social-ready | Ship local-only v1 but structure data models for future server sync (rooms, avatars, social visits) |
| Social vision (v2+) | Rooms are visitable, avatars mirror real life (sick/happy/tired), gift dropping | This is the real retention loop — pixel art social space where your avatar reflects your real life |
| Item count (v1) | 20-25 well-crafted items (reduced from 40-50) | Realistic scope for AI art pipeline; quality over quantity |

---

## Core Philosophy

**"Your day, on display."**

Users design their ideal daily schedule once during onboarding. From then on, the widget reflects whatever they're doing right now: at a `work` block, mini-me sits at a desk in a pixel study scene; at `exercise`, mini-me does jumping jacks in a gym scene; at `social`, mini-me hangs out — and if a friend is also in a social block, their mini-me is right there in the scene too.

**The character is YOU.** Not a pet. Not a Tamagotchi. A pixel version of yourself, alive on your home screen.

The completion mechanic (tap a block when done) drives a small coin economy that lets you decorate scenes, but the *primary feedback loop is ambient* — you glance at your home screen and see a pixel scene that matches what you're supposed to be doing. That glance is the product.

---

## Art & Aesthetic Identity — THE SOUL OF THE APP

> **Pixel art + lo-fi cozy vibe.** This is not a stylistic choice — it IS the product. Every screen, every animation, every asset must feel like it belongs on a lo-fi album cover or a cozy pixel diorama Pinterest board.

### Visual Pillars
1. **Isometric pixel rooms** — warm, miniature worlds viewed from a cozy diagonal angle. Dark backgrounds, glowing lamps, soft ambient light.
2. **Warm muted palette** — cream, sage green, warm orange, soft gold. No harsh neons, no corporate blues. Everything feels like a warm blanket.
3. **Handcrafted feel** — 32×32 sprites with 8-12 color palettes. Crisp pixels, no anti-aliasing, nearest-neighbor scaling. Each item should look like a pixel artist lovingly placed every dot.
4. **Lo-fi over polish** — pixel-art UI borders, retro accents, subtle scan-line or dither effects where appropriate. The app should feel warm and nostalgic, not clinical or modern-corporate.
5. **Ambient life** — soft glow from lamps, time-of-day lighting (sunrise warmth → sunset orange → night with warm interior light), subtle idle animations.

### The Vibe Test
Before adding any visual element, ask: *"Does this feel like it belongs in a lo-fi YouTube stream thumbnail?"* If no, rethink it.

### Color Palette
```
Background:  #F5E6D3 (warm cream)
Primary:     #5B8C5A (sage green)
Accent:      #E8985E (warm orange)
Text:        #3D3D3D (soft black)
Completed:   #7CB342 (fresh green)
Pending:     #BDBDBD (light grey)
Coin:        #FFD54F (gold)
```

---

## V1 MVP Scope (Widget-First)

The order below is the **priority order**. The first 4 are the showpiece — anything below that is supporting.

### What's IN v1

1. **Activity-aware widget** (small, medium, large, lock-screen) — the showpiece
2. **Schedule input → activity output pipeline** (current `BlockCategory` drives current `RoomType + PetActivity` written to App Group)
3. **Mini Me avatar with 6+ activity poses** (idle, sleeping, happy, working, exercising, eating, reading, socializing)
4. **5 scenes auto-swapping with activity** (bedroom, study, gym, kitchen, coffeeShop)
5. Daily schedule view with tap-to-complete (configures the widget)
6. Coin economy + lightweight scene decoration (secondary loop)
7. Settings screen (edit schedule, customize Mini Me, reset data)
8. Haptic feedback + sound effects
9. Block reminder notifications

### What's OUT of v1 (deferred)

- **Friends layer** → v1.5 (CloudKit-based, friend mini-mes appear during shared social blocks — this is the moat)
- **Multiple rooms as purchasable shop content** → reframed: rooms are activity scenes, not purchases
- **Habit insights / 2-week trend / streaks page** → keep code, hide tab until v1.1
- **Calendar sync** → keep EventKit code, hide UI in v1
- **Pro tier with cosmetic IAP** → v1.1 with real StoreKit 2 (currently a stub Apple will reject)
- **Outfit visual overlay on character** → v2 (auto-equip logic exists; visual rendering pending)
- **Apple Watch** → v2
- **Mini-games** → v2

### Pivot Notes (April 2026)

The original v1 spec framed Mini Me as a habit tracker with a widget on the side. We're correcting course: the widget is the product. Habit-tracker features (insights, streaks, gamification) are *demoted*, not removed — they'll re-surface in v1.1 once the widget-first launch validates the wedge.

---

## Feature Spec

### 1. Ideal Day Builder

**Onboarding Flow (first launch):**

```
Screen 1: "Let's design your ideal day."
Screen 2: "What time do you wake up?" → time picker
Screen 3: "What does your morning look like?" → pick from blocks
Screen 4: "What about your afternoon?" → same block picker
Screen 5: "And your evening?" → same block picker
Screen 6: "Create your Mini Me!" → name + skin tone picker
```

**How it works:**

- Users build a daily schedule from **time blocks** (30-min or 1-hr increments)
- Each block has a category, custom label, and time slot
- Schedule is fully editable after onboarding (Settings > Edit Schedule)
- Weekend schedule can differ from weekday (model supports it, weekend UI is v1.5)

**Block Categories (v1):**

| Category | Icon | Examples |
|----------|------|----------|
| Wellness | sparkles | Meditation, Skincare, Journaling |
| Exercise | figure.run | Gym, Walk, Yoga, Stretching |
| Nutrition | fork.knife | Breakfast, Lunch, Dinner, Meal Prep |
| Learning | book.fill | Study, Reading, Language Practice |
| Creative | paintbrush.fill | Drawing, Music, Writing, Coding |
| Work | briefcase.fill | Deep Work, Meetings, Email |
| Social | person.2.fill | Family Time, Call Friend, Date Night |
| Rest | moon.fill | Nap, Sleep, Wind Down |
| Routine | arrow.triangle.2.circlepath | Morning Routine, Evening Routine, Chores |
| Custom | star.fill | User-defined |

---

### 2. Daily Schedule View (Main Screen)

**Layout:** Vertical timeline for the current day.

```
┌─────────────────────────────┐
│  [Avatar]  Tue, Mar 24      │
│  ██████░░░░  60% done       │
├─────────────────────────────┤
│  ✅ 6:30  Morning Routine   │
│  ✅ 7:00  Exercise          │
│  ✅ 7:30  Breakfast         │
│  ▶️ 8:00  Deep Work         │  ← current block (highlighted)
│  ○ 10:00 Study              │
│  ○ 12:00 Lunch              │
│  ○ 13:00 Creative Time      │
│  ○ 15:00 Walk               │
│  ○ 17:00 Dinner             │
│  ○ 18:00 Free Time          │
│  ○ 21:00 Evening Routine    │
│  ○ 22:00 Wind Down          │
├─────────────────────────────┤
│  [📅Today] [🏠Room] [🛍Shop]│
│  [📊Stats] [⚙️Settings]    │
└─────────────────────────────┘
```

**Mechanics:**

- Tap a block to mark it complete → earns coins + haptic feedback + sound effect
- Current time block is highlighted with a subtle glow
- Blocks can be completed out of order (no rigid enforcement)
- Skipped blocks grey out after their time passes (no penalty in v1, just visual)
- Perfect day triggers celebration haptic + sound

---

### 3. Coin Economy

**Earning:**

| Action | Coins |
|--------|-------|
| Complete a time block | 10 coins |
| Complete all morning blocks | 15 bonus |
| Complete all afternoon blocks | 15 bonus |
| Complete all evening blocks | 15 bonus |
| Perfect day (100%) | 50 bonus |
| 3-day streak | 25 bonus |
| 7-day streak | 75 bonus |
| 30-day streak | 300 bonus |

**Typical daily earn:** 120-180 coins (assuming 10-12 blocks + bonuses).

**Spending:**

| Item Type | Price Range |
|-----------|-------------|
| Small room items (plants, rugs, posters) | 30-150 coins |
| Medium room items (desk, chair, lamp) | 150-350 coins |
| Large room items (bed, bookshelf, gaming desk) | 400-800 coins |
| Avatar outfits (v2) | 100-300 coins |
| New environments (v2) | 500-1500 coins |

---

### 4. Isometric Pixel Room

**The core reward loop.** Earn coins → buy items → place them in your room → see your room grow alongside your habits.

**Room spec (v1):**

- Single room, isometric perspective
- **Pre-set furniture slots** (12 fixed positions) — not free grid
- Tap a slot → choose which item goes there from owned items
- Room has walls (back left, back right) and floor
- Wall and floor themes are purchasable

**Pre-set slots (v1 room layout):**

| Slot | Position | Item types that fit |
|------|----------|-------------------|
| Bed area | Back-right corner | Beds, futons |
| Desk area | Back-left wall | Desks, tables |
| Desk chair | In front of desk | Chairs, stools |
| Shelf/bookcase | Left wall | Bookshelves, cabinets |
| Floor center | Room center | Rugs, floor cushions |
| Wall decor 1 | Back wall left | Posters, clocks, art |
| Wall decor 2 | Back wall right | Posters, shelves, art |
| Cozy corner | Front-left | Bean bags, plants, lamps |
| Side table | Near bed | Nightstands, small tables |
| Window area | Back wall center | Curtains, blinds |
| Chill spot | Floor near furniture | Cushions, boxes |
| Accent item | Floor front-right | Electronics, instruments |

**Room progression (v2+):**
- Start: Studio apartment. Bed, no frame. Bare walls.
- Earn coins → fill the room → unlock bigger house
- Studio → 1BR → 2BR
- Each environment can be upgraded independently
- Love the gym? Deck it out. Homebody? Kitchen island.

---

### 5. Mini Me Avatar System

**The character is YOU.** Not a pet. A pixel version of yourself.

**Avatar states (reflected in widget and in-room):**

| State | Trigger | Visual |
|-------|---------|--------|
| Sleeping | Before wake-up time or after 11pm | Zzz animation, 😴 |
| Happy | Completed recent blocks, >50% rate | Smiling, 😊 |
| Neutral | Normal state | Idle animation, 🙂 |
| Bored | No blocks completed in 3+ hours | Yawning, 🥱 |
| Sad | <30% of day completed near evening | Droopy, 😢 |
| Celebrating | Perfect day achieved | Party mode, 🥳 |

**Avatar customization (v1):**

- 3 skin tones: Warm Tone, Dark Tone, Light Tone
- Name your Mini Me
- Outfits/accessories (v2): headphones, phones, hats, jackets, gym fits, work outfits

**Avatar in room:**

- Wanders between furniture items
- Occasionally stretches (squash & stretch animation)
- Flips direction when walking
- Tap to interact (jumps + spins)
- Idle bobbing animation

**Future (v2+):**
- Sick day mode: cold towel, thermometer, red face
- Outfits auto-swap based on schedule (gym clothes at gym, PJs at night)
- Friends can visit your room and see your avatar

---

### 6. iOS Widget — The Showpiece

The widget is **the product**. See `docs/WIDGET_SPEC.md` for full implementation detail; this section is the product-facing summary.

**Activity-driven scene + pose:**

The current `TimeBlock.category` (or absence of an active block) drives:
- Which **scene** the widget shows (study, gym, kitchen, coffeeShop, bedroom)
- Which **pose** the mini-me holds (working, exercising, eating, socializing, sleeping, idling)

| Block Category | Scene | Mini-Me Pose |
|---|---|---|
| `work` | Study | `minime_working` (typing at desk) |
| `learning`, `creative` | Study | `minime_reading` |
| `exercise` | Gym | `minime_exercising` (jumping jack / yoga) |
| `nutrition` | Kitchen | `minime_eating` |
| `social` | Coffee Shop | `minime_socializing` |
| `rest`, `routine` (evening) | Bedroom | `minime_sleeping` |
| No active block | Bedroom | `minime_idle` |

**Widget sizes (v1):**

**Small (2×2):** Scene snapshot fills the entire widget. Activity label badge at bottom-left ("Working", "Exercise", etc.). No data clutter — pure ambient pixel art.

**Medium (4×2):** Scene fills the left half; right half shows activity name (large), progress fraction, coin count. The scene is still the focal point.

**Large (4×4):** Full scene at fidelity, with subtle activity label, "Up next" preview at bottom, and friend presence bubbles ("3 friends online") in v1.5.

**Lock screen (circular / rectangular / inline):** Inherit existing implementations; rectangular shows the activity icon + label; circular shows mini-me head only.

**Refresh strategy:**
- iOS limits widget refresh to ~15-min intervals
- App schedules timeline entries at every block boundary in today's schedule
- Each timeline entry corresponds to a pre-rendered snapshot (`room_diorama_<scene>_<pose>.png`)
- Snapshots are pre-baked when the user edits their schedule, so the widget never needs to wait for SpriteKit at render time

**Friends in scene (v1.5):**
- During shared `social` blocks, friends' mini-me sprites are composited into your coffee-shop scene at secondary positions
- Only `currentActivity + sceneType + name + sprite` syncs via CloudKit — no schedule, completion, or coin data ever leaves the device

---

### 7. Settings Screen

**Implemented features:**
- **Edit Mini Me**: Change name and skin tone
- **Edit Schedule**: View/add/delete time blocks, category picker, time picker, duration picker
- **App info**: Version display
- **Reset All Data**: Destructive action with confirmation, returns to onboarding

---

### 8. Haptic & Sound Feedback

**Haptics (HapticService):**
- Light: toggling, selecting items
- Medium: completing a block, purchasing
- Heavy: major milestones (perfect day, streak)
- Success: block completed, purchase confirmed
- Warning: streak at risk
- Error: can't afford, invalid action
- Selection: picker wheels, tab switching

**Sounds (SoundService via AudioToolbox):**
- Coin collection (system sound 1057)
- Block completed (system sound 1025)
- Purchase confirmed (system sound 1052)
- Celebration / perfect day (system sound 1026)
- Error / can't afford (system sound 1053)
- Navigation tap (system sound 1104)

---

## Monetization (V1)

### Freemium Model

**Free tier:**
- Full schedule builder
- Full daily tracking
- Coin earning (no cap)
- Room decoration (access to ~60% of items)
- Avatar with basic customization
- Widget (small only)

**Mini Me Pro — $1.99/month or $14.99/year:**
- Medium widget
- Exclusive room items (~40% of catalog)
- Exclusive avatar outfits (v2)
- Weekend schedule (separate from weekday)
- Multiple room themes (v2)
- Custom block categories
- Advanced stats
- No feature removed from free tier

**Why $1.99/month:**
- Impulse-buy territory — less than a coffee
- ~3.5x cheaper than Finch ($70/year) — obvious value pick
- Higher conversion rate at lower price outearns higher price at sub-100K scale
- Can raise prices later once content and social proof grow

---

## Technical Architecture

### Stack
- **Language:** Swift 5.9+
- **UI:** SwiftUI
- **Data:** SwiftData (local persistence, no server for v1)
- **Widget:** WidgetKit + SwiftUI
- **Room rendering:** SpriteKit (isometric, embedded in SwiftUI)
- **Haptics:** UIKit feedback generators
- **Sounds:** AudioToolbox system sounds
- **Minimum target:** iOS 17.0

### Key Architecture Notes
- SwiftData can't store enums directly — models use raw String values
- Widget shares data via App Groups (UserDefaults suiteName: `group.com.pixelpals.shared`)
- Room uses 12 fixed SlotType positions with hardcoded isometric coordinates
- `Pet` model is named "Pet" internally but represents the Mini Me avatar — never called "pet" in UI
- PetColor cases map to skin tones: `.orangeTabby` = Warm, `.black` = Dark, `.white` = Light
- Data models structured for future server sync (DTOs exist for all models)

---

---

## User Journey (First 7 Days)

**Day 1:**
- Download → Onboarding → Design ideal day (~2 min)
- Create your Mini Me → Choose skin tone + name
- See your schedule → Complete 2-3 blocks → Earn first coins
- Buy first small item (plant or rug) → Place in room
- "Come back tomorrow to keep building your room!"

**Day 2-3:**
- Complete more blocks → Buy another item
- Room starts to feel like "yours"
- 3-day streak bonus feels rewarding

**Day 4-5:**
- Unlock a medium item → Room transformation is visible
- Avatar reacts to furniture (wanders around, interacts)
- User screenshots room → shares

**Day 7:**
- 7-day streak bonus (75 coins)
- Room looks noticeably furnished
- Stats show weekly completion rate
- User thinks: "This is actually helping me stick to my routine"

---

## V2+ Roadmap

1. **Avatar outfits & outfit shop** (headphones, gym fits, work clothes)
2. **Multiple rooms** (bedroom, kitchen, study, gym, coffee shop)
3. **Social: visit friends' rooms**, leave gifts
4. **Sick day / status modes** (avatar mirrors real-life state)
5. **Seasonal events** (holiday items, limited-time furniture)
6. **Notifications** (block reminders, streak warnings)
7. **Weekend schedule UI**
8. **Apple Watch complication**
9. **Habit insights** (which blocks you skip most, trends)
10. **Lock Screen widget**
11. **Optional calendar sync** (for users who want it)
12. **Android version**

---

## Related Documents

- `docs/DESIGN_CONVERSATION.md` — Full design conversation log with all critiques, pivots, and reasoning
- `CLAUDE.md` — Technical project memory for development context
