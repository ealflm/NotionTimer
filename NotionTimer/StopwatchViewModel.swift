//
//  StopwatchViewModel.swift
//  NotionTimer
//
//  Created by Đào Phương Nam on 03/05/2023.
//

import SwiftUI
import Combine

class StopwatchViewModel: ObservableObject, StopwatchDelegate {
    @Published private(set) var description: String = "00:00"
    private var stopwatch: Stopwatch

    init(stopwatch: Stopwatch) {
        self.stopwatch = stopwatch
        self.stopwatch.multicastDelegate.addDelegate(self)
        self.description = stopwatch.description
    }

    // MARK: - StopwatchDelegate
    func didStart(_ stopwatch: Stopwatch) {
        updateDescription()
    }

    func didPause(_ stopwatch: Stopwatch) {
        updateDescription()
    }

    func didStop(_ stopwatch: Stopwatch, withValue value: TimeInterval) {
        updateDescription()
    }

    func didChange(_ stopwatch: Stopwatch) {
        updateDescription()
    }

    // MARK: - Private
    private func updateDescription() {
        DispatchQueue.main.async { [weak self] in
            self?.description = self?.stopwatch.description ?? "00:00"
        }
    }
}
