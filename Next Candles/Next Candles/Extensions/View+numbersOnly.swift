//
//  NumbersOnlyViewModifier.swift
//  Tristy
//
//  Created by Frank Anderson on 6/16/25.
//



import SwiftUI
import Combine

// https://www.youtube.com/watch?v=dd079CQ4Fr4

struct NumbersOnlyViewModifier: ViewModifier {
    
    @Binding var text: String
    var includeDecimal: Bool
    
    func body(content: Content) -> some View {
        content
        #if os(iOS)
            .keyboardType(includeDecimal ? .decimalPad : .numberPad)
        #endif
            .onReceive(Just(text)) { newValue in
                var numbers = "0123456789"
                let decimalSeparator: String = Locale.current.decimalSeparator ?? "."
                if includeDecimal {
                    numbers += decimalSeparator
                }
                if newValue.components(separatedBy: decimalSeparator).count-1 > 1 {
                    let filtered = newValue
                    self.text = String(filtered.dropLast())
                } else {
                    let filtered = newValue.filter { numbers.contains($0)}
                    if filtered != newValue {
                        self.text = filtered
                    }
                }
            }
    }
}

extension View {
    /// Restricts input for the field to only allowed numerics.
    /// 
    /// # Usage
    /// ```swift
    /// TextField("title", text: $value)
    ///     .numbersOnly($value)
    /// ```
    func numbersOnly(_ text: Binding<String>, includeDecimal: Bool = false) -> some View {
        self.modifier(NumbersOnlyViewModifier(text: text, includeDecimal: includeDecimal))
    }
}
