//
//  ContactListRow.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/4/25.
//

import SwiftUI

struct DateIcon: View {
    
    let contact: Contact
    
    var body: some View {
        
        let condition = (contact.daysToNextBirthday() ?? 0) > -1
        
        Group {
            if let d = contact.day {
                Text(d, format: .number)
//                    .fontDesign(.rounded)
//                    .bold()
                    .monospacedDigit()
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .frame(width: 24, height: 24)
            }
        }
        .aspectRatio(1.0, contentMode: .fill)
        .padding(5)
        .background {
            ConcentricRectangle(corners: .concentric(minimum: 15))
                .fill(.gray.gradient.opacity(0.5))
        }
        .opacity(condition ? 1 : 0.5)
    }
}

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
                DateIcon(contact: contact)
                Text(contact.name)
                    .font(.headline)
                    .foregroundStyle((contact.daysToNextBirthday() ?? 1000) > highlightRange || (contact.daysToNextBirthday() ?? 1000) < 0 ? .primary : Color.accentColor)
                    .bold()
                
                Spacer()
                
                Group {
                    if let dt = contact.daysToNextBirthday() {
                        if dt == 0 {
                            Text("Today")
                        } else if dt < 0 {
                            Text("^[\(abs(dt)) day](inflect: true) ago")
                        } else {
                            Text("^[\(dt) day](inflect: true) away")
                        }
                    }
                }
                .font(.footnote)
                
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
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if !contact.hidden {
                Button("Hide", systemImage: "eye.slash") {
                    contact.hidden.toggle()
                }
                .tint(.orange)
                .labelStyle(.iconOnly)
            } else {
                Button("Show", systemImage: "eye") {
                    contact.hidden.toggle()
                }
                .tint(.cyan)
                .labelStyle(.iconOnly)
            }
            
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
