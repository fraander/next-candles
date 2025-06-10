//
//  SheetRouter.swift
//  Next Candles
//
//  Created by Frank Anderson on 11/25/23.
//

import SwiftUI

enum SheetType: Identifiable {
    
    case custom, hidden, contact(Contact)
    
    var id: String {
        switch self {
        case .custom: return "custom"
        case .hidden: return "hidden"
        case .contact(let contact): return "contact_\(contact.id)"
        }
    }
}


struct SheetRouter: View {
    
    @Binding var item: SheetType?
    
    var body: some View {
        switch item {
        case .custom: AddManuallyView()
        case .hidden: HiddenContactsView()
        case .none: Text("")
        case .contact(let contact): ContactDetailView(contact: contact)
        }
    }
}
