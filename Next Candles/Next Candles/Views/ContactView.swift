//
//  ContactView.swift
//  Next Candles
//
//  Created by Frank Anderson on 11/25/23.
//

import SwiftUI
import SwiftData

@Observable
class ContactVM {
    var contact: Contact
    
    init(contact: Contact) {
        self.contact = contact
    }
}


struct ContactView: View {
    
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var settings: Settings
    @State var alert: AlertItem? = nil
    var vm: ContactVM
    
    init(contact: Contact) {
        self.vm = .init(contact: contact)
    }
    
    var hideButton: some View {
        Button("Hide Birthday", systemImage: "eye.slash") { hide(vm.contact)}
            .tint(.orange)
    }
    var deleteButton: some View {
        Button("Delete Birthday", systemImage: "trash", role: .destructive) { modelContext.delete(vm.contact) }
            .tint(.red)
    }
    var setNotifButton: some View {
        Button(
            vm.contact.hasNotifs() ? "Remove Notifications" : "Set Notifications",
            systemImage: vm.contact.hasNotifs() ? "bell.slash" : "bell"
        ) {
            if (vm.contact.hasNotifs()) {
                NotificationsHelper.removeNotifs(notifIds: vm.contact.notifs)
                vm.contact.notifs?.removeAll()
            } else {
                
                Task {
                    print("ask access")
                    let accessStatus = await NotificationsHelper.hasAccess()
                    print(accessStatus)
                    
                    print("Setting notifications")
                    do {
                        try await vm.contact.setNotifs(dayRange: settings.dayRange)
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
            Text(vm.contact.name)
            #if os(macOS)
                .font(.body)
            #else
                .font(.headline)
            #endif
                .lineLimit(2)
                .truncationMode(.tail)
            Spacer()
            Text(
                (vm.contact.birthdate ?? Date())
                    .formatted(
                        .dateTime
                            .day()
                            .month(.abbreviated)
                            .weekday(.wide)
                    )
            )
            .font(.subheadline)
            .foregroundColor((vm.contact.withinNextXDays(x: settings.dayRange)) ? .pink : .secondary)
            
            if (vm.contact.hasNotifs()) {
                Image(systemName: "bell.fill")
                    .font(.subheadline)
                    .foregroundColor((vm.contact.withinNextXDays(x: settings.dayRange)) ? .pink : .secondary)
            }
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
