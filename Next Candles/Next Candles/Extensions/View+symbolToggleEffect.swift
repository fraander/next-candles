//
//  SymbolToggleEffectViewModifier.swift
//  Tristy
//
//  Created by Frank Anderson on 6/15/25.
//

import SwiftUI

struct SymbolToggleEffectViewModifier: ViewModifier {
    
    var property: Bool
    var activeVariant: SymbolVariants
    var inactiveVariant: SymbolVariants
    
    func body(content: Content) -> some View {
        content
            .symbolVariant(property ? activeVariant : inactiveVariant)
            .symbolVariant(property ? .fill : .none)
            .frame(height: 24)
            .contentTransition(
                .symbolEffect(
                    .replace,
                    options: .default
                )
            )
    }
}

extension View {
    /// Show a filled version of the symbol when active, and a normal version of the symbol when inactive. Animate changes between when the given property changes.
    /// - Parameter property: property to animate the symbol for
    func symbolToggleEffect(_ property: Bool, activeVariant: SymbolVariants = .none, inactiveVariant: SymbolVariants = .none) -> some View {
        modifier(
            SymbolToggleEffectViewModifier(
                property: property,
                activeVariant: activeVariant,
                inactiveVariant: inactiveVariant,
            )
        )
    }
}
