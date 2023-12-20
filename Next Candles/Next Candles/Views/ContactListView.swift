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
            ContentUnavailableView("No birthdays found", systemImage: "birthday.cake", description: Text("Import Birthdays from Contacts or add some manually in Settings \(Image(systemName: "gear"))"))
        }
    }
    
    var body: some View {
        NavigationStack {
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
            .navigationTitle("Next Candles")
//            #else
//            .navigationTitle("")
            #endif
            .toolbar {
                SettingsMenu(sheet: $sheet, dayRangeAlert: $dayRangeAlert)
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
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, configurations: config)
    
    return ContactListView()
        .modelContainer(container)
}
