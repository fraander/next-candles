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
    @EnvironmentObject private var settings: Settings
    @Query private var allContacts: [Contact]
    @Query(filter: #Predicate<Contact> { $0.hidden }) private var hiddenContacts: [Contact]
    @Binding var sheet: SheetType?
    @State var showDeleteAll = false
    @Binding var dayRangeAlert: Bool
    
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
            
            Divider() 
            
            Button(!settings.janStart ? "Top: Current month" : "Top: January", systemImage: "platter.filled.top.and.arrow.up.iphone") {
                settings.janStart.toggle()
            }
            
            Button("Highlight Range: \(settings.dayRange) days", systemImage: "circle.lefthalf.striped.horizontal") {
                dayRangeAlert.toggle()
            }
            
//            Divider()
//            
//            Button("Log notifications", systemImage: "apple.terminal.fill") {
//                Task {
//                    
//                    print("All nids:", allContacts.compactMap(\.notifs))
//                    
//                    print("Printing Pending notifications")
//                    await NotificationsHelper.printAllPendingNotifs()
//                    print("---")
//                }
//            }
            
        }
        .tint(.pink)
        #if os(iOS)
        .labelStyle(.titleAndIcon)
        #endif
        .alert("Delete all Birthdays?", isPresented: $showDeleteAll) {
            Button("No, cancel", role: .cancel, action: { showDeleteAll = false })
            Button("Yes, delete", role: .destructive) {
                allContacts.forEach { modelContext.delete($0) }
                NotificationsHelper.removeAllNotifs()
            }
        }
    }
    
    func fetch() {
        Task {
            let fetched = try await ContactsUtils.fetch(existingContacts: allContacts)
            if (fetched.count > 0) {
                fetched.forEach { modelContext.insert($0) }
            } else {
                print("No new contacts were added.")
            }
        }
    }
}
