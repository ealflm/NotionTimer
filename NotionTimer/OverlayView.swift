//
//  OverlayView.swift
//  NotionTimer
//
//  Created by Đào Phương Nam on 03/05/2023.
//

import SwiftUI

struct OverlayView: View {
    @ObservedObject var viewModel: StopwatchViewModel

    var body: some View {
        Text(viewModel.description)
            .font(.system(size: 48))
            .padding()
            .background(Color.black.opacity(0.3))
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

struct OverlayView_Previews: PreviewProvider {
    static var previews: some View {
        OverlayView(viewModel: StopwatchViewModel(stopwatch: Stopwatch.shared))
    }
}
