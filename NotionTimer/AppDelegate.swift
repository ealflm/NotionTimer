//
//  AppDelegate.swift
//  NotionTimer
//
//  Created by Đào Phương Nam on 04/05/2023.
//

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, StopwatchDelegate, AppSettingsDelegate, WebSocketServerDelegate {
    @ObservedObject private var appSettings = AppSettings.shared
    
    var webSocketServer = WebSocketServer()
        
    private let marginRight: CGFloat = 16
    private let marginTop: CGFloat = 42
    
    var statusItem: NSStatusItem?
    let stopwatch = Stopwatch.shared
    var startPauseItem: NSMenuItem?
    var stopItem: NSMenuItem?
    var overlayPanel: FloatingPanel?

    // MARK: - ApplicationDidFinishLaunching
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupWebSocketServer()
        setupStatusItem()
        setupMenu()
        setupStopwatch()
        setupOverlay()
        setupAppSettings()
    }
    
    // MARK: - ApplicationWillTerminate
    func applicationWillTerminate(_ aNotification: Notification) {
        // Stop WebSocketServer
        try? webSocketServer.group?.syncShutdownGracefully()
    }
    
    // MARK: - WebSocketServer
    func setupWebSocketServer() {
        DispatchQueue.global(qos: .background).async {
            self.webSocketServer.startServer(delegate: self) { result in
                switch result {
                case .success(let message):
                    print(message)
                case .failure(let error):
                    print("Error starting the server: \(error)")
                }
            }
        }
    }
    
    func sendMessage(_ message: String) {
        webSocketServer.broadcastMessage(message)
    }
    
    func didReceiveMessage(_ message: String) {
        print("Received message: \(message)")
    }
    
    // MARK: - Setup status item
    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    }
    
    // MARK: - Setup panel
    private func updatePanelPosition(_ panel: NSPanel) {
        let screenSize = NSScreen.main?.frame ?? .zero
        
        let panelX = screenSize.width - panel.frame.width - marginRight
        let panelY = screenSize.height - panel.frame.height - marginTop
        panel.setFrameOrigin(CGPoint(x: panelX, y: panelY))
    }
    
    func setupOverlay() {
        let overlayView = NSHostingController(rootView: OverlayView(viewModel: StopwatchViewModel(stopwatch: Stopwatch.shared)))
        
        let panel = FloatingPanel(contentRect: CGRect(x: 0, y: 0, width: 200, height: 80), styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
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
    
    // MARK: - Setup menu
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
    
    // MARK: - Setup app settings
    func setupAppSettings() {
        appSettings.delegate = self
        if (appSettings.showIconInDock) {
            NSApp.setActivationPolicy(.regular)
        } else {
            NSApp.setActivationPolicy(.accessory)
        }
        updateOverlayVisibility()
    }
    
    func setupStopwatch() {
        stopwatch.multicastDelegate.addDelegate(self)
    }
    
    // MARK: - Panel delegate
    @objc func panelFrameDidChange(_ notification: Notification) {
        if let panel = overlayPanel {
            updatePanelPosition(panel)
        }
    }
    
    // MARK: - App settings delegate
    func didChangeShowIconInDock(to value: Bool) {
        if (value) {
            NSApp.setActivationPolicy(.regular)
        } else {
            NSApp.setActivationPolicy(.accessory)
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }
    
    func didChangeShowOverlayWindow(to value: Bool) {
        updateOverlayVisibility()
    }
    
    func updateOverlayVisibility() {
        if appSettings.showOverlayWindow {
            overlayPanel?.orderFrontRegardless()
        } else {
            overlayPanel?.orderOut(nil)
        }
    }
    
    // MARK: - Stopwatch delegate
    func didStart(_ stopwatch: Stopwatch) {}
    
    func didPause(_ stopwatch: Stopwatch) {}
    
    func didStop(_ stopwatch: Stopwatch, withValue value: TimeInterval) {}
    
    func didChange(_ stopwatch: Stopwatch) {
        DispatchQueue.main.async { [weak self] in
            let description = stopwatch.description
            let width: CGFloat = description.count <= 5 ? 57 : 77
            self?.statusItem?.button?.title = description
            self?.statusItem?.button?.frame.size.width = width
        }
    }
    
    // MARK: - Action
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
}
