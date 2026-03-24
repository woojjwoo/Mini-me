import AudioToolbox

/// Lightweight sound effect player using system sounds.
/// Uses AudioServicesPlaySystemSound for zero-latency playback without audio session setup.
enum SoundService {

    // MARK: - System Sound IDs (built-in iOS sounds)
    // These are reliable system sounds that don't require bundled audio files.

    /// Coin collection / reward earned
    static func playCoinSound() {
        AudioServicesPlaySystemSound(1057) // short "tink" sound
    }

    /// Block completed successfully
    static func playCompleteSound() {
        AudioServicesPlaySystemSound(1025) // short positive chime
    }

    /// Purchase confirmed
    static func playPurchaseSound() {
        AudioServicesPlaySystemSound(1052) // register-like sound
    }

    /// Perfect day / celebration
    static func playCelebrationSound() {
        AudioServicesPlaySystemSound(1026) // ascending chime
    }

    /// Error / can't afford
    static func playErrorSound() {
        AudioServicesPlaySystemSound(1053) // short error tone
    }

    /// Navigation / tap
    static func playTapSound() {
        AudioServicesPlaySystemSound(1104) // subtle click
    }
}
