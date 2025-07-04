//
//  ContentView.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/4/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    
    @Environment(Router.self) var router
    @Query var contacts: [Contact]
    
    var noContactsView: some View {
        ContentUnavailableView(
            "No birthdays found",
            systemImage: "birthday.cake",
            description: Text("In **Settings \(Image(systemName: "gear"))**, you can add birthdays with **Import from Contacts \(Image(systemName: "doc.text.magnifyingglass"))** or **Add Manually \(Image(systemName: "person.fill.badge.plus"))**.")
        )
    }
    
    var body: some View {
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
            .toolbar { ContactListToolbar() }
        }
        .sheet(isPresented: router.sheetIsPresentedBinding) {
            Group {
                if let rs = router.sheet {
                    rs.correspondingView()
                }
            }
        }
        .task {
            if contacts.isEmpty {
                
            }
        }
    }
}

#Preview {
    ContentView()
        .applyEnvironment(prePopulate: true)
}
