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
    
    private(set) var timer: DispatchSourceTimer?
    private var reference: Date
    private var accum: TimeInterval
    public var multicastDelegate = MulticastDelegate<StopwatchDelegate>()
    
    init() {
        self.timer = nil
        self.reference = Date()
        self.accum = 0
    }
    
    convenience init(delegate: StopwatchDelegate) {
        self.init()
        self.addDelegate(delegate)
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
    
    func addDelegate(_ delegate: StopwatchDelegate) {
        multicastDelegate.addDelegate(delegate)
    }
    
    func removeDelegate(_ delegate: StopwatchDelegate) {
        multicastDelegate.removeDelegate(delegate)
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
        
        multicastDelegate.invokeDelegates { $0.didStart(self) }
        multicastDelegate.invokeDelegates { $0.didChange(self) }
    }
    
    func pause() {
        guard !isPaused else { return }
        
        accum = value
        timer?.cancel()
        timer = nil
        
        multicastDelegate.invokeDelegates { $0.didPause(self) }
        multicastDelegate.invokeDelegates { $0.didChange(self) }
    }
    
    func reset(_ value: TimeInterval) {
        accum = value
        reference = Date()
        
        multicastDelegate.invokeDelegates { $0.didChange(self) }
    }
    
    func stop() {
        guard !isStopped else { return }
        
        let value = self.value
        accum = 0
        timer?.cancel()
        timer = nil
        
        multicastDelegate.invokeDelegates { $0.didChange(self) }
        multicastDelegate.invokeDelegates { $0.didStop(self, withValue: value) }
    }
    
    // MARK: - Private
    
    private func tick() {
        multicastDelegate.invokeDelegates { $0.didChange(self) }
    }
}
