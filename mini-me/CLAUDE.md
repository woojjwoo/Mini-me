# Mini Me - Project Memory

## What This App Is
Mini Me is a **virtual avatar / Tamagotchi-style iOS app** that gamifies daily routines. Users build a daily schedule of time blocks, earn coins by completing them, and use coins to buy furniture for an isometric pixel room. The user's **Mini Me** avatar lives in the room and reflects their progress through mood states — it's NOT a pet, it's a pixel version of YOU.

## Core Concept
The character is the user's **Mini Me** — a pixel avatar that represents them. It lives in their room, reacts to their daily habits, and celebrates their wins. Think of it as a digital twin that thrives when you follow your routine.

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
### COMPLETE
- **Living Diorama Engine**: Dynamic Z-sorting, Shadow projection, and "Walking Engine" (Stardew-style hops/directional flipping).
- **Dynamic Lighting (Time of Day)**: Screen overlays and glowing electronics that react to real-world hours (Morning, Day, Sunset, Night).
- **Milestone/Achievement System**: MilestoneService tracks streaks and block completions to unlock persistent room trophies.
- **Contextual Rituals (Greetings)**: Context-aware thought bubbles for morning greetings and evening reflections.
- **Soundscape/Haptic Juice**: Soft impact haptics and system sound "ticks" synced to character movement; multi-tone celebratory chimes.
- **Isometric Depth Sorting (Y-Sorting)**: Continuous per-frame depth calculation based on feet position.
- **v2: Outfit system** — 20 outfits, 6 slots, equip/unequip, auto-equip triggers
- **v2: Multiple rooms** — 6 room types, room shop, per-room decoration
- **v2: Notifications** — block reminders, streak warnings, morning greeting, mid-day nudge
- **v2: Weekend schedule** — separate weekend schedule creation and editing
- **v2: Habit insights** — 2-week trend, category breakdown, time-of-day analysis, streak history, fun stats
- **v2: Lock screen widget** — circular, rectangular, and inline widget families
- **v2: Sick day / manual status** — 4 statuses with mood override and auto-expiry
- **v2: Seasonal items** — 12 items across 5 seasons, availability logic
- **v2: Calendar sync** — EventKit integration, import calendar events as blocks
- **v2: Premium/Pro gating** — upgrade flow in settings (StoreKit integration placeholder)

### MISSING
- Handcrafted production art (currently using optimized emoji/placeholder sprites)
- StoreKit purchase flow (logic exists, UI/UX refinement needed)
- Unit tests

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
- `DESIGN_SPEC.md` — Full design specification (features, monetization, architecture, art direction)
- `docs/DESIGN_CONVERSATION.md` — Complete design conversation log (every critique, pivot, decision, and rationale)
- `docs/REFERENCES.md` — Art style references, competitor links, inspiration sources
