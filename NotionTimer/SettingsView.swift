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
            VStack {
                HStack {
                    Text("Show application icon in the dock")
                    Spacer()
                    Toggle("", isOn: $appSettings.showIconInDock)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle())
                        .scaleEffect(0.8)
                }

                Divider() // Add the divider here

                HStack {
                    Text("Show overlay window")
                    Spacer()
                    Toggle("", isOn: $appSettings.showOverlayWindow)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle())
                        .scaleEffect(0.8)
                }
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            .background(Color.gray.opacity(0.05)) // Add the gray background here
            .clipShape(RoundedRectangle(cornerRadius: 5)) // Add rounded corners here
            .overlay(
                RoundedRectangle(cornerRadius: 5) // Add the rounded border here
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            Spacer()
        }
        .padding(.vertical, 17)
        .padding(.horizontal, 15)
        .frame(minWidth: 450, maxWidth: 700, minHeight: 300, maxHeight: 500)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
