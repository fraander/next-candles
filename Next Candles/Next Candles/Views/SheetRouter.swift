//
//  SheetRouter.swift
//  Next Candles
//
//  Created by Frank Anderson on 11/25/23.
//

import SwiftUI

struct SheetRouter: View {
    
    @Binding var item: SheetType?
    
    var body: some View {
        switch item {
        case .custom: ContentUnavailableView("Add Manually", systemImage: "person.fill.badge.plus")
        case .hidden: HiddenContactsView()
        case .none:
            ContentUnavailableView("No sheet selected", systemImage: "wand.and.raysb")
        }
    }
}

#Preview {
    return SheetRouter(item: .constant(SheetType.hidden))
}
