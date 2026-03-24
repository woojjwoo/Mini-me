# Pixel Pals — Design Specification

## One-Liner

A pixel-art iOS app where you design your ideal daily schedule, complete it to earn coins, and spend coins decorating an isometric pixel room — with your pet living on your home screen widget.

---

## Decisions Log (Finalized)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Target audience | Students & young adults (16-27): high school, college, young professionals | Pixel aesthetic resonates, routine-forming life stage, social sharing culture |
| Room perspective | Isometric (lo-fi cozy aesthetic) | Gives that lo-fi album cover warmth; top-down feels like a game, isometric feels like a vibe |
| Furniture placement | Pre-set slots (not free grid) | Kills 80% of isometric rendering complexity; no z-sorting, collision, or free grid math needed |
| Art pipeline | AI-generated pixel art (v1), custom art later | Fast iteration, low cost; clean up and curate AI output |
| Architecture | Option C: solo-first, social-ready | Ship local-only v1 but structure data models for future server sync (rooms, avatars, social visits) |
| Social vision (v2+) | Rooms are visitable, avatars mirror real life (sick/happy/tired), gift dropping | This is the real retention loop — pixel art social space where your avatar reflects your real life |
| Item count (v1) | 20-25 well-crafted items (reduced from 40-50) | Realistic scope for AI art pipeline; quality over quantity |

---

## Core Philosophy

**"Design the life you want, then live it."**

Users don't sync their messy calendar. They answer: *"What does your ideal day look like?"*
The app builds a personalized daily schedule from that answer. Every completed block earns coins. Coins buy room items and pet cosmetics. The pet on your widget reflects how your day is going.

---

## V1 MVP Scope (8-10 week target)

### What's IN v1

1. Ideal Day Builder (onboarding + editable)
2. Daily schedule view with tap-to-complete
3. Coin economy (earn from completing blocks)
4. One isometric pixel room with purchasable furniture
5. One pet type with basic mood states on iOS widget
6. Home screen widget showing pet + today's progress

### What's OUT of v1 (future versions)

- Multiple rooms / room themes
- Multiple pet types
- Social features / friend visits
- Apple Watch support
- Advanced stats / analytics
- Streak rewards beyond basic
- Mini-games

---

## Feature Spec

### 1. Ideal Day Builder

**Onboarding Flow (first launch):**

```
Screen 1: "Let's design your ideal day."
Screen 2: "What time do you wake up?" → time picker
Screen 3: "What does your morning look like?" → pick from blocks:
          [Morning Routine] [Exercise] [Meditation] [Journaling]
          [Breakfast] [Study] [Creative Time] [Free Time]
Screen 4: "What about your afternoon?" → same block picker
Screen 5: "And your evening?" → same block picker
Screen 6: "Here's your ideal day!" → timeline preview → confirm
```

**How it works:**

- Users build a daily schedule from **time blocks** (30-min or 1-hr increments)
- Each block has a category, custom label, and time slot
- Pre-built templates available: "Student", "Remote Worker", "Fitness Focus", "Creative", "Balanced"
- Schedule is fully editable after onboarding (Settings > My Ideal Day)
- Weekend schedule can differ from weekday schedule

**Block Categories (v1):**

| Category | Icon | Examples |
|----------|------|----------|
| Wellness | 🧘 | Meditation, Skincare, Journaling |
| Exercise | 💪 | Gym, Walk, Yoga, Stretching |
| Nutrition | 🍳 | Breakfast, Lunch, Dinner, Meal Prep |
| Learning | 📚 | Study, Reading, Language Practice |
| Creative | 🎨 | Drawing, Music, Writing, Coding |
| Work | 💼 | Deep Work, Meetings, Email |
| Social | 👋 | Family Time, Call Friend, Date Night |
| Rest | 😴 | Nap, Sleep, Wind Down |
| Routine | ✨ | Morning Routine, Evening Routine, Chores |
| Custom | ⭐ | User-defined |

---

### 2. Daily Schedule View (Main Screen)

**Layout:** Vertical timeline for the current day.

```
┌─────────────────────────────┐
│  [Pet Avatar]  Tue, Mar 24  │
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
│  [🏠 Room]  [📊 Stats]     │
│  [🛍 Shop]  [⚙️ Settings]  │
└─────────────────────────────┘
```

**Mechanics:**

- Tap a block to mark it complete → earns coins + satisfying pixel animation
- Current time block is highlighted with a subtle glow
- Blocks can be completed out of order (no rigid enforcement)
- Skipped blocks grey out after their time passes (no penalty in v1, just visual)
- Optional: "I did something else" → log a custom activity for partial credit

**Completion feels good:**

- Tap to complete → pixel sparkle animation + coin sound
- Coin counter increments with a bounce
- Pet on the widget updates mood (happy face, hearts)
- Progress bar fills visually

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
| Small room items (books, plants, mugs) | 50-100 coins |
| Medium room items (desk, chair, lamp) | 150-300 coins |
| Large room items (bed, couch, bookshelf) | 400-800 coins |
| Special/rare items (arcade machine, aquarium) | 1000-2000 coins |
| Pet accessories (hats, scarves, glasses) | 100-300 coins |
| Wall/floor themes | 500-1000 coins |

**Balance target:** A casual user (completing ~60% of blocks) should unlock a small item daily and a medium item every 2-3 days. A perfect-day user should feel meaningfully rewarded but never run out of things to buy within the first 2 months.

---

### 4. Isometric Pixel Room

**The core reward loop.** You earn coins → you buy items → you place them in your room → you see your room grow alongside your habits.

**Room spec (v1):**

- Single room, isometric perspective
- **Pre-set furniture slots** (not free grid) — each slot has a fixed position in the room
- Tap a slot → choose which item goes there from your owned items
- Room has walls (back, left) and floor
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
| Window area | Back wall center | Curtains, blinds (cosmetic) |
| Pet bed | Floor near furniture | Pet beds, cushions, boxes |
| Accent item | Floor front-right | Electronics, instruments, fun items |

**Art style:**

- 32×32 pixel base tiles
- Warm, cozy color palette (think: lo-fi study room aesthetic)
- Items should feel handcrafted and charming
- Lighting: soft ambient + optional desk lamp glow
- The pet wanders the room when you view it

**V1 item count target:** 20-25 unique items across categories (quality over quantity, AI-generated):

- Furniture (bed, desk, chair, couch, bookshelf, table)
- Decor (plants, posters, rugs, curtains, clock)
- Electronics (laptop, monitor, game console, speakers)
- Cozy (candles, fairy lights, pillows, blankets)
- Fun (guitar, skateboard, telescope, globe)
- Food/Drink (coffee maker, ramen bowl, pizza box)

**Room interaction:**

- View room any time from bottom nav
- Pet walks around, sits on furniture, sleeps on bed
- Room reflects time of day (daylight through window → sunset → night with lights on)
- Screenshot/share button for social media

---

### 5. Pet System

**V1: One pet type** — A pixel cat (most universally appealing, lowest controversy).

**Pet states (reflected in widget and in-room):**

| State | Trigger | Visual |
|-------|---------|--------|
| Sleeping | Before wake-up time | Zzz animation |
| Happy | Completed recent blocks | Smiling, hearts |
| Neutral | Normal state | Idle animation |
| Bored | No blocks completed in 3+ hours | Yawning, looking around |
| Sad | Less than 30% of day completed near evening | Droopy ears, rain cloud |
| Celebrating | Perfect day achieved | Party hat, confetti |

**Pet customization (v1):**

- 3 base colors (orange tabby, black, white)
- Accessories purchasable with coins: hats (5), scarves (4), glasses (3), collars (4)
- Name your pet

**Pet in room:**

- Pet wanders between furniture items
- Sits on chairs, sleeps on beds, plays with certain items
- Idle animations cycle every 10-15 seconds

---

### 6. iOS Widget

**Widget sizes supported (v1):**

**Small widget (2×2):**
```
┌──────────┐
│  [Cat]   │
│  ██░░ 4/8│
│  60 🪙   │
└──────────┘
```
Shows: Pet with current mood, progress fraction, coins earned today.

**Medium widget (4×2):**
```
┌──────────────────────┐
│ [Cat]  Tue, Mar 24   │
│ ████░░░░  5/10 done  │
│ Next: Deep Work 2:00 │
│ 🪙 145 today         │
└──────────────────────┘
```
Shows: Pet, date, progress bar, next upcoming block, coins.

**Widget behavior:**

- Updates every 15 minutes (iOS limitation)
- Tapping widget opens app to daily schedule
- Pet mood reflects current completion status
- Pet has subtle idle animation frame changes on refresh

---

### 7. Notifications

**V1 notifications (all optional, off by default):**

- Block reminder: "Time for [Exercise]! Your cat is cheering you on." (5 min before block start)
- Mid-day nudge: "You've completed 4/10 blocks today. Keep going!" (1x, configurable time)
- Streak at risk: "Don't break your 7-day streak! Complete one more block." (evening)
- Never more than 3 notifications per day

---

## Monetization (V1)

### Freemium Model

**Free tier:**
- Full schedule builder
- Full daily tracking
- Coin earning (no cap)
- Room decoration (access to ~60% of items)
- Pet with basic customization
- Widget (small only)

**Pixel Pals Pro — $1.99/month or $14.99/year:**
- Medium widget
- Exclusive room items (~40% of catalog)
- Exclusive pet accessories
- Weekend schedule (separate from weekday)
- Multiple room themes (when added in v2)
- Custom block categories
- Advanced stats
- No feature removed from free tier (free users keep everything they had)

**Why this pricing:**
- $1.99/month is impulse-buy territory — less than a coffee, users don't hesitate
- ~3.5x cheaper than Finch ($70/year) — obvious value pick when users compare
- Higher conversion rate at $1.99 outearns $2.99 at sub-100K user scale
- Annual discount ($14.99 vs $23.88 monthly) incentivizes yearly commitment
- Can raise prices later once content library and social proof grow

**Revenue target math:**
- 10K downloads/month (achievable with good ASO + TikTok/IG content)
- 7% conversion to Pro at $1.99 = 700 subscribers/month
- Blended avg ~$1.66/month (mix of monthly + annual)
- ~$1,162/month per cohort
- After 12 months = ~$14K MRR
- Lower price, higher volume — better growth flywheel for a solo/small team

---

## Technical Architecture (iOS, Swift)

### Stack

- **Language:** Swift 5.9+
- **UI:** SwiftUI (entire app)
- **Data:** SwiftData (local persistence, no server needed for v1)
- **Widget:** WidgetKit + SwiftUI
- **Architecture:** MVVM
- **Pixel rendering:** SpriteKit for isometric room (embedded in SwiftUI view)
- **Notifications:** UserNotifications framework
- **Minimum target:** iOS 17.0

### Data Model (Core)

```swift
// User's ideal schedule
struct DailySchedule {
    let id: UUID
    var isWeekday: Bool
    var blocks: [TimeBlock]
}

struct TimeBlock {
    let id: UUID
    var category: BlockCategory
    var label: String
    var startTime: DateComponents  // hour + minute
    var durationMinutes: Int       // 30 or 60
}

enum BlockCategory: String, Codable {
    case wellness, exercise, nutrition, learning
    case creative, work, social, rest, routine, custom
}

// Daily tracking
struct DayLog {
    let id: UUID
    var date: Date
    var completedBlockIDs: [UUID]
    var coinsEarned: Int
}

// Room & items
struct Room {
    let id: UUID
    var wallTheme: String
    var floorTheme: String
    var placedItems: [PlacedItem]
}

struct PlacedItem {
    let id: UUID
    var itemID: String
    var gridX: Int
    var gridY: Int
    var rotation: Int  // 0, 90, 180, 270
}

// Pet
struct Pet {
    let id: UUID
    var name: String
    var baseColor: PetColor
    var accessories: [String]  // accessory item IDs
}

// Player
struct Player {
    var coins: Int
    var ownedItemIDs: [String]
    var currentStreak: Int
    var longestStreak: Int
    var totalDaysCompleted: Int
}
```

### Widget Data Sharing

- Use App Groups (`group.com.pixelpals.shared`) to share data between main app and widget extension
- Widget reads from shared `UserDefaults` or shared SwiftData store
- Main app writes completion status; widget reads on refresh

### File Structure

```
PixelPals/
├── App/
│   ├── PixelPalsApp.swift
│   └── ContentView.swift
├── Features/
│   ├── Onboarding/
│   │   ├── IdealDayBuilderView.swift
│   │   ├── TimePickerView.swift
│   │   └── BlockPickerView.swift
│   ├── Schedule/
│   │   ├── DailyScheduleView.swift
│   │   ├── TimeBlockRow.swift
│   │   └── CompletionAnimation.swift
│   ├── Room/
│   │   ├── IsometricRoomView.swift
│   │   ├── RoomScene.swift (SpriteKit)
│   │   ├── ItemPlacementView.swift
│   │   └── Assets/ (pixel art sprites)
│   ├── Shop/
│   │   ├── ShopView.swift
│   │   └── ItemDetailView.swift
│   ├── Pet/
│   │   ├── PetView.swift
│   │   └── PetCustomizationView.swift
│   └── Stats/
│       └── StatsView.swift
├── Models/
│   ├── DailySchedule.swift
│   ├── TimeBlock.swift
│   ├── Room.swift
│   ├── Pet.swift
│   └── Player.swift
├── Services/
│   ├── CoinService.swift
│   ├── StreakService.swift
│   ├── NotificationService.swift
│   └── WidgetDataService.swift
├── Shared/
│   ├── PixelArtComponents.swift
│   └── Theme.swift
└── Widget/
    ├── PixelPalsWidget.swift
    ├── SmallWidgetView.swift
    └── MediumWidgetView.swift
```

---

## Art Direction

### Pixel Art Style Guide

- **Tile size:** 32×32 pixels for items, 16×16 for small props
- **Palette:** Limited palette per item (8-12 colors max). Warm, muted tones.
- **Inspiration:** Stardew Valley's cozy interiors, Unpacking's item variety, Neko Atsume's charm
- **Isometric angle:** Standard 2:1 isometric (26.57°)
- **Character:** 24×24 pixel pet sprites, 4-frame idle animations
- **UI elements:** Pixel-art borders and buttons where appropriate, but readable modern text (SF Pro) for schedules and data

### Color Palette (Base)

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

## User Journey (First 7 Days)

**Day 1:**
- Download → Onboarding → Design ideal day (5 screens, ~2 min)
- Name your cat → Choose color
- See your schedule → Complete 2-3 blocks → Earn first coins
- Buy first small item (plant or book) → Place in room
- "Come back tomorrow to keep building your room!"

**Day 2-3:**
- Morning notification (if opted in): "[Cat name] is waiting for you!"
- Complete more blocks → Buy another item
- Room starts to feel like "yours"
- 3-day streak bonus feels rewarding

**Day 4-5:**
- Unlock a medium item → Room transformation is visible
- Pet has interacted with placed furniture (sits on chair, sleeps on bed)
- User screenshots room → shares on social

**Day 7:**
- 7-day streak bonus (75 coins) → Buy something special
- Room looks noticeably furnished
- Stats show weekly completion rate
- User thinks: "This is actually helping me stick to my routine"

---

## Success Metrics (V1)

| Metric | Target | Why |
|--------|--------|-----|
| Day 1 retention | >40% | Onboarding must be fast and delightful |
| Day 7 retention | >20% | Core loop must be sticky |
| Day 30 retention | >10% | Room decoration must provide ongoing motivation |
| Avg blocks completed/day | >5 | Schedule must feel achievable |
| Avg session length | 2-4 min | Short, daily check-ins (not time sinks) |
| Free → Pro conversion | >5% | Pro must feel like a clear upgrade |
| App Store rating | >4.5 | Quality bar |

---

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Room decoration novelty wears off | High | High | Seasonal items, rotating shop, room themes in v2 |
| Schedule feels too rigid | Medium | High | Allow out-of-order completion, "flex blocks", skip without penalty |
| Not enough items at launch | Medium | Medium | Target 40-50 items; prioritize variety over quantity |
| Widget feels static | Medium | Medium | Pet mood changes + progress updates give reason to glance |
| Users don't return after Day 3 | High | Critical | Day 2-3 rewards are front-loaded; push notification strategy |
| Pixel art production bottleneck | Medium | Medium | Use consistent style guide; consider AI-assisted pixel art for speed |
| iOS widget limitations frustrate | Low | Medium | Set expectations in onboarding; widget is a companion, not the app |

---

## V2+ Roadmap (Post-Launch)

Priority order based on expected retention/revenue impact:

1. **Multiple rooms** (bedroom, kitchen, study, balcony)
2. **More pet types** (dog, bunny, hamster, bird)
3. **Social: visit friends' rooms**
4. **Seasonal events** (Halloween room items, holiday pets)
5. **Apple Watch complication** (quick block completion)
6. **Habit insights** (which blocks you skip most, trends)
7. **Lock Screen widget**
8. **iPad support**
9. **Real calendar sync** (optional, for users who want it)
10. **Android version**
