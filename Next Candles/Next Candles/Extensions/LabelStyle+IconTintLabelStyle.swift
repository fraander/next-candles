//
//  IconTintLabelStyle.swift
//  Tristy
//
//  Created by Frank Anderson on 6/13/25.
//

import SwiftUI

struct IconTintLabelStyle: LabelStyle {

    var iconColor: Color
    var textColor: Color

    func makeBody(
        configuration: Configuration
    ) -> some View {
        Label(
            title: { configuration.title.foregroundStyle(textColor) },
            icon: { configuration.icon.foregroundStyle(iconColor) }
        )
    }
}

extension LabelStyle where Self == IconTintLabelStyle {
    static func tintedIcon(icon iconColor: Color = .accentColor, text textColor: Color = .primary) -> Self {
        .init(iconColor: iconColor, textColor: textColor)
    }
    
    static func tintedIcon(_ iconColor: Color = .accentColor) -> Self {
        .init(iconColor: iconColor, textColor: .primary)
    }
}
