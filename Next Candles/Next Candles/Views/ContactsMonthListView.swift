//
//  ContactMonthsListView.swift
//  Next Candles
//
//  Created by Frank Anderson on 11/25/23.
//

import SwiftUI
import SwiftData

struct AlertItem: Identifiable {
    typealias AlertAction = (title: String, action: () -> Void)
    
    let id: UUID = .init()
    let title: String
    let actions: [AlertAction]
    
    init(title: String, actions: [AlertAction] = []) {
        self.title = title
        self.actions = actions
    }
}

struct ContactsMonthListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var contacts: [Contact]
    @EnvironmentObject var settings: Settings
    
    init(month: Int) {
        _contacts = Query(filter: #Predicate<Contact> { contact in
            return (contact.month == month) && (contact.day != nil) && (contact.hidden == false)
        }, sort: [SortDescriptor(\Contact.month), SortDescriptor(\Contact.day), SortDescriptor(\Contact.year)])
    }
    
    
    
    var body: some View {
        ForEach(contacts) { contact in
            NavigationLink(value: contact) {
                ContactView(contact: contact)
            }
            .id(contact.id)
        }
    }
}

#Preview {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, configurations: config)
    
    return ContactsMonthListView(month: 5)
        .modelContainer(container)
    
}
