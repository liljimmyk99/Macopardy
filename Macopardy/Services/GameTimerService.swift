//
//  GameTimerService.swift
//  Macopardy
//
//  Created by Jimmy Kane on 7/15/26.
//
import Foundation

@Observable
final class GameTimer {
    private var timer: Timer?

    private(set) var remainingTime: TimeInterval
        private(set) var isRunning = false

        let startingTime: TimeInterval

    init(seconds: TimeInterval = 15.0) {
            self.startingTime = seconds
            self.remainingTime = seconds
        }

        func start() {
            guard !isRunning else { return }

            isRunning = true

            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self else { return }

                remainingTime -= 0.1

                if remainingTime <= 0 {
                    remainingTime = 0
                    stop()
                }
            }
        }

        func stop() {
            timer?.invalidate()
            timer = nil
            isRunning = false
        }

        func reset() {
            stop()
            remainingTime = startingTime
        }

    func addSeconds(_ amount: Int) {
        remainingTime = max(0, remainingTime + TimeInterval(amount))
    }
}
