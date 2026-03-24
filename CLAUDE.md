# Mini Me - Project Memory

## What This App Is
Mini Me is a **virtual avatar / Tamagotchi-style iOS app** that gamifies daily routines. Users build a daily schedule of time blocks, earn coins by completing them, and use coins to buy furniture for an isometric pixel room. The user's **Mini Me** avatar lives in the room and reflects their progress through mood states — it's NOT a pet, it's a pixel version of YOU.

## Core Concept
The character is the user's **Mini Me** — a pixel avatar that represents them. It lives in their room, reacts to their daily habits, and celebrates their wins. Think of it as a digital twin that thrives when you follow your routine.

## Tech Stack
- **SwiftUI** + **SwiftData** (persistence)
- **SpriteKit** for isometric room rendering
- iOS Widget via **WidgetKit** (small + medium sizes)
- Minimum iOS 17+ (SwiftData requirement)
- No backend — fully local/offline

## Architecture
```
PixelPals/
├── App/              # PixelPalsApp entry point, ContentView (onboarding gate + MainTabView)
├── Features/
│   ├── Onboarding/   # 6-step onboarding flow (welcome, wake-up, 3x block pickers, avatar setup)
│   ├── Schedule/     # DailyScheduleView + TimeBlockRow (Today tab)
│   ├── Room/         # IsometricRoomView + RoomScene (SpriteKit) + slot picker
│   ├── Shop/         # ShopView with category filters, purchase flow
│   ├── Settings/     # SettingsView (schedule editing, avatar customization, data reset)
│   └── Stats/        # StatsView (streaks, weekly heatmap, lifetime stats)
├── Models/           # SwiftData models: Player, Pet (avatar), Room, RoomSlotAssignment, DailySchedule, TimeBlock, DayLog
│                     # Note: "Pet" model name is legacy — it represents the Mini Me avatar
│                     # Also: BlockCategory enum, ShopItem + ItemCatalog, SlotType enum, PetMood/PetColor enums
├── Services/         # CoinService (rewards + purchases), PetMoodService, StreakService,
│                     # WidgetDataService, HapticService, SoundService
└── Shared/           # PixelTheme (colors, typography, Color hex init)

PixelPalsWidget/      # Widget extension (TimelineProvider, small/medium widget views)
```

## Key Models
- **Player**: coins, ownedItemIDs, streaks, hasCompletedOnboarding, isPremium
- **Pet** (= Mini Me avatar): name, color/skin tone (warm/dark/light), accessoryIDs (outfits)
- **DailySchedule**: isWeekday flag, contains TimeBlocks. Only weekday created in onboarding currently.
- **TimeBlock**: category, label, startHour/startMinute, durationMinutes, sortOrder
- **DayLog**: date, completedBlockIDs, coinsEarned. One per day.
- **Room**: wallTheme, floorTheme, 12 RoomSlotAssignment slots
- **ShopItem**: static catalog (ItemCatalog) with 22 items, 6 categories, slot-based placement

## Coin Economy
- 10 coins per block completed
- 15 coins for completing all morning/afternoon/evening blocks
- 50 coins for perfect day
- Streak bonuses: 25 (3-day), 75 (7-day), 300 (30-day)
- Items cost 30-800 coins

## Avatar Mood Logic (PetMoodService)
Mood determined by: time of day, completion rate, hours since last completion, streak
States: sleeping, happy, neutral, bored, sad, celebrating
The Mini Me's mood reflects how well the user is following their routine.

## Current Status
- All core game systems: COMPLETE
- Settings screen: COMPLETE (schedule editing, avatar customization, data reset)
- Haptic feedback + sound effects: COMPLETE (services in place)
- Avatar sprites / furniture art: MISSING (using emoji + colored placeholder boxes)
- Notifications: NOT IMPLEMENTED
- Unit tests: NOT WRITTEN

## Important Notes
- SwiftData can't store enums directly — models use raw String values
- Widget shares data via App Groups (UserDefaults suiteName)
- Room uses 12 fixed SlotType positions with hardcoded isometric coordinates
- Onboarding creates weekday schedule only; weekend schedule support exists in model but needs UI
- Player.hasCompletedOnboarding gates the entire app (ContentView checks this)
- The `Pet` model is named "Pet" internally but represents the user's Mini Me avatar — do NOT refer to it as a pet in UI
- PetColor cases are skin tones: .orangeTabby = "Warm Tone", .black = "Dark Tone", .white = "Light Tone"
