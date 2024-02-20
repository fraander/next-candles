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
    @EnvironmentObject private var settings: Settings
    @Query(filter: #Predicate<Contact> {  !$0.hidden }) private var contacts: [Contact]
    
    @State var loadingContacts: LoadingState = .waiting
    @State var sheet: SheetType? = nil
    @State var dayRangeAlert = false
    
    @State var path: [Contact] = []
    
    var months: [Int] {
        let allMonths = contacts.compactMap(\.month)
        let sortedMonths: [Int] = Set(allMonths).sorted { $0 < $1 }
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        if (settings.janStart) {
            return sortedMonths
        }
        
        var top: [Int] = []
        var bottom: [Int] = []
        
        for month in sortedMonths {
            if (month >= currentMonth) {
                top.append(month)
            } else {
                bottom.append(month)
            }
        }
        
        return top + bottom
    }
    
    var noContactsView: some View {
        VStack {
            ContentUnavailableView(
                "No birthdays found",
                systemImage: "birthday.cake",
                description: Text("In **Settings \(Image(systemName: "gear"))**, you can add birthdays with **Import from Contacts \(Image(systemName: "doc.text.magnifyingglass"))** or **Add Manually \(Image(systemName: "person.fill.badge.plus"))**.")
            )
        }
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollViewReader { svr in
                if (contacts.count == 0) {
                    noContactsView
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
#if os(iOS)
            .navigationTitle(path.isEmpty ? "Next Candles" : "Back")
            //            #else
            //            .navigationTitle("")
#endif
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    SettingsMenu(sheet: $sheet, dayRangeAlert: $dayRangeAlert)
                }
            }
            .overlay {
                LoadingContactsView(loadingContacts: loadingContacts)
            }
            .sheet(item: $sheet) { item in
                SheetRouter(item: $sheet)
            }
            .alert("Highlight Range", isPresented: $dayRangeAlert) {
                HighlightRangeAlert()
            }
            .onOpenURL { incomingURL in
                print("App was opened via URL: \(incomingURL)")
                handleIncomingURL(incomingURL)
            }
            .navigationDestination(for: Contact.self) { contact in
                ContactDetailView(contact: contact)
            }
        }
        .accentColor(path.isEmpty ? .pink : .white)
    }
    
    private func handleIncomingURL(_ url: URL) {
        guard url.scheme == "nextcandles" else {
            return
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid URL")
            return
        }
        
        guard let contactId = components.queryItems?.first(where: { $0.name == "id" })?.value else {
            print("Contact id not found")
            return
        }
        
        let foundIds = try? modelContext.fetch(FetchDescriptor(predicate: #Predicate<Contact> { $0.identifier == contactId}, sortBy: []))
        
        if let foundFirst = foundIds?.first {
            path.append(foundFirst)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, configurations: config)
    
    return ContactListView()
        .modelContainer(container)
}
