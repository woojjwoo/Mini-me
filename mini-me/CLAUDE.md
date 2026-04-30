# Mini Me - Project Memory

## What This App Is
Mini Me is a **widget-first iOS app**. The product is a home-screen widget where a pixel version of you lives your day — working when you work, exercising when you exercise, hanging out with your friends' mini-mes when you're being social. The phone app exists to **configure** the widget (set your schedule, customize your mini-me, add friends). **The widget IS the product.**

## Core Concept
The user's **Mini Me** is a pixel avatar that mirrors their real day on their home screen. The current `TimeBlock.category` drives which scene the widget shows (study/gym/kitchen/coffeeShop/bedroom) and which pose the character holds (typing/exercising/eating/socializing/sleeping). When friends are added (v1.5), their mini-mes appear in the same scene during shared `social` blocks.

**Why widget-first wins:** Pixel Pals (id6444085825) puts a *static* pet on the widget — pet doesn't do anything. Widgetable is co-parenting a Tamagotchi. Finch is app-only. **No competitor owns "your day, animated on your home screen."** That's the wedge.

## Art & Aesthetic Identity — NON-NEGOTIABLE
The entire app identity is **pixel art with a lo-fi cozy vibe**. This is the soul of the product, not a skin.
- **Isometric pixel art rooms** — the lo-fi album cover / cozy diorama aesthetic. Warm, miniature worlds.
- **Warm muted color palette**: cream (#F5E6D3), sage green (#5B8C5A), warm orange (#E8985E), gold (#FFD54F)
- **32×32 pixel sprites** for items, 24×24 for avatar. Crisp nearest-neighbor scaling, NO anti-aliasing.
- **Limited palette per asset** (8-12 colors max). Every item should feel handcrafted.
- **Light source from top-left** across all assets for consistency.
- **Lo-fi warmth over clinical polish** — pixel borders, retro UI elements, soft ambient glow.
- Think: lo-fi YouTube stream rooms, Stardew Valley interiors, cozy pixel diorama Pinterest boards.
- UI uses pixel-art borders/accents where appropriate, but SF Pro for readable text (schedules, data).
- **Every design decision must reinforce the cozy pixel aesthetic.** If it doesn't feel like it belongs on a lo-fi album cover, it doesn't belong in this app.

## Tech Stack
- **SwiftUI** + **SwiftData** (persistence)
- **SpriteKit** for isometric room rendering
- **WidgetKit** (small, medium, lock screen: circular, rectangular, inline)
- **UserNotifications** for block reminders, streak warnings
- **EventKit** for optional calendar sync
- Minimum iOS 17+ (SwiftData requirement)
- No backend — fully local/offline (data models structured for future server sync)

## Architecture
```
MiniMe/
├── App/              # MiniMeApp entry point, ContentView (onboarding gate + MainTabView)
├── Features/
│   ├── Onboarding/   # 6-step onboarding flow (welcome, wake-up, 3x block pickers, avatar setup)
│   ├── Schedule/     # DailyScheduleView + TimeBlockRow (Today tab)
│   ├── Room/         # IsometricRoomView + RoomScene (SpriteKit) + slot picker
│   ├── Shop/         # ShopView (4 tabs: Room Items, Outfits, Seasonal, Rooms)
│   ├── Outfits/      # OutfitView (equip/unequip per slot, auto-equip triggers)
│   ├── Insights/     # InsightsView (2-week trend, category breakdown, time-of-day, streaks, fun stats)
│   ├── Settings/     # SettingsView (pet editor, outfits, status, weekday/weekend schedule,
│   │                 #   notifications, calendar sync, pro upgrade, data reset)
│   │                 # + WeekendScheduleSetupSheet, StatusPickerSheet, CalendarSyncSheet
│   └── Stats/        # StatsView (streaks, weekly heatmap, lifetime stats) — legacy, replaced by Insights tab
├── Models/           # SwiftData models: Player, Pet, Room, RoomSlotAssignment, DailySchedule, TimeBlock, DayLog
│                     # Enums: BlockCategory, PetMood, PetColor, SlotType, RoomType, ManualStatus
│                     # Static catalogs: ShopItem + ItemCatalog, OutfitItem + OutfitCatalog, SeasonalItem + SeasonalCatalog
│                     # OutfitSlot enum (head, face, neck, top, hand, shoes)
│                     # Season enum (spring, summer, fall, winter, holiday)
├── Services/         # CoinService, PetMoodService, StreakService, WidgetDataService,
│                     # HapticService, SoundService, NotificationService, CalendarSyncService,
│                     # TimeOfDayService, MilestoneService
└── Shared/           # PixelTheme (colors, typography, Color hex init)

MiniMeWidget/      # Widget extension (small, medium, lock screen circular/rectangular/inline)
```

## Key Models
- **Player**: coins, ownedItemIDs, streaks, hasCompletedOnboarding, isPremium, manualStatusRaw, manualStatusExpiresAt, unlockedMilestoneIDs
- **Pet** (= Mini Me avatar): name, color/skin tone, accessoryIDs, equippedOutfitIDs
- **DailySchedule**: isWeekday flag, name ("Weekday"/"Weekend"), contains TimeBlocks
- **TimeBlock**: category, label, startHour/startMinute, durationMinutes, sortOrder
- **DayLog**: date, completedBlockIDs, coinsEarned, bonusCoinsEarned. One per day.
- **Room**: wallTheme, floorTheme, roomTypeRaw (RoomType), isActive, 12 RoomSlotAssignment slots
- **ShopItem**: static catalog (ItemCatalog) — 22 room items, 6 categories
- **OutfitItem**: 20 avatar outfits across 6 slots (head/face/neck/top/hand/shoes), with schedule auto-equip triggers
- **SeasonalItem**: 12 limited-time items across 5 seasons (spring/summer/fall/winter/holiday)

## Current Status (v2.5) — The Living Diorama Update

### CORE TO PIVOT — Widget-First Foundations
- **Living Diorama Engine**: Dynamic Z-sorting, Shadow projection, and "Walking Engine" (Stardew-style hops/directional flipping).
- **Dynamic Lighting (Time of Day)**: Screen overlays and glowing electronics that react to real-world hours.
- **Isometric Depth Sorting (Y-Sorting)**: Continuous per-frame depth calculation based on feet position.
- **Lock screen widget**: circular, rectangular, and inline widget families.
- **Snapshot pipeline**: `RoomScene` → `room_diorama.png` → App Group → widget rendering.
- **`PetActivity` enum** (idling, walking, working, reading, sleeping, eating, slacking, stretching) — the activity-pose scaffold already exists.
- **`RoomType` enum** (study, kitchen, gym, coffeeShop, rooftop) — these are the activity scenes (currently mis-framed as "rooms you buy").

### SECONDARY — Hide UI in v1, keep code
- **Outfits** (20 items, 6 slots, auto-equip triggers) — code stays, UI hidden until visual outfit overlay ships in v2.
- **Multiple-rooms shop** — reframe rooms as automatic activity-driven scene swaps, not purchasable rooms. Hide tab in v1.
- **Habit insights** (2-week trend, streaks, fun stats) — habit-tracker framing distracts from widget-first pitch. Hide tab in v1.
- **Calendar sync** — keep EventKit code, hide UI in v1.
- **Sick day / manual status** — keep, low priority.
- **Seasonal items** — keep, content lever for post-launch.
- **Pro upgrade** — currently sets `isPremium = true` client-side. Apple will reject. Hide UI in v1, re-introduce v1.1 with real StoreKit 2.
- **Notifications** — keep block reminders + streak warnings.
- **Milestone system** — keep.
- **Contextual greetings** — keep.

### MISSING — Required for Pivot Launch
- **Activity-aware widget engine**: `BlockCategory → RoomType + PetActivity` mapping piping into snapshot pipeline.
- **5 mini-me activity poses**: `minime_working`, `minime_exercising`, `minime_eating`, `minime_reading`, `minime_socializing`.
- **4 scene backgrounds**: study, gym, kitchen, coffeeShop (bedroom exists).
- **Friends layer (v1.5)**: CloudKit-based friend pairing + presence sync, friend mini-me composited into your scene during shared social blocks.
- **App Store assets**: full app icon set (13 sizes), screenshots showing widget on home screen, privacy policy URL.
- **StoreKit 2** for any future Pro tier — currently a stub.

## Important Notes
- **Physical Foundation**: For proper isometric depth, `visualNode.anchorPoint` MUST be `(0.5, 0)`.
- **Y-Sorting**: `RoomScene` update loop sets `zPosition = -position.y` for all world objects. Do not set manual Z-layers for floor-based items.
- **Uniform Scaling**: To avoid "crunching" pixel art, always scale X and Y proportionally or keep variations under 2%.
- SwiftData can't store enums directly — models use raw String values
- Widget shares data via App Groups (UserDefaults suiteName: `group.com.woojjwoo.pixieme.shared`)
- Room uses 12 fixed SlotType positions with hardcoded isometric coordinates
- Player.hasCompletedOnboarding gates the entire app (ContentView checks this)
- The `Pet` model is named "Pet" internally but represents the Mini Me avatar — do NOT refer to it as a pet in UI
- PetColor cases are skin tones: .orangeTabby = "Warm Tone", .black = "Dark Tone", .white = "Light Tone"
- ManualStatus auto-expires at end of day (manualStatusExpiresAt)
- Seasonal items use Season.isCurrentlyAvailable computed property based on current month
- OutfitItem.scheduleTrigger links outfits to BlockCategory rawValues for auto-equip
- CalendarSyncService.guessCategory does best-effort category mapping from event titles

## Project Documents
- `DESIGN_SPEC.md` — Full design specification (widget-first product, scope, architecture, art direction)
- `docs/WIDGET_SPEC.md` — Single source of truth for the widget product (sizes, scene mapping, pose mapping, refresh strategy)
- `docs/DESIGN_CONVERSATION.md` — Complete design conversation log (every critique, pivot, decision, and rationale)
- `docs/REFERENCES.md` — Art style references, competitor links, inspiration sources
