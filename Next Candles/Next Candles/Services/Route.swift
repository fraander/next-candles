//
//  Route.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/4/25.
//

import SwiftUI

enum Route: Hashable {
    case contact(Contact)
    case settings
    
    var id: String {
        switch self {
        case .contact(let contact): "contact_\(contact.identifier)"
        case .settings: "settings"
        }
    }
    
    @ViewBuilder
    func correspondingView() -> some View {
        switch self {
        case .contact(let contact): ContactDetailView(contact: contact)
        case .settings: SettingsView()
        }
    }
}
