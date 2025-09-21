//
//  ContactsAPI_Utils.swift
//  Next Candles
//
//  Created by Frank Anderson on 11/21/23.
//

import Foundation
import Contacts

struct ContactFetchResponse {
    let found: [Contact]
    let diff: [Contact]
}

class ContactsUtils {
    // fetch the contacts from the system and create ContactWrappers from the useful ones
    // throws error if trouble fetching from System; returns [] if no valid contacts are found
    static func fetch(existingContacts: [Contact]) async throws -> ([Contact], [(old: Contact?, new: Contact)]) {
        var contacts: [Contact] = [] // fetched Contacts (that have valid birthdays and names)
        var diffs: [(old: Contact?, new: Contact)] = []
        
        let store = CNContactStore() // store to access system contacts
        let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactBirthdayKey as CNKeyDescriptor, CNContactNicknameKey as CNKeyDescriptor, CNContactIdentifierKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor]) // attributes to request so that the size is small
        
        do {
            try store.enumerateContacts(with: fetchRequest) { contact, _ in // iterate over every contact ...
                
                // find (or don't find) existing contact
                if let existing = existingContacts.first(where: {$0.identifier == contact.identifier}) {
                    if let new = createContact(contact: contact) {
                        if Contact.areDifferent(new, existing) {
                            diffs.append((existing, new))
                        }
                    }
                } else { // if new
                    if let c = createContact(contact: contact) {
                        contacts.append( c )
                        diffs.append((nil, c))
                    }
                }
            }
        } catch { // if there's an issue ...
            throw ContactCodingError.fetch // there was an issue fetching (because decode errors are handled in teh initializer)
        }
        
        return (contacts, diffs) // looked over those contacts, let's play!
    }
    
    static func createContact(contact: CNContact) -> Contact? {
        if (contact.areKeysAvailable([CNContactGivenNameKey as CNKeyDescriptor, CNContactBirthdayKey as CNKeyDescriptor]) && contact.birthday?.month != nil && contact.birthday?.day != nil) { // check they have required fields before fetching
            // get each field and initialize
            return Contact(identifier: contact.identifier, givenName: contact.givenName, familyName: contact.familyName, nickname: contact.nickname, month: contact.birthday?.month, day: contact.birthday?.day, year: contact.birthday?.year, phones: contact.phoneNumbers, emails: contact.emailAddresses, image: contact.imageData)
        } else {
            return nil
        }
    }
}
