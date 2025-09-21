//
//  ContactListRow.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/4/25.
//

import SwiftUI

struct ContactListRow: View {
    @Environment(Router.self) var router
    @AppStorage(S.highlightRangeKey) var highlightRange = S.highlightRangeDefault
    @AppStorage(S.notificationIndicatorsKey) var notificationIndicators = S.notificationIndicatorsDefault
    @Environment(NotificationManager.self) var notifs
    
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
                    .foregroundStyle((contact.daysToNextBirthday() ?? 1000) > highlightRange || (contact.daysToNextBirthday() ?? 1000) < 0 ? .primary : Color.accentColor)
                    .bold()
                
                Spacer()
                
                if let dt = contact.daysToNextBirthday() {
                    if dt == 0 {
                        Text("Today")
                    } else if dt < 0 {
                        Text("^[\(abs(dt)) day](inflect: true) ago")
                    } else {
                        Text("^[\(dt) day](inflect: true) away")
                    }
                }
                
//                Image(systemName: "party.popper.fill")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 14, height: 14)
//                    .foregroundStyle(.white)
//                    .padding(6)
//                    .background(.yellow.gradient, in: .circle)
                
                if notificationIndicators && !notifs.pendingRequests.filter({
                    let idComponents = $0.identifier.split(separator: "%%%")
                    let prefix = idComponents.prefix(idComponents.count - 1).joined(separator: "")
                    return prefix == contact.identifier
                }).isEmpty {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(.white)
                        .imageScale(.small)
                        .frame(width: 14, height: 14)
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(.orange.gradient, in: .circle)
                }
                
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
