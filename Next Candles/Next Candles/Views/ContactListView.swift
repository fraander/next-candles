//
//  ContactListView.swift
//  Next Candles
//
//  Created by Frank Anderson on 11/20/23.
//

import SwiftUI
import SwiftData

struct ContactListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Contact> { contact in
        contact.month != nil && contact.day != nil && contact.hidden == false
    }, sort: [SortDescriptor(\Contact.month), SortDescriptor(\Contact.day), SortDescriptor(\Contact.year)]) private var contacts: [Contact]
    
    var body: some View {
        NavigationStack {
            List {
                
                // https://stackoverflow.com/questions/58142962/how-do-i-separate-events-into-different-sections-of-a-list-based-on-a-date-in-sw
                
                ForEach(contacts) { contact in
                    HStack {
                        Text(contact.name)
                            .font(.headline)
                        Spacer()
                        Text(
                            (contact.birthdate ?? Date())
                                .formatted(
                                    .dateTime
                                        .day()
                                        .month(.wide)
                                        .weekday(.wide)
                                )
                        )
                        .font(.subheadline)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button("Hide", systemImage: "eye.slash") { hide(contact)}
                            .tint(.orange)
                    }
                }
            }
            .navigationTitle("Contacts")
            .task {
                if (contacts.isEmpty) {
                    fetch()
                }
            }
        }
    }
    
    func delete(_ indexSet: IndexSet) {
        indexSet.forEach { modelContext.delete(contacts[$0]) }
    }
    
    func hide(_ contact: Contact) {
        contact.hidden = true
    }
    
    func fetch() {
        Task {
            let fetched = try await ContactsUtils.fetch()
            if (fetched.count > 0) {
                fetched.forEach { modelContext.insert($0) }
            } else {
                print("Error fetching from device.")
            }
        }
    }
}

#Preview {
    
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, configurations: config)
    
    return ContactListView()
        .modelContainer(container)
    
    
    
}
