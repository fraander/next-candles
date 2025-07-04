//
//  Color+systemGroupedBackground.swift
//  Tristy
//
//  Created by Frank Anderson on 6/12/25.
//

import SwiftUI

extension Color {
   static var systemGroupedBackground: Color {
       #if os(macOS)
       Color(NSColor.controlBackgroundColor)
       #else
       Color(UIColor.systemGroupedBackground)
       #endif
   }
}
