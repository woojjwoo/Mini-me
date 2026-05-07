import SwiftUI

/// One-time privacy priming sheet shown before the Friends feature is unlocked.
/// Explains exactly what mini-me syncs — and what it never touches — so the
/// user feels informed before iCloud starts syncing their presence.
///
/// Shown once: `fp_privacy_accepted` in UserDefaults gates it.
struct FriendsPermissionSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onAccept: () -> Void

    var body: some View {
        ZStack {
            Color(hex: "#1A1209").ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 10) {
                    Text("🏡")
                        .font(.system(size: 56))
                        .padding(.top, 40)

                    Text("Friends on mini-me")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color(hex: "#F5E6D3"))

                    Text("See what your friends' mini-mes are up to\n— and let them see yours.")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "#9E8B72"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Spacer().frame(height: 32)

                // What we sync
                privacyCard(
                    icon: "checkmark.circle.fill",
                    iconColor: Color(hex: "#5B8C5A"),
                    title: "What mini-me syncs",
                    rows: [
                        ("🏃", "Your current scene (e.g. coffee shop)"),
                        ("💻", "Your current activity (e.g. working)"),
                        ("🏷️", "Your display name"),
                        ("🕐", "When you were last active"),
                    ]
                )

                Spacer().frame(height: 12)

                // What we never sync
                privacyCard(
                    icon: "lock.fill",
                    iconColor: Color(hex: "#E8985E"),
                    title: "What mini-me never touches",
                    rows: [
                        ("📅", "Your schedule details or block labels"),
                        ("📍", "Your location"),
                        ("🍎", "Your Apple ID or email"),
                        ("📆", "Your calendar"),
                    ]
                )

                Spacer()

                // CTA
                VStack(spacing: 10) {
                    Button {
                        UserDefaults.standard.set(true, forKey: FriendsPermissionSheet.acceptedKey)
                        dismiss()
                        onAccept()
                    } label: {
                        Text("Sounds good — show me friends")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color(hex: "#1A1209"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color(hex: "#FFD54F"))
                            .cornerRadius(12)
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text("Not now")
                            .font(.system(size: 13))
                            .foregroundStyle(Color(hex: "#9E8B72"))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
            }
        }
    }

    // MARK: - Helpers

    static let acceptedKey = "fp_privacy_accepted"

    static var hasAccepted: Bool {
        UserDefaults.standard.bool(forKey: acceptedKey)
    }

    private func privacyCard(
        icon: String,
        iconColor: Color,
        title: String,
        rows: [(String, String)]
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
                    .font(.system(size: 13, weight: .semibold))
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(hex: "#F5E6D3"))
            }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(rows, id: \.1) { emoji, text in
                    HStack(spacing: 8) {
                        Text(emoji)
                            .font(.system(size: 14))
                            .frame(width: 22)
                        Text(text)
                            .font(.system(size: 13))
                            .foregroundStyle(Color(hex: "#C8A882"))
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#221810"))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#3A2E1A"), lineWidth: 1))
        .padding(.horizontal, 24)
    }
}
