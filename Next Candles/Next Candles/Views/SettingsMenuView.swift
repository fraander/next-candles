//
//  SettingsMenu.swift
//  Next Candles
//
//  Created by Frank Anderson on 11/25/23.
//

import SwiftUI
import SwiftData

struct SettingsMenu: View {
    
    @Environment(\.modelContext) var modelContext
    @Query private var allContacts: [Contact]
    @Query(filter: #Predicate<Contact> { $0.hidden }) private var hiddenContacts: [Contact]
    @Binding var sheet: SheetType?
    @State var showDeleteAll = false
    
    var body: some View {
        Menu("Settings", systemImage: "gear") {
            if (!hiddenContacts.isEmpty) {
                Button("Hidden Birthdays", systemImage: "eye.slash", action: {sheet = .hidden})
                Divider()                
            }
            Button("Import from Contacts", systemImage: "doc.text.magnifyingglass") { fetch() }
            Button("Add Manually", systemImage: "person.fill.badge.plus") { sheet = .custom }
            
            if (!allContacts.isEmpty) {
                Divider()
                Button("Delete all", systemImage: "trash", role: .destructive) { showDeleteAll = true }
            }
            
        }
        .labelStyle(.titleAndIcon)
        .alert("Delete all Birthdays?", isPresented: $showDeleteAll) {
            Button("No, cancel", role: .cancel, action: { showDeleteAll = false })
            Button("Yes, delete", role: .destructive) { allContacts.forEach { modelContext.delete($0) } }
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
    SettingsMenu(sheet: .constant(.hidden))
}
