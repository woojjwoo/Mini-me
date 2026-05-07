import CloudKit
import Foundation
import UIKit

/// Manages friend pairing and presence sync via CloudKit public database.
///
/// Privacy contract: only (displayName, currentScene, currentActivity, lastSeen)
/// are ever written to the cloud — never schedule details, location, or Apple ID.
///
/// Architecture:
///   - Each user has ONE `FriendPresence` record keyed by a stable local UUID.
///   - Pairing uses a 6-character invite code. User A shares their code; User B
///     enters it to look up A's record and link the two profiles.
///   - Friend list stored locally in UserDefaults as JSON [String] of userIDs.
///   - No push notifications in v1 — presence refreshes on app foreground.
///
/// CloudKit record type: `FriendPresence`
///   userID          String   — stable UUID (not Apple ID)
///   inviteCode      String   — 6-char alphanumeric, regeneratable
///   displayName     String   — pet name shown to friends
///   currentScene    String   — RoomType rawValue
///   currentActivity String   — PetActivity rawValue
///   lastSeen        Date

@Observable
final class FriendPresenceService {
    static let shared = FriendPresenceService()

    // MARK: - Published state

    /// Friends whose presence has been fetched. Refreshed on foreground.
    var friends: [FriendPresence] = []
    /// True while any CloudKit operation is in flight.
    var isLoading = false
    /// Last error message — shown in FriendsView if non-nil.
    var errorMessage: String?
    /// Last presence-publish error (network, quota, account). Shown as a
    /// non-blocking toast in FriendsView. Cleared on next successful publish.
    var lastPublishError: String?
    /// True when iCloud account is available.
    var iCloudAvailable = false

    // MARK: - Private

    private let container = CKContainer(identifier: "iCloud.com.woojjwoo.pixieme")
    private var db: CKDatabase { container.publicCloudDatabase }

    private enum Keys {
        static let userID     = "fp_user_id"
        static let inviteCode = "fp_invite_code"
        static let friendIDs  = "fp_friend_ids"
    }

    private let recordType = "FriendPresence"

    private init() {
        checkiCloudStatus()
    }

    // MARK: - Identity

    /// Stable local UUID — generated once, never changes.
    var myUserID: String {
        if let existing = UserDefaults.standard.string(forKey: Keys.userID) { return existing }
        let new = UUID().uuidString
        UserDefaults.standard.set(new, forKey: Keys.userID)
        return new
    }

    /// 6-char invite code — persisted locally, can be regenerated.
    var myInviteCode: String {
        if let existing = UserDefaults.standard.string(forKey: Keys.inviteCode) { return existing }
        return regenerateInviteCode()
    }

    @discardableResult
    func regenerateInviteCode() -> String {
        let chars = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789") // no I/O/0/1 — easy to type
        let code = String((0..<6).compactMap { _ in chars.randomElement() })
        UserDefaults.standard.set(code, forKey: Keys.inviteCode)
        return code
    }

    // MARK: - Friend list (local)

    var friendIDs: [String] {
        get {
            guard let data = UserDefaults.standard.data(forKey: Keys.friendIDs),
                  let ids = try? JSONDecoder().decode([String].self, from: data)
            else { return [] }
            return ids
        }
        set {
            UserDefaults.standard.set(try? JSONEncoder().encode(newValue), forKey: Keys.friendIDs)
        }
    }

    // MARK: - iCloud availability

    private func checkiCloudStatus() {
        container.accountStatus { [weak self] status, _ in
            DispatchQueue.main.async {
                self?.iCloudAvailable = (status == .available)
            }
        }
    }

    // MARK: - Write own presence

    /// Push the current (scene, activity, displayName) to CloudKit.
    /// Called by WidgetDataService.updateWidgetData and on app foreground.
    func publishPresence(displayName: String, scene: RoomType, activity: PetActivity) {
        guard iCloudAvailable else { return }

        let recordID = CKRecord.ID(recordName: myUserID)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        record["userID"]          = myUserID as CKRecordValue
        record["inviteCode"]      = myInviteCode as CKRecordValue
        record["displayName"]     = displayName as CKRecordValue
        record["currentScene"]    = scene.rawValue as CKRecordValue
        record["currentActivity"] = activity.rawValue as CKRecordValue
        record["lastSeen"]        = Date() as CKRecordValue

        let op = CKModifyRecordsOperation(recordsToSave: [record])
        op.savePolicy = .allKeys
        op.modifyRecordsResultBlock = { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success:
                    // Clear any previous error on success
                    self.lastPublishError = nil
                case .failure(let error):
                    // Surface the error so FriendsView can show a toast.
                    // Common cases: account temporarily unavailable, quota
                    // exceeded, network blip, permission revoked.
                    let ck = error as? CKError
                    self.lastPublishError = Self.publishErrorMessage(for: ck) ?? error.localizedDescription
                    #if DEBUG
                    print("[FriendPresence] publish failed: \(error)")
                    #endif
                }
            }
        }
        db.add(op)
    }

    /// Map common CKError codes to user-friendly messages. Returns nil for
    /// unknown codes — caller falls back to `error.localizedDescription`.
    private static func publishErrorMessage(for error: CKError?) -> String? {
        guard let error else { return nil }
        switch error.code {
        case .networkFailure, .networkUnavailable:
            return "Couldn't reach iCloud. Check your connection."
        case .notAuthenticated, .accountTemporarilyUnavailable:
            return "Sign into iCloud in Settings to share your presence."
        case .quotaExceeded:
            return "iCloud storage is full. Free up space to keep syncing."
        case .permissionFailure:
            return "Couldn't sync — iCloud Drive permission is off."
        case .requestRateLimited, .zoneBusy, .serviceUnavailable:
            return nil // transient; don't bother the user
        default:
            return nil
        }
    }

    // MARK: - Pairing via invite code

    /// Look up a friend by their 6-char invite code and add them.
    /// Calls completion on main thread with a success/failure result.
    func addFriend(inviteCode: String, completion: @escaping (Result<FriendPresence, FriendError>) -> Void) {
        guard iCloudAvailable else {
            completion(.failure(.iCloudUnavailable)); return
        }
        let code = inviteCode.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard code.count == 6 else {
            completion(.failure(.invalidCode)); return
        }
        guard code != myInviteCode else {
            completion(.failure(.ownCode)); return
        }

        let pred = NSPredicate(format: "inviteCode == %@", code)
        let query = CKQuery(recordType: recordType, predicate: pred)

        fetchWithRetry(query: query, limit: 1) { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure:
                DispatchQueue.main.async { completion(.failure(.networkError)) }
            case .success(let matchResults):
                guard let (_, recordResult) = matchResults.first,
                      case .success(let record) = recordResult,
                      let presence = FriendPresence(record: record)
                else {
                    DispatchQueue.main.async { completion(.failure(.notFound)) }
                    return
                }
                // Persist friend locally
                var ids = self.friendIDs
                if !ids.contains(presence.userID) { ids.append(presence.userID) }
                self.friendIDs = ids

                DispatchQueue.main.async {
                    if !self.friends.contains(where: { $0.userID == presence.userID }) {
                        self.friends.append(presence)
                    }
                    completion(.success(presence))
                }
            }
        }
    }

    func removeFriend(userID: String) {
        friendIDs = friendIDs.filter { $0 != userID }
        friends   = friends.filter   { $0.userID != userID }
    }

    // MARK: - Fetch friends' presence

    /// Refresh all friends' current scene/activity from CloudKit.
    func refreshFriends() {
        let ids = friendIDs
        guard !ids.isEmpty, iCloudAvailable else { return }

        isLoading = true
        errorMessage = nil

        let pred = NSPredicate(format: "userID IN %@", ids)
        let query = CKQuery(recordType: recordType, predicate: pred)

        fetchWithRetry(query: query, limit: 50) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                case .success(let matchResults):
                    self.friends = matchResults.compactMap { _, recordResult in
                        guard case .success(let record) = recordResult else { return nil }
                        return FriendPresence(record: record)
                    }
                    .sorted { ($0.lastSeen ?? .distantPast) > ($1.lastSeen ?? .distantPast) }
                }
            }
        }
    }

    // MARK: - Retry helper

    /// Per-call result type for the retry helper. Hides CKQueryCursor since
    /// neither caller paginates beyond the first 50 records.
    private typealias QueryMatches = [(CKRecord.ID, Result<CKRecord, Error>)]

    /// Wrap a CKQuery fetch in a small exponential-backoff retry. Transient
    /// errors (network blip, rate-limited, zone busy) get up to 3 tries;
    /// permanent errors (auth, permission) fail fast so the user can act.
    /// Backoff: 0.5s → 1s → 2s. Total worst-case latency: ~3.5s.
    private func fetchWithRetry(
        query: CKQuery,
        limit: Int,
        attempt: Int = 1,
        completion: @escaping (Result<QueryMatches, Error>) -> Void
    ) {
        db.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: limit) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let (matchResults, _)):
                completion(.success(matchResults))
            case .failure(let error):
                let nextAttempt = attempt + 1
                if Self.shouldRetry(error), nextAttempt <= 3 {
                    let delay = pow(2.0, Double(attempt - 1)) * 0.5 // 0.5, 1, 2
                    DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                        self.fetchWithRetry(
                            query: query,
                            limit: limit,
                            attempt: nextAttempt,
                            completion: completion
                        )
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
    }

    /// True for transient CKErrors that have a real chance of recovering on
    /// retry. Permanent errors (auth, permission, bad container) fail-fast.
    private static func shouldRetry(_ error: Error) -> Bool {
        guard let ck = error as? CKError else { return false }
        switch ck.code {
        case .networkFailure, .networkUnavailable,
             .requestRateLimited, .zoneBusy, .serviceUnavailable,
             .internalError:
            return true
        default:
            return false
        }
    }
}

// MARK: - FriendPresence model

struct FriendPresence: Identifiable {
    let id: String          // same as userID
    let userID: String
    let displayName: String
    let scene: RoomType
    let activity: PetActivity
    let lastSeen: Date?

    init?(record: CKRecord) {
        guard
            let userID      = record["userID"]      as? String,
            let name        = record["displayName"] as? String,
            let sceneRaw    = record["currentScene"]    as? String,
            let activityRaw = record["currentActivity"] as? String,
            let scene       = RoomType(rawValue: sceneRaw),
            let activity    = PetActivity(rawValue: activityRaw)
        else { return nil }

        self.id          = userID
        self.userID      = userID
        self.displayName = name
        self.scene       = scene
        self.activity    = activity
        self.lastSeen    = record["lastSeen"] as? Date
    }

    var sceneEmoji: String {
        switch scene {
        case .bedroom:    return "🛏️"
        case .study:      return "💻"
        case .kitchen:    return "🍳"
        case .gym:        return "🏃"
        case .coffeeShop: return "☕"
        case .rooftop:    return "🌆"
        }
    }

    /// Resolve a UIImage for the friend's current activity sprite.
    /// Cascades: new name → legacy timestamp → idle fallback. Mirrors the
    /// resolution logic in RoomScene.textureNameForActivity so what shows
    /// in the friends list matches what shows in the room.
    var sprite: UIImage? {
        let preferred: String
        switch activity {
        case .sleeping:  preferred = "minime_sleeping"
        case .working:   preferred = "minime_working"
        case .reading:   preferred = "minime_reading"
        case .eating:    preferred = "minime_eating"
        case .stretching: preferred = "minime_exercising"
        case .slacking:  preferred = "minime_socializing"
        case .walking, .idling: preferred = "minime_idle"
        }
        if let img = UIImage(named: preferred) { return img }
        // Legacy fallbacks for assets that haven't been re-exported yet.
        if activity == .sleeping, let img = UIImage(named: "minime_sleeping_1774711364657") { return img }
        return UIImage(named: "minime_idle_1774711350053")
    }

    var lastSeenLabel: String {
        guard let date = lastSeen else { return "Unknown" }
        let diff = Date.now.timeIntervalSince(date)
        if diff < 60        { return "Just now" }
        if diff < 3600      { return "\(Int(diff / 60))m ago" }
        if diff < 86400     { return "\(Int(diff / 3600))h ago" }
        return "\(Int(diff / 86400))d ago"
    }
}

// MARK: - Errors

enum FriendError: LocalizedError {
    case iCloudUnavailable
    case invalidCode
    case ownCode
    case notFound
    case networkError

    var errorDescription: String? {
        switch self {
        case .iCloudUnavailable: return "Sign into iCloud in Settings to add friends."
        case .invalidCode:       return "Invite codes are 6 characters."
        case .ownCode:           return "That's your own invite code!"
        case .notFound:          return "No mini-me found with that code. Double-check and try again."
        case .networkError:      return "Couldn't reach the server. Check your connection."
        }
    }
}
