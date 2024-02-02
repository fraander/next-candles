//
//  HiddenContactsView.swift
//  Next Candles
//
//  Created by Frank Anderson on 11/25/23.
//

import SwiftUI
import SwiftData

struct HiddenContactsView: View {
    
    @Environment(\.modelContext) var modelContext
    @Query(filter: #Predicate<Contact> { $0.hidden }, sort: [SortDescriptor(\.familyName), SortDescriptor(\.givenName)]) private var contacts: [Contact]
    @State var selectedContacts = Set<Contact>()
    
    @State var searchString: String = ""
    var searchedContacts: [Contact] {
        return searchString.isEmpty ? contacts : contacts.filter { $0.name.localizedStandardContains(searchString) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if (contacts.isEmpty) {
                    ContentUnavailableView("No birthdays are hidden", systemImage: "eye.slash", description: Text("You can swipe a birthday from right to left and tap the \(Image(systemName: "eye.slash")) icon to hide."))
                } else {
                    List(searchedContacts, id: \.self, selection: $selectedContacts) { contact in
                        ContactView(contact: contact)
                    }
                    .searchable(text: $searchString, placement: .navigationBarDrawer(displayMode: .always))
                }
            }
            .navigationTitle("Hidden")
            .toolbar {
                if (!selectedContacts.isEmpty && !contacts.isEmpty) {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        selectedContacts.forEach { modelContext.delete($0) }
                    }
                    
                    Button("Unhide", systemImage: "eye") {
                        selectedContacts.forEach { $0.hidden = false }
                    }
                }
                
                if (!contacts.isEmpty) {
                    #if os(iOS)
                    EditButton()
                    #endif
                }
            }
        }
    }
}

#Preview {
    HiddenContactsView()
}
