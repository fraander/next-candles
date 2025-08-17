//
//  ContactImportManager.swift
//  Next Candles
//
//  Created by frank on 8/17/25.
//

import Observation
import SwiftUI
import SwiftData

@Observable
class ContactImportManager {
    var resultToShow: Int? = nil
    
    /**
     Imports contacts from the system, compares with app data, and inserts new ones.
     - Parameter modelContext: Your SwiftData model context for contacts.
     */
    func importContacts(modelContext: ModelContext, showAlert: Bool) async {
        // Fetch all existing contacts from SwiftData
        let fetchDescriptor = FetchDescriptor<Contact>()
        guard let existing = try? modelContext.fetch(fetchDescriptor) else { return }
        
        // Fetch contacts from the system, compare
        guard let (_, diffs) = try? await ContactsUtils.fetch(existingContacts: existing) else { return }
        
        // Insert only the new contacts (where old == nil)
        let actuallyNewContacts = diffs.filter { $0.old == nil }.map { $0.new }
        for contact in actuallyNewContacts {
            modelContext.insert(contact)
        }
        
        // Set resultToShow to count of new contacts added
        if showAlert {
            self.resultToShow = actuallyNewContacts.count
        }
    }
}
