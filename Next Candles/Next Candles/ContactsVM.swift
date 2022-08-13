//
//  ContactsVM.swift
//  Next Candles
//
//  Created by Frank Anderson on 8/13/22.
//

import Foundation
import Contacts

struct ContactWrapper: Identifiable {
    var id = UUID()
    var content: CNContact
    
    var name: String {
        content.givenName + " " + content.familyName
    }
    
    var hasBirthday: Bool {
        if content.birthday == nil {
            return false
        } else {
            return true
        }
    }
    
    var birthday: Date? {
        if (content.isKeyAvailable(CNContactBirthdayKey)) {
            if let b = content.birthday {
                return Calendar.current.date(from: b)
            }
        }
        
        return nil
    }
    
    var formattedBirthday: String {
        
        if let birthday {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US")
            df.setLocalizedDateFormatFromTemplate("Md")
            
            return df.string(from: birthday)
        } else {
            return ""
        }
    }
    
    init(_ content: CNContact) {
        self.id = UUID()
        self.content = content
    }
}

class ContactsVM: ObservableObject {
    @Published var contacts = [ContactWrapper]()
    
    func fetch() {
        var contacts = [CNContact]()
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactBirthdayKey as CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)
        
        let contactStore = CNContactStore()
        
        do {
            try contactStore.enumerateContacts(with: request) {
                (contact, stop) in
                // Array containing all unified contacts from everywhere
                contacts.append(contact)
            }
        }
        catch {
            print("unable to fetch contacts")
        }
        
        self.contacts = contacts.map({ContactWrapper($0)}).filter({$0.hasBirthday})       
    }
}
