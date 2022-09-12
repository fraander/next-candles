//
//  ContactsVM.swift
//  Next Candles
//
//  Created by Frank Anderson on 8/13/22.
//

import Foundation
import Contacts

class ContactsVM: ObservableObject {
    @Published var contacts = [ContactWrapper]()
    
    var months: [MonthWrapper] {
        return collapser(input: contacts)
    }
    
    // fetch the contacts from the system and create ContactWrappers from the useful ones
    // throws error if trouble fetching from System; returns [] if no valid contacts are found
    func fetch() async throws -> [ContactWrapper] {
        var contacts: [ContactWrapper] = [] // fetched Contacts (that have valid birthdays and names)
        
        let store = CNContactStore() // store to access system contacts
        let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactBirthdayKey as CNKeyDescriptor]) // attributes to request so that the size is small
        
        do {
            try store.enumerateContacts(with: fetchRequest) { contact, _ in // iterate over every contact ...
                if (contact.areKeysAvailable([CNContactGivenNameKey as CNKeyDescriptor, CNContactBirthdayKey as CNKeyDescriptor])) { // check they have required fields before fetching
                    // TODO: profile photos?
                    
                    // get each field and initialize
                    let _ = try? contacts.append(
                        ContactWrapper(firstName: contact.givenName,
                                       lastName: contact.familyName,
                                       month: contact.birthday?.month,
                                       day: contact.birthday?.day,
                                       year: contact.birthday?.year)
                    )
                }
            }
        } catch { // if there's an issue ...
            throw ContactCodingError.fetch // there was an issue fetching (because decode errors are handled in teh initializer)
        }
        
        return contacts // looked over those contacts, let's play!
    }
    
    // Converts list of numbers into list of lists of each occurrence of each number, sorted from least to greatest
    func collapser(input: [ContactWrapper]) -> [MonthWrapper] {
        let base: [MonthWrapper] = [] // if no numbers exist, produce an empty array of arrays; easier for readability
        let reduced = input.reduce(base) {reducer(soFar: $0, next: $1)} // collapse the list into the list of lists
        return sorter(reduced: reduced) // sort them
    }
    
    // Converts list of months into list of lists of each occurrence of each number
    func reducer(soFar: [MonthWrapper], next: ContactWrapper) -> [MonthWrapper] {
        // create mutable version of soFar
        var new = soFar
        
        // find int array and add it to that one
        for index in 0..<new.count {
            // check if the number has already appeared
            if (new[index].contacts.first?.month == next.month) {
                // if so, add this instance to the already existing array
                new[index].contacts += [next]
                return new // produce the result
            }
        }
        
        // if you've reached this far, the number is a new occurrence...
        // create a new array to hold instances and add this instance
        new.append(MonthWrapper(contacts: [next], monthInt: next.month))
        return new // produce the result
    }
    
    // Sorts months from least to greatest
    func sorter(reduced: [MonthWrapper]) -> [MonthWrapper] {
        return reduced.sorted()
    }
}
