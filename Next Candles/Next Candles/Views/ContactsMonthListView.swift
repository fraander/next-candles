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
    
    @Environment(\.modelContext) private var modelContext
    @Query private var contacts: [Contact]
    let dayRange: Int
    
    init(month: Int, dayRange: Int) {
        _contacts = Query(filter: #Predicate<Contact> { contact in
            return (contact.month == month) && (contact.day != nil) && (contact.hidden == false)
        }, sort: [SortDescriptor(\Contact.month), SortDescriptor(\Contact.day), SortDescriptor(\Contact.year)])
        self.dayRange = dayRange
    }
    
    
    
    var body: some View {
        ForEach(contacts) { contact in
            ContactView(contact: contact)
        }
    }
}

#Preview {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, configurations: config)
    
    return ContactsMonthListView(month: 5, dayRange: 20)
        .modelContainer(container)
    
}
