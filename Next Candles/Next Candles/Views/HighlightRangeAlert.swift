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
        #if os(iOS)
            .keyboardType(.numberPad)
        #endif
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
    
    @FocusState var focused
    @EnvironmentObject var settings: Settings
    @State var newRange = ""
    
    var body: some View {
        Group {
            
            // TODO: placeholder # is always one change behind. eg. after change from 10 to 20 will show 10 on next appear
            TextField("\(settings.dayRange) \(settings.dayRange == 1 ? "day" : "days")", text: $newRange)
                .numbersOnly($newRange)
            #if os(iOS)
                .keyboardType(.numberPad)
            #endif
                .focused($focused)
                .task {
                    focused = true
                }
            
            HStack {
                Button("Cancel", role: .cancel) {}
                
                Button("Set") {
                    if !newRange.isEmpty {
                        if let i = Int(newRange) {
                            if (i >= 0) {
                                settings.dayRange = i
                            }
                        }
                    }
                }
            }
            
        }
    }
}
