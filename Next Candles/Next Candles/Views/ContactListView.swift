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
            return (contact.month == month) && (contact.day != nil) && (contact.hidden == false)
        }, sort: [SortDescriptor(\Contact.month), SortDescriptor(\Contact.day), SortDescriptor(\Contact.year)])
    }
    
    var body: some View {
        ForEach(contacts) { contact in
            HStack {
                Text(contact.name)
                    .font(.headline)
                    .lineLimit(2)
                    .truncationMode(.tail)
                Spacer()
                Text(
                    (contact.birthdate ?? Date())
                        .formatted(
                            .dateTime
                                .day()
                                .month(.abbreviated)
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


enum LoadingState {
    case waiting, failed, loading
}

enum SheetType: Identifiable {
    case custom, /*settings,*/ hidden
    
    var id: Self {
        return self
    }
}


struct ContactListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Contact> {  !$0.hidden }) private var contacts: [Contact]

    @State var loadingContacts: LoadingState = .waiting
    @State var sheet: SheetType? = nil
    
    var months: [Int] {
        let allMonths = contacts.compactMap(\.month)
        return Set(allMonths).sorted { $0 < $1 }
    }
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { svr in
                if (contacts.count == 0) {
                    VStack {
                        ContentUnavailableView {
                            Label("No birthdays found", systemImage: "birthday.cake")
                        } description: {
                            Text("You can try importing some from your Contacts.")
                        } actions: {
                            Button("Search", systemImage: "doc.text.magnifyingglass", action: fetch)
                        }
                    }
                } else {
                    List {
                        ForEach(months, id: \.self) { month in
                            Section("\(Calendar.current.monthSymbols[month-1])") {
                                ContactsMonthListView(month: month, searchText: searchText)
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
            .toolbar {
                Menu("Settings", systemImage: "gear") {
                    Button("Hidden Birthdays", systemImage: "eye.slash", action: {sheet = .hidden})
                    Divider()
                    Button("Import from Contacts", systemImage: "doc.text.magnifyingglass", action: { fetch() })
                    Button("Add Manually", systemImage: "person.fill.badge.plus", action: {sheet = .custom})
                }
                .labelStyle(.titleAndIcon)
            }
            .overlay {
                Group {
                    if (loadingContacts == .loading) {
                        ProgressView()
                    } else if (loadingContacts == .failed) {
                        ContentUnavailableView {
                            Label("Could not find birthdays to import from Contacts.", systemImage: "birthday.cake")
                        } actions: {
                            Button("Try again.", systemImage: "doc.text.magnifyingglass", action: fetch)
                        }
                        
                    }
                }
            }
            .sheet(item: $sheet) { item in
                switch item {
//                case .settings: ContentUnavailableView("Settings", systemImage: "gear")
                case .custom: ContentUnavailableView("Add Manually", systemImage: "person.fill.badge.plus")
                case .hidden: ContentUnavailableView("Hidden Birthdays", systemImage: "eye.slash")
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
