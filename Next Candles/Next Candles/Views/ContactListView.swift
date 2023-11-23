//
//  ContactListView.swift
//  Next Candles
//
//  Created by Frank Anderson on 11/20/23.
//

import SwiftUI
import SwiftData

struct ContactsMonthListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var contacts: [Contact]
    
    init(month: Int) {
        _contacts = Query(filter: #Predicate<Contact> { contact in
            contact.month == month && contact.day != nil && contact.hidden == false
        }, sort: [SortDescriptor(\Contact.month), SortDescriptor(\Contact.day), SortDescriptor(\Contact.year)])
    }
    
    var body: some View {
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
    
    func hide(_ contact: Contact) {
        contact.hidden = true
    }
}


struct ContactListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Contact> {  !$0.hidden }) private var contacts: [Contact]
    
    var months: [Int] {
        let allMonths = contacts.compactMap(\.month)
        return Set(allMonths).sorted { $0 < $1 }
    }
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { svr in
                if (contacts.isEmpty) {
                    VStack {
                        ContentUnavailableView("No birthdays found", systemImage: "birthday.cake", description: Text("Loading from your Contacts..."))
                    }
                } else {
                    List {
                        ForEach(months, id: \.self) { month in
                            Section("\(Calendar.current.monthSymbols[month-1])") {
                                ContactsMonthListView(month: month)
                                    .id(month)
                            }
                        }
                    }
                    .task {
                        let components = Calendar.current.dateComponents([.month], from: Date())
                        let currentMonth = components.month
                        if let currentMonth {
                            if  months.contains(currentMonth) {
                                svr.scrollTo(currentMonth, anchor: .top)
                            }
                        }
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
