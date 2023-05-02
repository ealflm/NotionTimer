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
        
        menu.addItem(NSMenuItem.separator())
        
        let startPauseItem = NSMenuItem(title: "Start/Pause", action: #selector(startPauseStopwatch), keyEquivalent: "s")
        startPauseItem.target = self
        menu.addItem(startPauseItem)
        
        let stopItem = NSMenuItem(title: "Stop", action: #selector(stopStopwatch), keyEquivalent: "t")
        stopItem.target = self
        menu.addItem(stopItem)

        menu.addItem(NSMenuItem.separator())
        
        let settingsItem = NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
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
        } else {
            stopwatch.start()
        }
    }
    
    @objc func stopStopwatch() {
        stopwatch.stop()
    }
}
