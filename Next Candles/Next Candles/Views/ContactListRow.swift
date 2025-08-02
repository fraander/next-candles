//
//  ContactListRow.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/4/25.
//

import SwiftUI

struct ContactListRow: View {
    @Environment(Router.self) var router
    
    var contact: Contact
    
    @Namespace private var transitionNamespace
    
    var body: some View {
        
        let presentSheetForContactBinding: Binding<Bool> = .init(
            get: { router.sheet == .contact(contact) },
            set: { if $0 {} else { router.popToHome() } }
        )
        
        Button {
            router.present(.contact(contact))
        } label: {
            HStack {
                Text(contact.name)
                    .font(.headline)
                    .foregroundStyle((contact.daysToNextBirthday() ?? 1000) > 20 ? .primary : Color.accentColor)
                    .bold((contact.daysToNextBirthday() ?? 1000) > 20)
                #warning("use settings for days thing instead of this")
                
                Spacer()
                
                if let dt = contact.daysToNextBirthday() {
                    Text("^[\(dt) day](inflect: true) away")
                }
                
                #warning("missing icons for notification on day vs. other")
                
                Spacer()
                    .frame(width: 15)
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .matchedTransitionSource(id: contact.identifier, in: transitionNamespace)
        }
        .sheet(isPresented: presentSheetForContactBinding) {
            ContactDetailView(contact: contact)
                .navigationTransition(.zoom(sourceID: contact.identifier, in: transitionNamespace))
        }
    }
}

#Preview {
    ContentView()
        .applyEnvironment(prePopulate: true)
}
