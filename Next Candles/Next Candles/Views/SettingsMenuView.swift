//
//  SettingsMenu.swift
//  Next Candles
//
//  Created by Frank Anderson on 11/25/23.
//

import SwiftUI
import SwiftData

struct SettingsMenu: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject private var settings: Settings
    @Query private var allContacts: [Contact]
    @Query(filter: #Predicate<Contact> { $0.hidden }) private var hiddenContacts: [Contact]
    @Binding var sheet: SheetType?
    @EnvironmentObject var alertRouter: AlertRouter
    @EnvironmentObject var progressRouter: ProgressViewRouter
    @Binding var dayRangeAlert: Bool
    @State var showResolveDiffs = false
    @State var toResolve: [(Contact, Contact)] = []
    
    var allHidden: Bool {
        return allContacts.filter{$0.hidden == false}.count == 0
    }
    
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
                
                Button("Notify all", systemImage: "bell.badge.fill") {
                    progressRouter.isLoading = true
                    allContacts.forEach { c in
                        if !c.hasNotifs && !c.hidden {
                            Task { try await c.setNotifs(distanceFromBD: 0) }
                        }
                    }
                    progressRouter.isLoading = false
                }
                
                Button("Notifs off", systemImage: "bell.slash.fill") {
                    progressRouter.isLoading = true
                    allContacts.forEach { c in
                        NotificationsHelper.removeAllNotifs()
                        c.notif = nil
                    }
                    progressRouter.isLoading = false
                }
                
                Button(allHidden ? "Show All" : "Hide all", systemImage: allHidden ? "eye" : "eye.slash") {
                    let ah = allHidden
                    allContacts.forEach { c in
                        c.hidden = ah ? false : true
                    }
                }
                
                Button("Delete all", systemImage: "trash", role: .destructive) {
                    alertRouter.alert = Alert(
                        title: Text("Delete all Birthdays?"),
                        primaryButton: .destructive(Text("Yes, delete")) {
                            allContacts.forEach { modelContext.delete($0) }
                            NotificationsHelper.removeAllNotifs()
                        },
                        secondaryButton: .cancel(Text("No, cancel"))
                    )
                }
            }
            
            Divider()
            
            Button(!settings.janStart ? "Top: Current month" : "Top: January", systemImage: "platter.filled.top.and.arrow.up.iphone") {
                settings.janStart.toggle()
            }
            
            Button("Highlight Range: \(settings.dayRange) days", systemImage: "circle.lefthalf.striped.horizontal") {
                dayRangeAlert.toggle()
            }
        }
        .tint(.pink)
#if os(iOS)
        .labelStyle(.titleAndIcon)
#endif
        .sheet(isPresented: $showResolveDiffs) {
            DiffView(toResolve: $toResolve)
        }
    }
    
    func fetch() {
        Task {
            let (existing, diffs) = try await ContactsUtils.fetch(existingContacts: allContacts)
            if (existing.count > 0) {
                existing.forEach { modelContext.insert($0) }
            } else if diffs.count != 0 {
                showResolveDiffs = true
                toResolve = diffs
            } else {
                alertRouter.alert = Alert(title: Text("No new contacts to import."))
            }            
        }
    }
}
