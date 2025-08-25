//
//  SoundPlayerService.swift
//  WildSound
//
//  Created by Alexander Micksch on 06.08.25.
//

import AVFoundation
import Combine
import Foundation
import os

@Observable
final class SoundPlayerService {

    private var player: AVPlayer?
    private var timeObserverToken: Any?
    private var cancellables = Set<AnyCancellable>()

    private(set) var isPlaying = false
    private(set) var error: String?
    private(set) var progress: Double = 0.0
    private(set) var currentPath: String?
    private(set) var currentURL: URL?

    private let repo = SoundRepository()
    private let logger = Logger(subsystem: "WildSound", category: "Sound")

    func playSound(from url: URL) {
        stop()
        error = nil

        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        currentURL = url

        NotificationCenter.default.publisher(
            for: AVPlayerItem.didPlayToEndTimeNotification,
            object: item
        )
        .sink { [weak self] _ in self?.stop() }
        .store(in: &cancellables)

        NotificationCenter.default.publisher(
            for: AVPlayerItem.failedToPlayToEndTimeNotification,
            object: item
        )
        .sink { [weak self] note in
            self?.error = "Audio konnte nicht abgespielt werden"
            if let err = note.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
                self?.logger.error("AVPlayer failedToPlay: \(String(describing: err))")
            } else {
                self?.logger.error("AVPlayer failedToPlay without error")
            }
            self?.stop()
        }
        .store(in: &cancellables)

        timeObserverToken = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.2, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard
                let self,
                let item = self.player?.currentItem,
                item.status == .readyToPlay
            else { return }

            let duration = item.duration.seconds
            guard duration.isFinite, duration > 0 else { return }
            self.progress = min(max(time.seconds / duration, 0), 1)
        }

        player?.play()
        isPlaying = true
    }

    func play(storagePath: String) async {
        do {
            let url = try await repo.downloadURL(for: storagePath)
            currentPath = storagePath
            playSound(from: url)
        } catch {
            self.error =
                "Sound konnte nicht geladen werden: \(error.localizedDescription)"
            logger.error("Sound download failed (play): \(String(describing: error))")
        }
    }

    func stop() {
        player?.pause()
        player = nil
        isPlaying = false
        progress = 0.0
        currentPath = nil
        removeTimeObserver()
        cancellables.removeAll()
    }

    func toggle(storagePath: String) async {
        do {
            let url = try await repo.downloadURL(for: storagePath)
            if isPlaying, let cur = currentURL,
                cur.absoluteString == url.absoluteString
            {
                stop()
            } else {
                currentPath = storagePath
                playSound(from: url)
            }
        } catch {
            self.error =
                "Sound konnte nicht geladen werden: \(error.localizedDescription)"
            logger.error("Sound download failed (toggle): \(String(describing: error))")
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
        logger.error("Manuel sound error set: \(message)")
    }

    deinit {
        removeTimeObserver()
        cancellables.removeAll()
    }
}
