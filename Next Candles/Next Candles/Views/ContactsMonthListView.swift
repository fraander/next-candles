//
//  ContactMonthsListView.swift
//  Next Candles
//
//  Created by Frank Anderson on 11/25/23.
//

import SwiftUI
import SwiftData

struct AlertItem: Identifiable {
    let id: UUID = .init()
    let title: String
}

struct ContactsMonthListView: View {
    
    @EnvironmentObject var settings: Settings
    @Environment(\.modelContext) private var modelContext
    @Query private var contacts: [Contact]
    let dayRange: Int
    @State var alert: AlertItem? = nil
    
    init(month: Int, dayRange: Int) {
        _contacts = Query(filter: #Predicate<Contact> { contact in
            return (contact.month == month) && (contact.day != nil) && (contact.hidden == false)
        }, sort: [SortDescriptor(\Contact.month), SortDescriptor(\Contact.day), SortDescriptor(\Contact.year)])
        self.dayRange = dayRange
    }
    
    
    
    var body: some View {
        ForEach(contacts) { contact in
            ContactView(vm: .init(contact: contact, dayRange: dayRange))
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button("Hide", systemImage: "eye.slash") { hide(contact)}
                        .tint(.orange)
                    
                    Button("Delete", systemImage: "trash", role: .destructive) { modelContext.delete(contact) }
                        .tint(.red)
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button("\(contact.notif == nil ? "Notify" : "Remove Notification")", systemImage: "\(contact.notif == nil ? "bell" : "bell.slash")") {
                        
                        print("\(contact.notif ?? "--none--")")
                        
                        if (contact.notif == nil) {
                            Task {
                                do {
                                    try await contact.notifyXDaysBefore(days: settings.dayRange)
                                    alert = .init(title: "Notification set!") // TODO: include more data here
                                } catch {
                                    alert = .init(title: "Failed to set notification")
                                }
                            }
                        } else {
                            contact.notif = nil
                            alert = .init(title: "Notification removed!")
                        }
                    }
                    .tint(contact.notif == nil ? .pink : .secondary)
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
    }
    
    func hide(_ contact: Contact) {
        contact.hidden = true
    }
}

#Preview {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, configurations: config)
    
    return ContactsMonthListView(month: 5, dayRange: 20)
        .modelContainer(container)
    
}
