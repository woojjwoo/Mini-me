# Pixel Pals - Project Memory

## What This App Is
Pixel Pals is a **virtual pet / Tamagotchi-style iOS app** that gamifies daily routines. Users build a daily schedule of time blocks, earn coins by completing them, and use coins to buy furniture for an isometric pixel room. A virtual cat pet reflects the user's progress through mood states.

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
│   ├── Onboarding/   # 6-step onboarding flow (welcome, wake-up, 3x block pickers, pet setup)
│   ├── Schedule/     # DailyScheduleView + TimeBlockRow (Today tab)
│   ├── Room/         # IsometricRoomView + RoomScene (SpriteKit) + slot picker
│   ├── Shop/         # ShopView with category filters, purchase flow
│   ├── Settings/     # SettingsView (schedule editing, pet customization, app preferences)
│   └── Stats/        # StatsView (streaks, weekly heatmap, lifetime stats)
├── Models/           # SwiftData models: Player, Pet, Room, RoomSlotAssignment, DailySchedule, TimeBlock, DayLog
│                     # Also: BlockCategory enum, ShopItem + ItemCatalog, SlotType enum, PetMood/PetColor enums
├── Services/         # CoinService (rewards + purchases), PetMoodService, StreakService,
│                     # WidgetDataService, HapticService, SoundService
└── Shared/           # PixelTheme (colors, typography, Color hex init)

PixelPalsWidget/      # Widget extension (TimelineProvider, small/medium widget views)
```

## Key Models
- **Player**: coins, ownedItemIDs, streaks, hasCompletedOnboarding, isPremium
- **Pet**: name, color (orange/black/white), accessoryIDs
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

## Pet Mood Logic (PetMoodService)
Mood determined by: time of day, completion rate, hours since last completion, streak
States: sleeping, happy, neutral, bored, sad, celebrating

## Current Status
- All core game systems: COMPLETE
- Settings screen: COMPLETE (schedule editing, pet customization, data reset)
- Haptic feedback + sound effects: COMPLETE (services in place)
- Pet sprites / furniture art: MISSING (using emoji + colored placeholder boxes)
- Notifications: NOT IMPLEMENTED
- Unit tests: NOT WRITTEN

## Important Notes
- SwiftData can't store enums directly — models use raw String values
- Widget shares data via App Groups (UserDefaults suiteName)
- Room uses 12 fixed SlotType positions with hardcoded isometric coordinates
- Onboarding creates weekday schedule only; weekend schedule support exists in model but needs UI
- Player.hasCompletedOnboarding gates the entire app (ContentView checks this)
