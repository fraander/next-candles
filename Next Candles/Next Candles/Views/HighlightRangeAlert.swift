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
                var numbers = "0123456789"
                
                let filtered = newValue.filter { numbers.contains ($0)}
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
