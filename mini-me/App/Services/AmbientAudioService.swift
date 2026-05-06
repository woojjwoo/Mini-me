import AVFoundation
import UIKit

/// Plays a looping lo-fi background track while the app is in the foreground.
/// Controlled by the "Ambient music" toggle in YouView. Persists preference
/// via UserDefaults. Silent-fails gracefully when the asset is not yet in the
/// bundle — the toggle wires up and the playback starts as soon as the file lands.
///
/// Audio session behaviour:
///   - Category: `.playback` so it continues if the screen dims.
///   - Option: `.duckOthers` so podcasts / calls fade under our music.
///   - Deactivates the session on stop so other apps restore their volume.
///
/// Usage:
///   AmbientAudioService.shared.startPlayback()
///   AmbientAudioService.shared.stopPlayback()
final class AmbientAudioService {
    static let shared = AmbientAudioService()

    static let userDefaultsKey = "ambient_music_enabled"

    private var player: AVAudioPlayer?
    private var fadeTimer: Timer?

    /// Target playback volume (0–1). Kept intentionally below 1.0 so the
    /// lo-fi sits "behind" the UI rather than on top of it.
    private let targetVolume: Float = 0.60

    private init() {
        // Observe app lifecycle so we pause in the background and resume in
        // the foreground — avoids battery drain and respects iOS audio rules.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    // MARK: - Public API

    /// Begin looping the lo-fi track. Fades in over 1.5 s.
    /// Safe to call when already playing — no-op if a player is active.
    func startPlayback() {
        guard player == nil else { return }
        guard let url = Bundle.main.url(forResource: "lofi_loop", withExtension: "m4a") else {
            // Asset not in bundle yet — the toggle still persists; playback
            // will begin automatically once the file is added.
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                options: [.mixWithOthers, .duckOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)

            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.numberOfLoops = -1   // infinite loop
            newPlayer.volume = 0
            newPlayer.prepareToPlay()
            newPlayer.play()
            player = newPlayer

            fadeVolume(to: targetVolume, duration: 1.5)
        } catch {
            // AVFoundation setup failed — silent, no crash.
        }
    }

    /// Fade out and stop. Deactivates the audio session so other apps restore.
    func stopPlayback() {
        fadeVolume(to: 0, duration: 1.0) { [weak self] in
            self?.player?.stop()
            self?.player = nil
            try? AVAudioSession.sharedInstance().setActive(
                false, options: .notifyOthersOnDeactivation
            )
        }
    }

    // MARK: - Lifecycle

    @objc private func appDidEnterBackground() {
        // Pause (don't stop) — preserves playback position and skips the
        // fade-out cost. We're not allowed to play .playback audio in the
        // background without a special entitlement we don't have.
        player?.pause()
    }

    @objc private func appWillEnterForeground() {
        guard UserDefaults.standard.bool(forKey: Self.userDefaultsKey) else { return }
        // Resume from where we paused — no fade needed, instant resume.
        player?.play()
    }

    // MARK: - Volume Fade

    private func fadeVolume(to target: Float, duration: TimeInterval, completion: (() -> Void)? = nil) {
        fadeTimer?.invalidate()

        let steps = 20
        let interval = duration / Double(steps)
        let startVolume = player?.volume ?? 0
        let delta = (target - startVolume) / Float(steps)
        var currentStep = 0

        fadeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self, let player = self.player else {
                timer.invalidate()
                completion?()
                return
            }
            currentStep += 1
            player.volume = startVolume + delta * Float(currentStep)
            if currentStep >= steps {
                player.volume = target
                timer.invalidate()
                completion?()
            }
        }
    }
}
