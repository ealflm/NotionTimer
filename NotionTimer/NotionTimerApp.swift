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

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, StopwatchDelegate, AppSettingsDelegate {
    @ObservedObject private var appSettings = AppSettings.shared
    var statusItem: NSStatusItem?
    let stopwatch = Stopwatch.shared
    
    // Menu items
    var startPauseItem: NSMenuItem?
    var stopItem: NSMenuItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        setupMenu()
        setupStopwatch()
        setupAppSettings()
    }

    func setupMenu() {
        guard let button = statusItem?.button else { return }
        button.title = "00:00"

        let menu = NSMenu()
        menu.autoenablesItems = false
        
        let startPauseItem = NSMenuItem(title: "Start", action: #selector(startPauseStopwatch), keyEquivalent: "s")
        menu.addItem(startPauseItem)
        self.startPauseItem = startPauseItem
        
        let stopItem = NSMenuItem(title: "Stop", action: #selector(stopStopwatch), keyEquivalent: "t")
        stopItem.isEnabled = false
        menu.addItem(stopItem)
        self.stopItem = stopItem

        menu.addItem(NSMenuItem.separator())
        
        let settingsItem = NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: ",")
        menu.addItem(settingsItem)
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        menu.addItem(quitItem)
        
        menu.delegate = self
        statusItem?.menu = menu
    }
   
    func setupAppSettings() {
        appSettings.delegate = self
        if (appSettings.showIconInDock) {
            NSApp.setActivationPolicy(.regular)
        } else {
            NSApp.setActivationPolicy(.accessory)
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }

    func setupStopwatch() {
        stopwatch.delegate = self
    }
    
    // MARK: - AppSettingsDelegate

    func didChangeShowIconInDock(to value: Bool) {
        if (value) {
            NSApp.setActivationPolicy(.regular)
        } else {
            NSApp.setActivationPolicy(.accessory)
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }

    // MARK: - StopwatchDelegate

    func didStart(_ stopwatch: Stopwatch) {}

    func didPause(_ stopwatch: Stopwatch) {}

    func didStop(_ stopwatch: Stopwatch, withValue value: TimeInterval) {}

    func didChange(_ stopwatch: Stopwatch) {
        DispatchQueue.main.async { [weak self] in
            self?.statusItem?.button?.title = stopwatch.description
        }
    }
    
    @objc func openSettings() {
        let settingsView = SettingsView()
        let settingsWindow = NSWindow(contentViewController: NSHostingController(rootView: settingsView))
        settingsWindow.title = "Settings"
        settingsWindow.styleMask = [.closable, .miniaturizable, .resizable, .titled]
        settingsWindow.center()
        settingsWindow.level = .floating
        NSWindowController(window: settingsWindow).showWindow(nil)
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    @objc func startPauseStopwatch() {
        if stopwatch.isActive {
            stopwatch.pause()
            self.startPauseItem?.title = "Start"
        } else {
            stopwatch.start()
            self.startPauseItem?.title = "Pause"
            self.stopItem?.isEnabled = true
        }
    }
    
    @objc func stopStopwatch() {
        stopwatch.stop()
        self.startPauseItem?.title = "Start"
        self.stopItem?.isEnabled = false
    }
}
