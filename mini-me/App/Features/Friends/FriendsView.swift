import SwiftUI

/// Shows all linked friends with their current scene/activity.
/// Entry point: YouView → "Friends" row → NavigationLink to here.
struct FriendsView: View {
    @State private var service = FriendPresenceService.shared
    @State private var showInviteSheet = false
    @State private var showAddSheet = false
    @State private var addCodeInput = ""
    @State private var addError: String?
    @State private var addSuccess: FriendPresence?

    var body: some View {
        ZStack {
            Color(hex: "#1A1209").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    headerCard
                    if !service.iCloudAvailable {
                        iCloudBanner
                    }
                    if service.lastPublishError != nil {
                        publishErrorToast
                    }
                    if service.isLoading {
                        ProgressView()
                            .tint(Color(hex: "#FFD54F"))
                            .padding(.top, 32)
                    } else if service.friends.isEmpty {
                        emptyState
                    } else {
                        friendsList
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Friends")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Share my code", systemImage: "square.and.arrow.up") {
                        showInviteSheet = true
                    }
                    Button("Add a friend", systemImage: "person.badge.plus") {
                        showAddSheet = true
                    }
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color(hex: "#FFD54F"))
                }
            }
        }
        .sheet(isPresented: $showInviteSheet) {
            FriendInviteSheet()
        }
        .sheet(isPresented: $showAddSheet) {
            addFriendSheet
        }
        .onAppear {
            service.refreshFriends()
        }
    }

    // MARK: - Subviews

    private var headerCard: some View {
        VStack(spacing: 6) {
            Text("Your mini-me in their world.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color(hex: "#9E8B72"))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }

    private var iCloudBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "icloud.slash")
                    .foregroundStyle(Color(hex: "#E8985E"))
                Text("Sign in to iCloud in Settings to see friends.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: "#C8A882"))
            }

            Button {
                openICloudSettings()
            } label: {
                Label("Open Settings", systemImage: "arrow.up.right.square")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(hex: "#FFD54F"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(hex: "#FFD54F").opacity(0.5), lineWidth: 1))
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#2A1E0F"))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#E8985E").opacity(0.4), lineWidth: 1))
    }

    /// Deep link to the iOS Settings app at the iCloud account pane.
    /// Falls back to the root Settings page if the deep link is rejected.
    private func openICloudSettings() {
        // App-prefs:CASTLE works on most iOS versions; if rejected, the
        // generic UIApplication.openSettingsURLString is the safe fallback.
        if let url = URL(string: "App-prefs:CASTLE"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    /// Inline non-blocking toast shown when `lastPublishError` is non-nil.
    /// Tapping the toast dismisses it (and clears the error).
    private var publishErrorToast: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color(hex: "#E8985E"))
            Text(service.lastPublishError ?? "")
                .font(.system(size: 12))
                .foregroundStyle(Color(hex: "#C8A882"))
                .lineLimit(2)
            Spacer()
            Button {
                service.lastPublishError = nil
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(Color(hex: "#9E8B72"))
                    .font(.system(size: 11, weight: .medium))
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#2A1E0F"))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#E8985E").opacity(0.35), lineWidth: 1))
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Text("🏡")
                .font(.system(size: 48))
            Text("No friends yet")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(hex: "#F5E6D3"))
            Text("Share your invite code\nor enter a friend's to connect.")
                .font(.system(size: 13))
                .foregroundStyle(Color(hex: "#9E8B72"))
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                Button {
                    showInviteSheet = true
                } label: {
                    Label("Share code", systemImage: "square.and.arrow.up")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color(hex: "#1A1209"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(Color(hex: "#FFD54F"))
                        .cornerRadius(8)
                }

                Button {
                    showAddSheet = true
                } label: {
                    Label("Add friend", systemImage: "person.badge.plus")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color(hex: "#FFD54F"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "#FFD54F").opacity(0.5), lineWidth: 1))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 48)
    }

    private var friendsList: some View {
        VStack(spacing: 10) {
            ForEach(service.friends) { friend in
                FriendRow(friend: friend) {
                    service.removeFriend(userID: friend.userID)
                }
            }
        }
    }

    // MARK: - Add Friend Sheet

    private var addFriendSheet: some View {
        NavigationView {
            ZStack {
                Color(hex: "#1A1209").ignoresSafeArea()
                VStack(spacing: 20) {
                    Text("Enter your friend's 6-character invite code.")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "#9E8B72"))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)

                    TextField("e.g. ABC123", text: $addCodeInput)
                        .textInputAutocapitalization(.characters)
                        .disableAutocorrection(true)
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(hex: "#FFD54F"))
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 12)
                        .background(Color(hex: "#2A1E0F"))
                        .cornerRadius(10)
                        .padding(.horizontal, 32)
                        .onChange(of: addCodeInput) { _, v in
                            addCodeInput = String(v.prefix(6)).uppercased()
                        }

                    if let err = addError {
                        Text(err)
                            .font(.system(size: 13))
                            .foregroundStyle(Color(hex: "#E8985E"))
                            .multilineTextAlignment(.center)
                    }

                    if let s = addSuccess {
                        Text("✅ \(s.displayName) added!")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color(hex: "#5B8C5A"))
                    }

                    Button {
                        addError = nil
                        addSuccess = nil
                        service.addFriend(inviteCode: addCodeInput) { result in
                            switch result {
                            case .success(let p):
                                addSuccess = p
                                addCodeInput = ""
                            case .failure(let e):
                                addError = e.localizedDescription
                            }
                        }
                    } label: {
                        Text("Connect")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color(hex: "#1A1209"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(addCodeInput.count == 6 ? Color(hex: "#FFD54F") : Color(hex: "#3A2E1A"))
                            .cornerRadius(10)
                            .padding(.horizontal, 32)
                    }
                    .disabled(addCodeInput.count != 6)

                    Spacer()
                }
            }
            .navigationTitle("Add Friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { showAddSheet = false }
                        .foregroundStyle(Color(hex: "#9E8B72"))
                }
            }
        }
    }
}

// MARK: - Friend Row

private struct FriendRow: View {
    let friend: FriendPresence
    let onRemove: () -> Void
    @State private var showConfirm = false

    var body: some View {
        HStack(spacing: 12) {
            // Scene emoji badge
            Text(friend.sceneEmoji)
                .font(.system(size: 28))
                .frame(width: 48, height: 48)
                .background(Color(hex: "#2A1E0F"))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 3) {
                Text(friend.displayName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(hex: "#F5E6D3"))

                HStack(spacing: 4) {
                    Text(friend.activity.rawValue.capitalized)
                        .font(.system(size: 12))
                        .foregroundStyle(Color(hex: "#9E8B72"))
                    Text("·")
                        .foregroundStyle(Color(hex: "#9E8B72").opacity(0.5))
                        .font(.system(size: 12))
                    Text(friend.scene.rawValue.capitalized)
                        .font(.system(size: 12))
                        .foregroundStyle(Color(hex: "#9E8B72"))
                }
            }

            Spacer()

            Text(friend.lastSeenLabel)
                .font(.system(size: 11))
                .foregroundStyle(Color(hex: "#9E8B72").opacity(0.7))
        }
        .padding(12)
        .background(Color(hex: "#221810"))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#3A2E1A"), lineWidth: 1))
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                showConfirm = true
            } label: {
                Label("Remove", systemImage: "person.badge.minus")
            }
        }
        .confirmationDialog("Remove \(friend.displayName)?", isPresented: $showConfirm, titleVisibility: .visible) {
            Button("Remove", role: .destructive, action: onRemove)
            Button("Cancel", role: .cancel) {}
        }
    }
}
