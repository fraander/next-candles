//
//  ContactMonthsListView.swift
//  Next Candles
//
//  Created by Frank Anderson on 11/25/23.
//

import SwiftUI
import SwiftData

struct ContactsMonthListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var contacts: [Contact]
    
    init(month: Int) {
        _contacts = Query(filter: #Predicate<Contact> { contact in
            return (contact.month == month) && (contact.day != nil) && (contact.hidden == false)
        }, sort: [SortDescriptor(\Contact.month), SortDescriptor(\Contact.day), SortDescriptor(\Contact.year)])
    }
    
    var body: some View {
        ForEach(contacts) { contact in
            ContactView(contact: contact)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button("Hide", systemImage: "eye.slash") { hide(contact)}
                        .tint(.orange)
                    
                    Button("Delete", systemImage: "trash", role: .destructive) { modelContext.delete(contact) }
                        .tint(.red)
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
    
    return ContactsMonthListView(month: 5)
        .modelContainer(container)
    
}
