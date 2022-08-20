//
//  ContactsVM.swift
//  Next Candles
//
//  Created by Frank Anderson on 8/13/22.
//

import Foundation
import Contacts

// types of errors from converting CNContact to ContactWrapper
enum ContactCodingError: Error {
    // initializer: doesn't have all valid properties to be wrapped
    // fetch: error in fetching contacts from the store
    case initializer, fetch
}

// wrapper for a contact to make it easier to handle in SwiftUI
struct ContactWrapper: Identifiable {
    var id = UUID()
    var firstName: String
    var lastName: String
    var month: Int
    var day: Int
    var year: Int?
    
    // throwing initializer that only works if all required fields exist.
    init(firstName: String?, lastName: String?, month: Int?, day: Int?, year: Int?) throws {
        // check for valid fields, otherwise throw an error
        guard let firstName = firstName, let month = month, let day = day else {
            throw ContactCodingError.initializer
        }
        
        // fields are valid, so set them all
        self.firstName = firstName
        self.lastName = lastName ?? ""
        self.month = month
        self.day = day
        self.year = year
        
        return // all done :)
    }
}

struct MonthWrapper: Identifiable {
    var id = UUID()
    var contacts: [ContactWrapper]
    var month: String
    
    init(contacts: [ContactWrapper], month: Int) {
        self.contacts = contacts.sorted { lhs, rhs in
            return lhs.day > rhs.day
        }
        
        switch month {
            case 1:
                self.month = "January"
            case 2:
                self.month = "February"
            case 3:
                self.month = "March"
            case 4:
                self.month = "April"
            case 5:
                self.month = "May"
            case 6:
                self.month = "June"
            case 7:
                self.month = "July"
            case 8:
                self.month = "August"
            case 9:
                self.month = "September"
            case 10:
                self.month = "October"
            case 11:
                self.month = "November"
            case 12:
                self.month = "December"
            default:
                self.month = "ERROR"
        }
    }
}

class ContactsVM: ObservableObject {
    @Published var contacts = [ContactWrapper]()
    
    var months: [MonthWrapper] {
        return collapser(input: contacts)
    }
    
    init() {
        do {
            try self.contacts = self.fetch()
        } catch {
            self.contacts = []
        }
    }
    
    // fetch the contacts from the system and create ContactWrappers from the useful ones
    // throws error if trouble fetching from System; returns [] if no valid contacts are found
    func fetch() throws -> [ContactWrapper] {
        var contacts: [ContactWrapper] = [] // fetched Contacts (that have valid birthdays and names)
        
        let store = CNContactStore() // store to access system contacts
        let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactBirthdayKey as CNKeyDescriptor]) // attributes to request so that the size is small
        
        do {
                // TODO: Move this off of the main thread somehow
                try store.enumerateContacts(with: fetchRequest) { contact, _ in // iterate over every contact ...
                    if (contact.areKeysAvailable([CNContactGivenNameKey as CNKeyDescriptor, CNContactBirthdayKey as CNKeyDescriptor])) { // check they have required fields before fetching
                        // TODO: check if familyName can be fetched even without checking it exists. If not, handle appropriately before trying the initializer (because it contains an access for a field that doens't exist in that case)
                        // TODO: profile photos?
                        // TODO: move this all off the main thread; async/await with Jordan Morgan article? HWS article?
                        
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
    
    // Converts list of numbers into list of lists of each occurrence of each number
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
        new.append(MonthWrapper(contacts: [next], month: next.month))
        return new // produce the result
    }
    
    // Sorts positive numbers from least to greatest
    func sorter(reduced: [MonthWrapper]) -> [MonthWrapper] {
        return reduced.sorted(by: { lhs, rhs in
            return lhs.month < rhs.month
        })
    }
}
