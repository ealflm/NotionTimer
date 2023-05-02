//
//  SettingsView.swift
//  NotionTimer
//
//  Created by Đào Phương Nam on 02/05/2023.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var appSettings = AppSettings.shared

    var body: some View {
        VStack {
            HStack {
                Text("Show application icon in the dock")
                    .padding(.leading)
                Spacer()
                Toggle("", isOn: $appSettings.showIconInDock)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle())
                    .padding(.trailing)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 4)

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .frame(minWidth: 450, maxWidth: 700, minHeight: 300, maxHeight: 500)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
