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
    @EnvironmentObject var alertRouter: AlertRouter
    var contact: Contact
    
    @State var setNotifSheet = false
    
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
                        try await contact.setNotifs(distanceFromBD: settings.dayRange)
                        print("Notifs set")
                    } catch {
                        alertRouter.alert = Alert(title: Text(error.localizedDescription))
                    }
                }
            }
        }
        .tint(.yellow)
    }
    
    var body: some View {
        HStack {
            Text(contact.name)
                .foregroundColor((contact.withinNextXDays(x: settings.dayRange)) ? .pink : .primary.opacity(0.8))
            #if os(macOS)
                .font(.system(.body, design: .rounded))
            #else
                .font(.system(.headline, design: .rounded))
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
                .font(.system(.subheadline, design: .rounded, weight: .regular))
                .foregroundColor(.secondary)
                
                if (contact.hasNotifs) {
                    Image(systemName: "bell.fill")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
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
            Button("Set") {
                setNotifSheet.toggle()
            }
        }
        .contextMenu {
            
            hideButton
            
            Divider()
            
            setNotifButton
            
            Button("Copy Identifier", systemImage: "barcode.viewfinder") {
                UIPasteboard.general.string = "nextcandles://open?contact=" + contact.identifier
            }
        }
        .sheet(isPresented: $setNotifSheet) { SetNotificationView(contact: contact) }
    }
    
    func hide(_ contact: Contact) {
        contact.hidden.toggle()
    }
}
