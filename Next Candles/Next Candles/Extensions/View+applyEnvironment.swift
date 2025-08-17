//
//  View+applyEnvironment.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/4/25.
//

import SwiftUI
import SwiftData

struct ApplyEnvironmentModifier: ViewModifier {
    
    @State var notifs: NotificationManager = .init()
    @State var importManager: ContactImportManager = .init()
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
        
        let alertBinding = Binding<Bool>(
            get: { importManager.resultToShow != nil },
            set: { if (!$0) { importManager.resultToShow = nil } }
        )
        
        content
            .environment(notifs)
            .environment(router)
            .environment(importManager)
            .modelContainer(modelContainer)
            .alert("Imported Contacts", isPresented: alertBinding) { } message: {
                Text("Found ^[\(importManager.resultToShow ?? 0) birthday](inflect: true)! 🥳")
            }
    }
}

extension View {
    func applyEnvironment(prePopulate: Bool = false) -> some View {
        self
            .modifier(ApplyEnvironmentModifier(prePopulate: prePopulate))
    }
}
