//
//  BackgroundView.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/4/25.
//


import SwiftUI

struct BackgroundView: View {
    var color: Color = .accentColor
    
    @Environment(\.colorScheme) var colorScheme
    
    var headerColor: Color {
        return color.mix(with: .systemGroupedBackground, by: 1)
    }
    
    var backgroundColor: Color {
        .systemGroupedBackground.mix(with: color, by: 0)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [headerColor, backgroundColor],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: Metrics.backgroundHeight)
            
            Rectangle()
                .fill(backgroundColor)
        }
        .opacity(colorScheme == .light ? /*0.5*/ 1 : 1)
        .ignoresSafeArea(.all)
    }
}

#Preview {
    ContentView()
        .applyEnvironment(prePopulate: true)
}
