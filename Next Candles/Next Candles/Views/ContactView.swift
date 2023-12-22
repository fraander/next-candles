//
//  ContactView.swift
//  Next Candles
//
//  Created by Frank Anderson on 11/25/23.
//

import SwiftUI
import SwiftData


struct ContactView: View {
    
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var settings: Settings
    @State var alert: AlertItem? = nil
    var contact: Contact
    
    var hideButton: some View {
        Button("Hide Birthday", systemImage: "eye.slash") { hide(contact)}
            .tint(.orange)
    }
    var deleteButton: some View {
        Button("Delete Birthday", systemImage: "trash", role: .destructive) { modelContext.delete(contact) }
            .tint(.red)
    }
    var setNotifButton: some View {
        Button(
            contact.hasNotifs ? "Remove Notifications" : "Set Notifications",
            systemImage: contact.hasNotifs ? "bell.slash" : "bell"
        ) {
            if (contact.hasNotifs) {
                if let n = contact.notif {
                    NotificationsHelper.removeNotifs(notifIds: [n])
                    contact.notif = nil
                }
                
            } else {
                
                Task {
                    print("ask access")
                    let accessStatus = await NotificationsHelper.hasAccess()
                    print(accessStatus)
                    
                    print("Setting notifications")
                    do {
                        try await contact.setNotifs(dayRange: settings.dayRange)
                        print("Notifs set")
                    } catch {
                        print(error.localizedDescription)
                        alert = AlertItem(title: error.localizedDescription)
                    }
                }
            }
        }
        .tint(.pink)
    }
    
    var body: some View {
        HStack {
            Text(contact.name)
            #if os(macOS)
                .font(.body)
            #else
                .font(.headline)
            #endif
                .lineLimit(2)
                .truncationMode(.tail)
            Spacer()
            HStack {
                
                Text(
                    (contact.birthdate ?? Date())
                        .formatted(
                            .dateTime
                                .day()
                                .month(.abbreviated)
                                .weekday(.wide)
                        )
                )
                .multilineTextAlignment(.leading)
                .font(.subheadline)
                .foregroundColor((contact.withinNextXDays(x: settings.dayRange)) ? .pink : .secondary)
                
                if (contact.hasNotifs) {
                    Image(systemName: "bell.fill")
                        .font(.subheadline)
                        .foregroundColor((contact.withinNextXDays(x: settings.dayRange)) ? .pink : .secondary)
                }
            }
            .padding(.trailing, 4)
        }
        #if os(macOS)
        .padding(.vertical, 8)
        #endif
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            hideButton
            
            deleteButton
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            setNotifButton
        }
        .contextMenu {
            hideButton
            deleteButton
            
            Divider()
            
            setNotifButton
            
            Button("Copy Identifier", systemImage: "barcode.viewfinder") {
                UIPasteboard.general.string = "nextcandles://open?contact=" + contact.identifier
            }
        }
        .alert(item: $alert) { alert in
            Alert(
                title: Text(alert.title),
                dismissButton: .default(
                    Text("Okay")
                )
            )
        }
    }
    
    func hide(_ contact: Contact) {
        contact.hidden.toggle()
    }
}
