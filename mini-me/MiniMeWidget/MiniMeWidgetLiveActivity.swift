import ActivityKit
import WidgetKit
import SwiftUI
import UIKit

// MARK: - Attributes (must match what the main app passes to ActivityKit)

struct MiniMeActivityAttributes: ActivityAttributes {
    // Fixed at start of activity
    let petName: String
    let blockLabel: String   // e.g. "Deep Work"
    let category: String     // e.g. "work"

    public struct ContentState: Codable, Hashable {
        // Updated dynamically while the block is running
        var sceneRaw: String        // RoomType.rawValue
        var activityRaw: String     // PetActivity.rawValue
        var minutesRemaining: Int
        var completedBlocks: Int
        var totalBlocks: Int

        var scene: RoomType    { RoomType(rawValue: sceneRaw)       ?? .bedroom }
        var activity: PetActivity { PetActivity(rawValue: activityRaw) ?? .idling }
        var completionRate: Double {
            guard totalBlocks > 0 else { return 0 }
            return Double(completedBlocks) / Double(totalBlocks)
        }
    }
}

// MARK: - Live Activity Widget

struct MiniMeWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MiniMeActivityAttributes.self) { context in
            // Lock screen / banner
            HStack(spacing: 12) {
                // Scene snapshot thumbnail
                if let image = loadSceneSnapshot(
                    scene: context.state.scene,
                    activity: context.state.activity) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 52, height: 52)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "E8985E").opacity(0.3))
                        .frame(width: 52, height: 52)
                        .overlay(Text(context.state.scene.displayName)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(Color(hex: "2D2040")))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(context.attributes.blockLabel)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "2D2040"))
                    Text("\(context.state.minutesRemaining) min left  ·  \(context.state.completedBlocks)/\(context.state.totalBlocks) done")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "2D2040").opacity(0.7))
                    ProgressView(value: context.state.completionRate)
                        .tint(Color(hex: "E8985E"))
                }
                Spacer()
            }
            .padding(12)
            .activityBackgroundTint(Color(hex: "F5E6D3"))
            .activitySystemActionForegroundColor(Color(hex: "2D2040"))

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded (long-press)
                DynamicIslandExpandedRegion(.leading) {
                    if let image = loadSceneSnapshot(
                        scene: context.state.scene,
                        activity: context.state.activity) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 44, height: 44)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.leading, 4)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(context.state.minutesRemaining)m")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("remaining")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.trailing, 4)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.attributes.blockLabel)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        Spacer()
                        ProgressView(value: context.state.completionRate)
                            .tint(Color(hex: "E8985E"))
                            .frame(width: 80)
                    }
                    .padding(.horizontal, 8)
                }
            } compactLeading: {
                // Tiny pill — left side
                if let image = loadSceneSnapshot(
                    scene: context.state.scene,
                    activity: context.state.activity) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 20, height: 20)
                        .clipShape(Circle())
                }
            } compactTrailing: {
                // Tiny pill — right side: minutes remaining
                Text("\(context.state.minutesRemaining)m")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            } minimal: {
                // Single dot view
                if let image = loadSceneSnapshot(
                    scene: context.state.scene,
                    activity: context.state.activity) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                }
            }
            .widgetURL(URL(string: "pixieme://today"))
            .keylineTint(Color(hex: "E8985E"))
        }
    }
}
