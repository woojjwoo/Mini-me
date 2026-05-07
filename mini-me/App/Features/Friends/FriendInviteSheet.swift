import SwiftUI

/// Shows the user's own invite code with share options.
/// Presented modally from FriendsView or YouView.
struct FriendInviteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var service = FriendPresenceService.shared
    @State private var showShareSheet = false
    @State private var showRegenerateConfirm = false
    @State private var copied = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#1A1209").ignoresSafeArea()

                VStack(spacing: 28) {
                    Spacer()

                    // Code display
                    VStack(spacing: 10) {
                        Text("Your invite code")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(hex: "#9E8B72"))

                        Text(service.myInviteCode)
                            .font(.system(size: 42, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(hex: "#FFD54F"))
                            .tracking(6)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 18)
                            .background(Color(hex: "#2A1E0F"))
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(hex: "#FFD54F").opacity(0.25), lineWidth: 1.5)
                            )
                    }

                    Text("Share this code with a friend.\nThey enter it to link your mini-mes.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(hex: "#9E8B72"))
                        .multilineTextAlignment(.center)

                    // Action buttons
                    VStack(spacing: 12) {
                        // Share via system sheet
                        Button {
                            showShareSheet = true
                        } label: {
                            Label("Share code", systemImage: "square.and.arrow.up")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color(hex: "#1A1209"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(hex: "#FFD54F"))
                                .cornerRadius(12)
                        }

                        // Copy to clipboard
                        Button {
                            UIPasteboard.general.string = service.myInviteCode
                            withAnimation { copied = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation { copied = false }
                            }
                        } label: {
                            Label(copied ? "Copied!" : "Copy code", systemImage: copied ? "checkmark" : "doc.on.doc")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(copied ? Color(hex: "#5B8C5A") : Color(hex: "#F5E6D3"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(hex: "#2A1E0F"))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            copied ? Color(hex: "#5B8C5A").opacity(0.6) : Color(hex: "#3A2E1A"),
                                            lineWidth: 1
                                        )
                                )
                        }
                    }
                    .padding(.horizontal, 32)

                    // Regenerate
                    Button {
                        showRegenerateConfirm = true
                    } label: {
                        Text("Generate new code")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(hex: "#9E8B72").opacity(0.7))
                            .underline()
                    }

                    Spacer()
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("Invite a Friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color(hex: "#FFD54F"))
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [inviteMessage])
        }
        .confirmationDialog(
            "Generate a new code?",
            isPresented: $showRegenerateConfirm,
            titleVisibility: .visible
        ) {
            Button("Generate new code", role: .destructive) {
                service.regenerateInviteCode()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Friends using your old code won't be able to pair again, but existing connections stay.")
        }
    }

    private var inviteMessage: String {
        "Add me on mini-me! Enter code \(service.myInviteCode) in the Friends tab. 🏡"
    }
}

// MARK: - UIActivityViewController wrapper

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uvc: UIActivityViewController, context: Context) {}
}
