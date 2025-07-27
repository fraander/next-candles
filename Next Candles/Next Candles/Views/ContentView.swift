//
//  ContentView.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/4/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    
    @Environment(\.scenePhase) var scenePhase
    
    @Environment(NotificationManager.self) var notifs
    @Environment(Router.self) var router
    
    @Environment(\.modelContext) var modelContext
    @Query var contacts: [Contact]
    
    @State var diffs: [(Contact?, Contact)] = []
    @State var showResolveDiffs = false
    @State var showFetchAlert = false
    
    var noContactsView: some View {
        ContentUnavailableView(
            "No birthdays found",
            systemImage: "birthday.cake",
            description: Text("In **Settings \(Image(systemName: "gear"))**, you can add birthdays with **Import from Contacts \(Image(systemName: "doc.text.magnifyingglass"))** or **Add Manually \(Image(systemName: "person.fill.badge.plus"))**.")
        )
    }
    
    @Namespace private var transitionNamespace
    
    var body: some View {
        let presentSheetForContactBinding: Binding<Bool> = .init(
            get: { router.sheet == .settings },
            set: { if $0 {} else { router.popToHome() } }
        )
        
        NavigationView {
            ZStack {
                BackgroundView(color: .accentColor)
                
                if contacts.isEmpty {
                    noContactsView
                } else {
                    ContactList()
                        .scrollContentBackground(.hidden)
                }
            }
            .toolbar { ContactListToolbar(transitionNamespace: transitionNamespace) }
            .navigationTitle("Next Candles")
        }
        .sheet(isPresented: presentSheetForContactBinding) {
            SettingsView()
                .navigationTransition(.zoom(sourceID: "settings", in: transitionNamespace))
        }
        .sheet(isPresented: $showResolveDiffs) {
            DiffView(toResolve: $diffs)
        }
        .task {
            Task {
                await notifs.requestPermission()
                await notifs.updateNotifications()
            }
            
            if contacts.isEmpty {
                fetch(showNoNewAlert: true)
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active && !contacts.isEmpty {
                fetch(showNoNewAlert: false)
            }
        }
        .alert(
            "No new contacts to import.",
            isPresented: $showFetchAlert,
            actions: {}
        )
    }
    
    func fetch(showNoNewAlert: Bool = true) {
        Task {
            let (_, diffs) = try await ContactsUtils.fetch(existingContacts: contacts)
            if diffs.count != 0 {
                self.showResolveDiffs = true
                self.diffs = diffs
            } else {
                if showNoNewAlert { showFetchAlert.toggle() }
            }
        }
    }
}

#Preview {
    ContentView()
        .applyEnvironment(prePopulate: false)
}
