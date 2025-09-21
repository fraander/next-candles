//
//  WideButton.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/4/25.
//

import SwiftUI

struct WideButton: View {
    @Environment(\.colorScheme) var colorScheme

    var text: String
    var systemName: String
    var bg: AnyGradient
    var action: (() -> Void)

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                VStack {
                    Image(systemName: systemName)
                        .foregroundStyle(.white)
                        .imageScale(.large)
                }
                .frame(width: 60, height: 60)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(bg)
                }
                
                Text(text)
                    .font(.system(.title3, design: .rounded, weight: .medium))
                    .foregroundStyle(
                        colorScheme == .light
                        ? .black.opacity(0.8)
                        : .white.opacity(0.8)
                    )
                
                Spacer()
            }
            .padding(8)
            .background {
                Group {
                    colorScheme == .light ? Color.white : Color.gray.opacity(0.3)
                }
                .cornerRadius(20)
            }
        }
    }
}

