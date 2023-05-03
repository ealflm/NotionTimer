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
    
    // Overlay
    var overlayPanel: FloatingPanel?
    
    private let marginRight: CGFloat = 16
    private let marginTop: CGFloat = 42
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        setupMenu()
        setupStopwatch()
        setupAppSettings()
        setupOverlay()
    }
    
    func setupOverlay() {
        let overlayView = NSHostingController(rootView: OverlayView(viewModel: StopwatchViewModel(stopwatch: Stopwatch.shared)))
        
        let panel = FloatingPanel(contentRect: CGRect(x: 0, y: 0, width: 400, height: 100), styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.contentView = overlayView.view
        panel.hasShadow = false
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.ignoresMouseEvents = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        
        NotificationCenter.default.addObserver(self, selector: #selector(panelFrameDidChange), name: NSView.frameDidChangeNotification, object: panel.contentView)
        
        updatePanelPosition(panel)
        
        panel.orderFrontRegardless()
        overlayPanel = panel
    }
    
    private func updatePanelPosition(_ panel: NSPanel) {
        let screenSize = NSScreen.main?.frame ?? .zero
        
        let panelX = screenSize.width - panel.frame.width - marginRight
        let panelY = screenSize.height - panel.frame.height - marginTop
        panel.setFrameOrigin(CGPoint(x: panelX, y: panelY))
    }
    
    @objc func panelFrameDidChange(_ notification: Notification) {
        if let panel = overlayPanel {
            updatePanelPosition(panel)
        }
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
        }
    }
    
    func setupStopwatch() {
        stopwatch.multicastDelegate.addDelegate(self)
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
        NSApplication.shared.activate(ignoringOtherApps: true)
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
