//
//  ContactView.swift
//  Next Candles
//
//  Created by Frank Anderson on 11/25/23.
//

import SwiftUI

struct ContactView: View {
    
    let contact: Contact
    var dayRange: Int? = nil
    
    var body: some View {
        HStack {
            Text(contact.name)
                .font(.headline)
                .lineLimit(2)
                .truncationMode(.tail)
            Spacer()
            Text(
                (contact.birthdate ?? Date())
                    .formatted(
                        .dateTime
                            .day()
                            .month(.abbreviated)
                            .weekday(.wide)
                    )
            )
            .font(.subheadline)
            .foregroundColor((dayRange != nil && contact.withinNextXDays(x: dayRange ?? 0)) ? .pink : .secondary)
        }
    }
}

#Preview {
    List {
        ContactView(contact: Contact(givenName: "Malcolm", familyName: "Anderson", month: 3, day: 7, year: 1935), dayRange: 20)

        ContactView(contact: Contact(givenName: "Malcolm", familyName: "Anderson", month: 3, day: 7, year: 1935), dayRange: 20)

        ContactView(contact: Contact(givenName: "Malcolm", familyName: "Anderson", month: 3, day: 7, year: 1935), dayRange: 20)

    }
}
