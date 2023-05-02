//
//  Stopwatch.swift
//  NotionTimer
//
//  Created by Đào Phương Nam on 02/05/2023.
//

import Foundation

protocol StopwatchDelegate: AnyObject {
    func didStart(_ stopwatch: Stopwatch)
    func didPause(_ stopwatch: Stopwatch)
    func didStop(_ stopwatch: Stopwatch, withValue value: TimeInterval)
    func didChange(_ stopwatch: Stopwatch)
}

class Stopwatch {
    static let shared = Stopwatch()
    
    weak var delegate: StopwatchDelegate?
    private(set) var timer: DispatchSourceTimer?
    private var reference: Date
    private var accum: TimeInterval

    init() {
        self.timer = nil
        self.reference = Date()
        self.accum = 0
    }
    
    convenience init(delegate: StopwatchDelegate) {
        self.init()
        self.delegate = delegate
    }

    var description: String {
        let seconds = Int(floor(value))
        let hours = seconds / 3600
        let minutes = (seconds / 60) % 60
        let remainingSeconds = seconds % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
        } else {
            return String(format: "%02d:%02d", minutes, remainingSeconds)
        }
    }

    var value: TimeInterval {
        if timer == nil {
            return accum
        }
        return Date().timeIntervalSince(reference) + accum
    }

    var isActive: Bool {
        return timer != nil
    }

    var isPaused: Bool {
        return timer == nil && accum > 0
    }

    var isStopped: Bool {
        return timer == nil && accum == 0
    }

    func start() {
        guard !isActive else { return }

        reference = Date()
        
        let queue = DispatchQueue.global(qos: .default)
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now(), repeating: 0.5, leeway: .nanoseconds(Int(0.1 * Double(NSEC_PER_SEC))))
        timer?.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                self?.tick()
            }
        }
        timer?.resume()

        delegate?.didStart(self)
        delegate?.didChange(self)
    }

    func pause() {
        guard !isPaused else { return }

        accum = value
        timer?.cancel()
        timer = nil

        delegate?.didPause(self)
    }

    func reset(_ value: TimeInterval) {
        accum = value
        reference = Date()

        delegate?.didChange(self)
    }

    func stop() {
        guard !isStopped else { return }

        let value = self.value
        accum = 0
        timer?.cancel()
        timer = nil

        delegate?.didStop(self, withValue: value)
    }

    // MARK: - Private

    private func tick() {
        delegate?.didChange(self)
    }
}
