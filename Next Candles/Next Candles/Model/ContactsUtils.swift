//
//  ContactsAPI_Utils.swift
//  Next Candles
//
//  Created by Frank Anderson on 11/21/23.
//

import Foundation
import Contacts

class ContactsUtils {
    // fetch the contacts from the system and create ContactWrappers from the useful ones
    // throws error if trouble fetching from System; returns [] if no valid contacts are found
    static func fetch() async throws -> [Contact] {
        var contacts: [Contact] = [] // fetched Contacts (that have valid birthdays and names)
        
        let store = CNContactStore() // store to access system contacts
        let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactBirthdayKey as CNKeyDescriptor]) // attributes to request so that the size is small
        
        do {
            try store.enumerateContacts(with: fetchRequest) { contact, _ in // iterate over every contact ...
                if (contact.areKeysAvailable([CNContactGivenNameKey as CNKeyDescriptor, CNContactBirthdayKey as CNKeyDescriptor])) { // check they have required fields before fetching
                    // TODO: profile photos?
                    
                    // get each field and initialize
                    contacts.append(
                        Contact(givenName: contact.givenName, familyName: contact.familyName, month: contact.birthday?.month, day: contact.birthday?.day, year: contact.birthday?.year)
                    )
                }
            }
        } catch { // if there's an issue ...
            throw ContactCodingError.fetch // there was an issue fetching (because decode errors are handled in teh initializer)
        }
        
        return contacts // looked over those contacts, let's play!
    }
    
}
