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
        let frameWidth = viewModel.description.count <= 5 ? 200 : 267
        
        ZStack {
            Color.black.opacity(0.3)
                .frame(width: CGFloat(frameWidth))
                .frame(height: 80)
                .cornerRadius(10)
            
            Text(viewModel.description)
                .font(.system(size: 48))
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

struct OverlayView_Previews: PreviewProvider {
    static var previews: some View {
        OverlayView(viewModel: StopwatchViewModel(stopwatch: Stopwatch.shared))
    }
}
