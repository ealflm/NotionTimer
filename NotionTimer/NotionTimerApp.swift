//
//  NotionTimerApp.swift
//  NotionTimer
//
//  Created by Đào Phương Nam on 02/05/2023.
//

import SwiftUI
import AppKit

@main
struct NotionTimerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusMenuDelegate: StatusMenuDelegate?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusMenuDelegate = StatusMenuDelegate()
    }
}

class StatusMenuDelegate: NSObject, NSMenuDelegate, StopwatchDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let stopwatch = Stopwatch.shared

    override init() {
        super.init()
        setupMenu()
        setupStopwatch()
    }

    func setupMenu() {
        guard let button = statusItem.button else { return }
        button.title = "00:00"

        let menu = NSMenu()
        let openItem = NSMenuItem(title: "Open", action: #selector(openApp), keyEquivalent: "o")
        openItem.target = self
        menu.addItem(openItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let startPauseItem = NSMenuItem(title: "Start/Pause", action: #selector(startPauseStopwatch), keyEquivalent: "s")
        startPauseItem.target = self
        menu.addItem(startPauseItem)
        
        let stopItem = NSMenuItem(title: "Stop", action: #selector(stopStopwatch), keyEquivalent: "t")
        stopItem.target = self
        menu.addItem(stopItem)

        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        menu.delegate = self
        statusItem.menu = menu
    }

    func setupStopwatch() {
        stopwatch.delegate = self
    }

    // MARK: - StopwatchDelegate

    func didStart(_ stopwatch: Stopwatch) {}

    func didPause(_ stopwatch: Stopwatch) {}

    func didStop(_ stopwatch: Stopwatch, withValue value: TimeInterval) {}

    func didChange(_ stopwatch: Stopwatch) {
        DispatchQueue.main.async { [weak self] in
            self?.statusItem.button?.title = stopwatch.description
        }
    }

    @objc func openApp() {
        // Add code to open the main app window
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    @objc func startPauseStopwatch() {
        if stopwatch.isActive {
            stopwatch.pause()
        } else {
            stopwatch.start()
        }
    }
    
    @objc func stopStopwatch() {
        stopwatch.stop()
    }
}
