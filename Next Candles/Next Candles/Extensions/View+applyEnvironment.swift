//
//  View+applyEnvironment.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/4/25.
//

import SwiftUI
import SwiftData

struct ApplyEnvironmentModifier: ViewModifier {
    
    @State var notifs: NotificationsStore = .init()
    @State var router: Router = .init()
    
    let prePopulate: Bool
    
    var modelContainer: ModelContainer {
        if prePopulate {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try! ModelContainer(
                for: Contact.self,
                configurations: config
            )
            
            for contact in Contact.examples {
                container.mainContext.insert(contact)
            }
            
            try! container.mainContext.save()
            
            return container
        } else {
            return try! ModelContainer(for: Contact.self)
        }
    }
    
    func body(content: Content) -> some View {
        content
            .environment(notifs)
            .environment(router)
            .modelContainer(modelContainer)
    }
}

extension View {
    func applyEnvironment(prePopulate: Bool = false) -> some View {
        self
            .modifier(ApplyEnvironmentModifier(prePopulate: prePopulate))
    }
}
