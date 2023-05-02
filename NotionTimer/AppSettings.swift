//
//  AppSettings.swift
//  NotionTimer
//
//  Created by Đào Phương Nam on 02/05/2023.
//

import Foundation

protocol AppSettingsDelegate: AnyObject {
    func didChangeShowIconInDock(to value: Bool)
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

    private init() {
        showIconInDock = UserDefaults.standard.bool(forKey: "showIconInDock")
    }
}
