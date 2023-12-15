//
//  ContactView.swift
//  Next Candles
//
//  Created by Frank Anderson on 11/25/23.
//

import SwiftUI
import SwiftData

@Observable
class ContactVM {
    var contact: Contact
    var dayRange: Int? = nil

    init(contact: Contact, dayRange: Int?) {
        self.contact = contact
        self.dayRange = dayRange
    }
    convenience init(contact: Contact) {
        self.init(contact: contact, dayRange: nil)
    }
}


struct ContactView: View {
    
    var vm: ContactVM
    
    init(vm: ContactVM) {
        self.vm = vm
    }
    
    var body: some View {
        HStack {
            Text(vm.contact.name)
                .font(.headline)
                .lineLimit(2)
                .truncationMode(.tail)
            Spacer()
            Text(
                (vm.contact.birthdate ?? Date())
                    .formatted(
                        .dateTime
                            .day()
                            .month(.abbreviated)
                            .weekday(.wide)
                    )
            )
            .font(.subheadline)
            .foregroundColor((vm.dayRange != nil && vm.contact.withinNextXDays(x: vm.dayRange ?? 0)) ? .pink : .secondary)
            
            if (vm.contact.notif != nil) {
                Image(systemName: "bell.fill")
                    .font(.subheadline)
                    .foregroundColor((vm.dayRange != nil && vm.contact.withinNextXDays(x: vm.dayRange ?? 0)) ? .pink : .secondary)
            }
        }
    }
}
