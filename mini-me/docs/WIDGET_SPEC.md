# Widget Specification

> The widget IS the product. This doc is the single source of truth for the widget's behavior, sizes, scene mapping, pose mapping, and refresh strategy.

---

## Product Promise

When the user looks at their home screen, they see a pixel scene that reflects what they're doing right now. At a `work` block, mini-me sits at a pixel desk in a study scene. At `exercise`, mini-me does jumping jacks in a gym. At `social`, friends' mini-mes are visible in the scene too.

**No data clutter. No habit-tracker UI. The scene speaks for itself.**

---

## Activity → Scene + Pose Mapping

Drives every widget render. Implemented as `BlockCategory.toRoomType()` and `BlockCategory.toActivity()` extensions.

| `BlockCategory` (input) | `RoomType` (scene) | `PetActivity` (pose) | Sprite asset |
|---|---|---|---|
| `work` | `study` | `working` | `minime_working.png` |
| `learning` | `study` | `reading` | `minime_reading.png` |
| `creative` | `study` | `working` | `minime_working.png` |
| `exercise` | `gym` | `stretching` | `minime_exercising.png` |
| `nutrition` | `kitchen` | `eating` | `minime_eating.png` |
| `social` | `coffeeShop` | `slacking` | `minime_socializing.png` |
| `wellness` | `bedroom` | `idling` | `minime_idle.png` |
| `routine` | `bedroom` | `idling` | `minime_idle.png` |
| `rest` | `bedroom` | `sleeping` | `minime_sleeping.png` |
| `custom` | `bedroom` (fallback) | `idling` | `minime_idle.png` |
| **No active block** | `bedroom` | `idling` | `minime_idle.png` |

### Time-of-day overrides
- After 11pm or before user's wake-up time → always `bedroom + sleeping` regardless of category
- During the active block window otherwise → use the mapping above

---

## Scene Backgrounds (5 required)

Each is 246×246 isometric, transparent PNG, same proportions as `room_bedroom_empty.png`.

| Scene asset | Used for | Status |
|---|---|---|
| `room_bedroom_empty.png` | rest, idle, default | ⚠️ No dedicated asset — falls back to legacy `room_base_lofi_v2` |
| `room_study_empty.png` | work, learning, creative | ✅ Landed (246x246) |
| `room_gym_empty.png` | exercise | 🔴 Need |
| `room_kitchen_empty.png` | nutrition | ✅ Landed (246x246) |
| `room_coffeeshop_empty.png` | social | ✅ Landed (246x246) |

All scenes follow:
- Light source: top-left
- Palette: 11-color cozy warm (see `CLAUDE.md`)
- Anchor for character: bottom-center of designated activity slot in the scene

---

## Mini Me Activity Poses (8 required)

Character is rendered at 192×320 to match `minime_idle.png`. All poses transparent PNG, same dimensions, same palette.

| Pose asset | Activity | Description | Status |
|---|---|---|---|
| `minime_idle.png` | default | Standing, hands at side | ⚠️ Legacy (77x182, wrong dimensions — needs 192x320 regeneration) |
| `minime_happy.png` | celebrating | Arms up, smiling | ⚠️ Legacy (246x246, wrong dimensions — needs 192x320 regeneration) |
| `minime_sleeping.png` | rest | Lying down with Zzz | ⚠️ Legacy (246x246, wrong dimensions — needs 192x320 regeneration) |
| `minime_working.png` | work | Sitting at desk, typing | ✅ Landed (192x320) |
| `minime_exercising.png` | exercise | Mid-jumping-jack | ✅ Landed (192x320) |
| `minime_eating.png` | nutrition | Sitting at table, fork raised | ✅ Landed (192x320) |
| `minime_reading.png` | learning, creative | Sitting cross-legged with book | ✅ Landed (192x320) |
| `minime_socializing.png` | social | Standing chatting, gesture | ✅ Landed (192x320) |

### Animation Frames (widget cycling, 3 frames per activity)

| Frame set | Status |
|---|---|
| `minime_socializing_f1/f2/f3` | ✅ Landed (192x320) — ⚠️ Style mismatch with base pose |
| `minime_working_f1/f2/f3` | 🔴 Need |
| `minime_exercising_f1/f2/f3` | 🔴 Need |
| `minime_eating_f1/f2/f3` | 🔴 Need |
| `minime_reading_f1/f2/f3` | 🔴 Need |

---

## Widget Sizes

### Small (2×2)
- Pure scene snapshot fills the entire widget
- Activity label badge bottom-left in semi-transparent dark pill: "Working", "Exercise", etc.
- No data clutter — pure ambient pixel art

### Medium (4×2)
- Left half (square): scene snapshot
- Right half: activity name (large, bold rounded), progress fraction (`4/6 done`), coin count
- Scene is still the focal point — text is supportive

### Large (4×4)
- Full scene at fidelity
- Bottom 20%: subtle activity label, "Up next: [block name] at [time]"
- Right edge (v1.5): friend presence bubbles ("3 friends online")

### Lock screen — Circular
- Mini-me head only on transparent background
- Mood indicator color ring around edge

### Lock screen — Rectangular
- Activity icon + label ("🏋️ Exercise") with mini progress bar

### Lock screen — Inline
- Single line: "💪 Mini Me is exercising" or "✅ 4/6 today"

---

## Refresh Strategy

iOS limits widget timeline reloads to ~15-min intervals. Strategy:

1. **Schedule timeline entries at every block boundary.** When the user edits their schedule, the app calls `WidgetCenter.shared.reloadAllTimelines()`. Each boundary becomes a `TimelineEntry` with the corresponding `(scene, pose)` pair.

2. **Pre-render snapshots.** When the schedule is saved, the app pre-renders all required `(scene, pose)` PNGs to the App Group container as `room_diorama_<scene>_<pose>.png`. The widget reads these directly — never invokes SpriteKit at render time.

3. **Cache invalidation.** When the user changes their schedule, customizes their mini-me, or changes outfits, the snapshot cache is wiped and re-baked.

4. **Background refresh fallback.** If iOS doesn't fire the timeline at the boundary (it sometimes drifts), the next foreground app open re-syncs and pushes a timeline reload.

---

## Friends in Scene (v1.5)

### Data model
```swift
struct FriendPresence {
    let userID: String         // CloudKit recordID
    let displayName: String    // user-set, max 12 chars
    let currentScene: RoomType
    let currentPose: PetActivity
    let spriteVariant: String  // their mini-me palette/skin variant
    let lastUpdated: Date      // cache TTL ~30min
}
```

### Sync mechanism
- **CloudKit subscription** on a public container (no per-user auth pain — iCloud account is enough)
- Friend records updated every 15min (matches widget refresh)
- Privacy: only `currentScene + currentPose + name + sprite` syncs. **Never** schedule, completion data, or coins.

### Rendering rule
- When YOU have an active `social` block AND a friend has an active `social` block within the same 30-min window → friend's sprite is composited into your `coffeeShop` scene at slot 2
- Up to 3 friends in scene at once (slots 2, 3, 4 in the coffee shop layout)
- Friends' mini-mes are tappable in the in-app room view (deep-link to a "Hi from [Friend]!" reaction)

### Privacy-first pitch
> "Mini Me only syncs what you're up to right now — and only when you and a friend are *both* hanging out. No tracking, no surveillance, just vibes."

---

## Implementation Files

| Concern | File |
|---|---|
| Activity mapping | `App/Models/BlockCategory.swift` (add `toRoomType()`, `toActivity()` extensions) |
| Snapshot baking | `App/Services/WidgetDataService.swift` (extend to pre-render all `(scene, pose)` pairs) |
| Scene rendering | `App/Features/Room/RoomScene.swift` (parameterize `init(roomType:, activity:)`) |
| Widget reading | `Widget/MiniMeWidget.swift` (load `room_diorama_<scene>_<pose>.png` based on entry) |
| Friend sync (v1.5) | New: `App/Services/FriendPresenceService.swift` (CloudKit subscription) |

---

## Out of Scope (post-v1)

- Animated widgets (iOS 18+ Live Activities-style continuous animation) — too costly to ship in v1
- Custom scene themes (e.g., "neon city study" alternate skin) — v1.1 cosmetic IAP
- Pet co-presence (your pet *and* you in scene) — never. The character is YOU, not a pet.
- Multi-character scenes (you, a friend, and a stranger) — v2; raises moderation surface area
