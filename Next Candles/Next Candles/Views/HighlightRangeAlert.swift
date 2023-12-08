//
//  HighlightRangeAlert.swift
//  Next Candles
//
//  Created by Frank Anderson on 12/8/23.
//

import SwiftUI
import Combine

// https://www.youtube.com/watch?v=dd079CQ4Fr4

struct NumbersOnlyViewModifier: ViewModifier {
    @Binding var text: String
    func body (content: Content) -> some View {
        content
            .keyboardType(.numberPad)
            .onReceive (Just(text)) { newValue in
                let filtered = newValue.filter { "0123456789".contains ($0)}
                if filtered != newValue {
                    self.text = filtered
                }
            }
    }
}

extension View {
    func numbersOnly(_ text: Binding<String>) -> some View {
        self.modifier(NumbersOnlyViewModifier(text: text))
    }
}


struct HighlightRangeAlert: View {
    
    @Binding var dayRange: Int
    @State var newRange = ""
    
    var body: some View {
        Group {
            
            TextField("Days", text: $newRange)
                .numbersOnly($newRange)
                .keyboardType(.numberPad)
            
            Button("Set") {
                if !newRange.isEmpty {
                    if let i = Int(newRange) {
                        if (i >= 0) {
                            dayRange = i
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    HighlightRangeAlert(dayRange: .constant(20))
}
