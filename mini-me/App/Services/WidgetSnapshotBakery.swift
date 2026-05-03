import UIKit
import SpriteKit
import SwiftData
import WidgetKit

/// Pre-renders RoomScene snapshots for every (scene, activity) pair the user
/// will encounter in their day, so the widget always has an up-to-date PNG
/// ready when iOS asks for a timeline entry — even at block boundaries the
/// app isn't actively foregrounded for.
///
/// Off-screen rendering in SpriteKit is finicky: the SKView must briefly be
/// in a real view hierarchy for layout + textures to resolve. We attach a
/// hidden, alpha=0 SKView to the keyWindow, render, then detach.
///
/// All work is main-thread: SpriteKit is not thread-safe.
@MainActor
final class WidgetSnapshotBakery {
    static let shared = WidgetSnapshotBakery()

    /// Output snapshot dimensions. Matches the size the widget displays.
    /// Square so all widget sizes (small, medium left half, large) look
    /// consistent after their own aspectFill.
    private let snapshotSize = CGSize(width: 280, height: 280)

    private init() {}

    // MARK: - Public API

    /// Compute the unique (scene, activity) pairs the user will encounter
    /// across `schedule` and bake one snapshot per pair to the App Group
    /// container as `room_diorama_<scene>_<activity>.png`. Always includes
    /// the default `(.bedroom, .idling)` fallback for the no-active-block
    /// state. Idempotent — safe to call repeatedly.
    func bakeRequiredSnapshots(
        for schedule: DailySchedule,
        pet: Pet?,
        room: Room
    ) {
        var seen = Set<String>()
        var pairs: [(RoomType, PetActivity)] = []

        // Always include the default fallback (no-active-block state).
        pairs.append((.bedroom, .idling))
        seen.insert("bedroom_idling")

        // Plus the (scene, activity) pair derived from each block category.
        for block in schedule.blocks {
            let category = block.blockCategory
            let scene = category.sceneRoomType
            let activity = category.sceneActivity
            let key = "\(scene.rawValue)_\(activity.rawValue)"
            if seen.insert(key).inserted {
                pairs.append((scene, activity))
            }
        }

        // Render each pair and persist.
        for (scene, activity) in pairs {
            if let image = render(scene: scene, activity: activity, pet: pet, room: room) {
                WidgetDataService.shared.saveSceneSnapshot(image, scene: scene, activity: activity)
            }
        }

        // Tell iOS the widget timeline is stale so it re-renders immediately
        // instead of waiting for the next 15-min natural refresh cycle.
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Ambient fill color per scene type.
    /// Used as the solid background for the baked PNG so the widget never shows
    /// black bars where the isometric room art doesn't fill the canvas edges.
    private func ambientColor(for scene: RoomType) -> UIColor {
        switch scene {
        case .bedroom:    return UIColor(red: 0.10, green: 0.06, blue: 0.19, alpha: 1) // deep purple-night
        case .study:      return UIColor(red: 0.11, green: 0.09, blue: 0.06, alpha: 1) // warm dark wood
        case .gym:        return UIColor(red: 0.05, green: 0.10, blue: 0.05, alpha: 1) // dark green
        case .kitchen:    return UIColor(red: 0.10, green: 0.07, blue: 0.03, alpha: 1) // warm amber
        case .coffeeShop: return UIColor(red: 0.10, green: 0.05, blue: 0.05, alpha: 1) // warm brick
        case .rooftop:    return UIColor(red: 0.04, green: 0.05, blue: 0.10, alpha: 1) // night sky
        }
    }

    /// Render a single (scene, activity) pair off-screen. Public for testing.
    func render(
        scene: RoomType,
        activity: PetActivity,
        pet: Pet?,
        room: Room
    ) -> UIImage? {
        let ambient = ambientColor(for: scene)
        let frame = CGRect(origin: .zero, size: snapshotSize)
        let skView = SKView(frame: frame)
        skView.allowsTransparency = false
        skView.backgroundColor = ambient

        // SKView needs to be in a real window for layout + texture resolution.
        // We attach it to the keyWindow with alpha=0 so it's invisible to the
        // user, then yank it after capture.
        let attached: Bool
        if let window = currentKeyWindow() {
            skView.alpha = 0
            window.addSubview(skView)
            attached = true
        } else {
            // No window yet (e.g. very early in launch). Best-effort render —
            // texture(from:) may return nil, which is fine; the widget will
            // just fall back to the generic snapshot.
            attached = false
        }
        defer { if attached { skView.removeFromSuperview() } }

        let roomScene = RoomScene(
            room: room,
            pet: pet,
            mood: .neutral,
            streakCount: 0,
            size: snapshotSize,
            sceneRoomType: scene,
            initialActivity: activity
        )
        roomScene.scaleMode = .aspectFill
        roomScene.backgroundColor = SKColor(uiColor: ambient)
        skView.presentScene(roomScene)

        // One layout pass so the scene's didMove/setupRoom runs and textures load.
        skView.layoutIfNeeded()

        // Pull the rendered scene as a texture. cgImage() is the only reliable
        // bridge from SKTexture → UIImage that doesn't require the view to
        // currently be on-screen displaying.
        guard let texture = skView.texture(from: roomScene) else { return nil }
        return UIImage(cgImage: texture.cgImage())
    }

    // MARK: - Helpers

    private func currentKeyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ??
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first
    }
}
