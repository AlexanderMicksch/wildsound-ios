//
//  SoundPlayerService.swift
//  WildSound
//
//  Created by Alexander Micksch on 06.08.25.
//

import AVFoundation
import Combine
import Foundation

@Observable
final class SoundPlayerService {

    private var player: AVPlayer?
    private var timeObserverToken: Any?
    private var cancellables = Set<AnyCancellable>()

    private(set) var isPlaying = false
    private(set) var error: String?
    private(set) var progress: Double = 0.0
    
    private let repo = SoundRepository()

    func playSound(from url: URL) {
        stop()
        error = nil
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

        NotificationCenter.default.publisher(
            for: AVPlayerItem.didPlayToEndTimeNotification,
            object: playerItem
        )
        .sink { [weak self] _ in self?.stop() }
        .store(in: &cancellables)

        NotificationCenter.default.publisher(
            for: AVPlayerItem.failedToPlayToEndTimeNotification,
            object: playerItem
        )
        .sink { [weak self] notification in
            self?.error = "Audio konnte nicht abgespielt werden"
            self?.stop()
        }
        .store(in: &cancellables)

        timeObserverToken = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.2, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let duration = self?.player?.currentItem?.duration.seconds,
                duration > 0
            else { return }
            self?.progress = time.seconds / duration
        }

        player?.play()
        isPlaying = true
    }
    
    func play(storagePath: String) async {
        do {
            let url = try await repo.downloadURL(for: storagePath)
            playSound(from: url)
        } catch {
            self.error = "Sound konnte nicht geladen werden: \(error.localizedDescription)"
            print("SoundPlayerService.play(storagePath:) error:", error)
        }
    }

    func stop() {
        player?.pause()
        player = nil
        isPlaying = false
        progress = 0.0
        removeTimeObserver()
        cancellables.removeAll()
    }
    
    func toggleSound(from url: URL) {
        if isPlaying {
            stop()
        } else {
            playSound(from: url)
        }
    }
    
    private func removeTimeObserver() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }

    func setError(_ message: String) {
        error = message
    }

    deinit {
        removeTimeObserver()
        cancellables.removeAll()
    }
}

extension SoundPlayerService {
    func toggle(storagePath: String) async {
        if isPlaying {
            stop()
        } else {
            await play(storagePath: storagePath)
        }
    }
}
