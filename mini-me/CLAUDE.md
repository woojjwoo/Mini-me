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
│   │                 # + MiniMeAvatarView (SwiftUI Canvas pixel art renderer, no sprites needed)
│   ├── Schedule/     # DailyScheduleView + TimeBlockRow (Today tab)
│   ├── Room/         # IsometricRoomView + RoomScene (SpriteKit) + CharacterCompositeNode + slot picker
│   ├── Shop/         # ShopView (1 tab: Room Items only — outfits/seasonal removed for MVP)
│   ├── Settings/     # SettingsView + CharacterEditorView + CharacterCardView
│   │                 # (character appearance editor replaced old PetEditorSheet)
│   │                 # + WeekendScheduleSetupSheet, StatusPickerSheet, CalendarSyncSheet
│   └── Stats/        # StatsView — legacy, Insights tab removed in v3 cleanup
├── Models/           # SwiftData models: Player, Pet, Room, RoomSlotAssignment, DailySchedule, TimeBlock, DayLog
│                     # Enums: BlockCategory, PetMood, SlotType, RoomType, ManualStatus
│                     # CharacterOptions: HairStyle, HairColor, SkinTone, EyeSize, FaceShape, OutfitStyle
│                     # Static catalogs: ShopItem + ItemCatalog (furniture only)
├── Services/         # CoinService, PetMoodService, StreakService, WidgetDataService,
│                     # HapticService, SoundService, NotificationService, CalendarSyncService,
│                     # TimeOfDayService, MilestoneService
└── Shared/           # PixelTheme (colors, typography, Color hex init)

MiniMeWidget/      # Widget extension (small, medium, lock screen circular/rectangular/inline)
                   # Reads room_diorama.png from App Group container (written by RoomScene.takeWidgetSnapshot)
```

## Key Models
- **Player**: coins, ownedItemIDs, streaks, hasCompletedOnboarding, isPremium, manualStatusRaw, manualStatusExpiresAt, unlockedMilestoneIDs
- **Pet** (= Mini Me avatar): name, hairStyleRaw, hairColorRaw, skinToneRaw, eyeSizeRaw, faceShapeRaw, outfitStyleRaw, equippedOutfitIDs
- **DailySchedule**: isWeekday flag, name ("Weekday"/"Weekend"), contains TimeBlocks
- **TimeBlock**: category, label, startHour/startMinute, durationMinutes, sortOrder
- **DayLog**: date, completedBlockIDs, coinsEarned, bonusCoinsEarned. One per day.
- **Room**: wallTheme, floorTheme, roomTypeRaw (RoomType), isActive, 12 RoomSlotAssignment slots
- **ShopItem**: static catalog (ItemCatalog) — furniture room items only

## Character System (v3 — CharacterCompositeNode)
The avatar is no longer a single sprite. It's a layered `SKNode` subclass:
- `CharacterCompositeNode` renders body + outfit + hair + eyes as separate layers
- Uses `ImageRenderer` to rasterize `MiniMeAvatarView` (SwiftUI Canvas) into a texture at runtime
- `apply(pet:mood:)` rebuilds the composite whenever Pet properties change
- `invalidateCache()` forces a texture refresh (called before `apply` when customization changes)
- `SkinTone.color` returns a SwiftUI `Color` — use `UIColor($0.skinTone.color)` in SpriteKit contexts (requires `import SwiftUI`)
- `petBaseScale` is `0.35` (was `0.22` in the old single-sprite version)

## Avatar Activity Logic
`currentActivity` in `IsometricRoomView` is a computed property that:
1. Finds the current `TimeBlock` by matching current clock time to block start/end
2. If the block is work/study/learn type AND not yet completed in `DayLog` → returns `.slacking`
3. Otherwise delegates to `PetMoodService.currentActivity(for:)`

Activity drives avatar position and pose via `RoomScene.updateForActivity(_:)`:
- `.working` → walks to desk (squishes slightly in non-cafe rooms, sits in coffee shop)
- `.sleeping` → walks to bed, squishes flat
- `.slacking` → phone emoji overlay + character tilt + periodic put-away animation
- `.reading`, `.idling` in coffee shop → sitting legs with dangle/kick animation
- All others → center floor

## Current Status (v3) — Wired & Shippable
### COMPLETE
- **Living Diorama Engine**: Dynamic Z-sorting, shadow projection, "Walking Engine" (Stardew-style hops/directional flipping)
- **CharacterCompositeNode**: Layered avatar renderer with live customization — hair, skin tone, eye size, face shape, outfit style
- **Character editor**: Full appearance customization in Settings (CharacterEditorView) and during onboarding (PetSetupStep)
- **Slacking state**: Phone overlay + character tilt when in incomplete work/study/learn block
- **Sitting legs**: Dangling pixel legs with swing + kick animations for coffee shop seating
- **Activity wiring**: Avatar reacts immediately on Room tab open (`.onAppear`) and refreshes every 5 min via timer
- **Widget snapshot**: `takeWidgetSnapshot()` fires on appear + after activity changes; `WidgetCenter.reloadAllTimelines()` fires after block completion
- **Full notification suite**: Morning greeting (onboarding), mid-day nudge + streak warning (Settings toggle), block reminders
- **Scene caching**: `[UUID: RoomScene]` prevents recreation on every SwiftUI re-render
- **Dynamic Lighting (Time of Day)**: Screen overlays and glowing electronics react to real-world hours
- **Milestone/Achievement System**: MilestoneService unlocks persistent room trophies
- **Contextual Rituals**: Context-aware thought bubbles for morning greetings and evening reflections
- **Soundscape/Haptic Juice**: Soft impact haptics and system sound "ticks" synced to movement
- **v2: Multiple rooms** — 6 room types, per-room decoration
- **v2: Notifications** — block reminders, streak warnings, morning greeting, mid-day nudge
- **v2: Weekend schedule** — separate weekend schedule creation and editing
- **v2: Lock screen widget** — circular, rectangular, and inline widget families
- **v2: Sick day / manual status** — 4 statuses with mood override and auto-expiry
- **v2: Calendar sync** — EventKit integration, import calendar events as blocks
- **v2: Premium/Pro gating** — upgrade flow in settings (StoreKit placeholder)

### REMOVED IN v3 CLEANUP
- Insights tab (removed — too early, not enough data to be meaningful)
- Outfits system (removed from Shop — complexity not worth it at MVP scale)
- Seasonal items (removed — requires ongoing content work)

### STILL MISSING
- Handcrafted production art (currently using Canvas-rendered pixel art via MiniMeAvatarView)
- StoreKit purchase flow (logic exists, UI/UX refinement needed)
- Unit tests

## Important Notes
- **Character anchor**: `compositeNode` (the `CharacterCompositeNode` inside `petNode`) uses anchor point `(0.5, 0)` — feet on floor.
- **Y-Sorting**: `RoomScene` update loop sets `zPosition = -position.y` for all world objects. Do not set manual Z-layers for floor-based items.
- **Uniform Scaling**: To avoid pixel art "crunching", always scale X and Y proportionally or keep variations under 2%.
- **SwiftUI in SpriteKit**: `RoomScene.swift` imports both `SpriteKit` and `SwiftUI` — needed for `UIColor(Color)` initializer (`SkinTone.color` returns SwiftUI `Color`).
- SwiftData can't store enums directly — models use raw String values (`hairStyleRaw`, `skinToneRaw`, etc.)
- Widget shares data via App Groups: `group.com.woojjwoo.pixieme.shared`
- App Bundle ID: `com.woojjwoo.pixieme`
- Room uses 12 fixed SlotType positions with hardcoded isometric coordinates
- Player.hasCompletedOnboarding gates the entire app (ContentView checks this)
- The `Pet` model is named "Pet" internally but represents the Mini Me avatar — do NOT refer to it as a pet in UI
- ManualStatus auto-expires at end of day (manualStatusExpiresAt)
- CalendarSyncService.guessCategory does best-effort category mapping from event titles

## Branch Strategy
- `claude/study-pixel-pals-design-Z7965` — main branch (Living Diorama engine, character system)
- `claude/session-planning` — activity wiring, slacking animations, notification suite (open PR #1)

## Project Documents
- `docs/DESIGN_CONVERSATION.md` — Complete design conversation log (every critique, pivot, decision, and rationale)
- `docs/REFERENCES.md` — Art style references, competitor links, inspiration sources
