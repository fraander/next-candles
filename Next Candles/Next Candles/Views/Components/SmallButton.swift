//
//  SmallButton.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/4/25.
//

import SwiftUI

struct SmallButton: View {
    
    var text: String
    var systemName: String
    var bg: AnyGradient
    var action: (() -> Void)
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: systemName)
                    .foregroundStyle(.white)
                    .imageScale(.large)
                
                Text(text)
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                    .offset(y: 2)
            }
            .frame(maxWidth: .infinity, minHeight: 84, maxHeight: 84)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(bg)
            }
        }
    }
}

#Preview {
    SmallButton(
        text: "Send",
        systemName: "paperplane",
        bg: Color.cyan.gradient
    ) {}
}
