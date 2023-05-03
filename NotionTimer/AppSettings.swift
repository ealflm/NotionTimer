//
//  AppSettings.swift
//  NotionTimer
//
//  Created by Đào Phương Nam on 02/05/2023.
//

import Foundation

protocol AppSettingsDelegate: AnyObject {
    func didChangeShowIconInDock(to value: Bool)
    func didChangeShowOverlayWindow(to value: Bool)
}

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    weak var delegate: AppSettingsDelegate?

    @Published var showIconInDock: Bool {
        didSet {
            UserDefaults.standard.set(showIconInDock, forKey: "showIconInDock")
            delegate?.didChangeShowIconInDock(to: showIconInDock)
        }
    }
    
    @Published var showOverlayWindow: Bool {
        didSet {
            UserDefaults.standard.set(showOverlayWindow, forKey: "showOverlayWindow")
            delegate?.didChangeShowOverlayWindow(to: showOverlayWindow)
        }
    }

    private init() {
        showIconInDock = UserDefaults.standard.bool(forKey: "showIconInDock")
        showOverlayWindow = UserDefaults.standard.bool(forKey: "showOverlayWindow")
    }
}
