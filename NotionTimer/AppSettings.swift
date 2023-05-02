//
//  AppSettings.swift
//  NotionTimer
//
//  Created by Đào Phương Nam on 02/05/2023.
//

import Foundation

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var showIconInDock: Bool {
        didSet {
            UserDefaults.standard.set(showIconInDock, forKey: "showIconInDock")
        }
    }

    private init() {
        showIconInDock = UserDefaults.standard.bool(forKey: "showIconInDock")
    }
}
