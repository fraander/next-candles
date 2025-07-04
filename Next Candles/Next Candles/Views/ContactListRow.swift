//
//  ContactListRow.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/4/25.
//

import SwiftUI

struct ContactListRow: View {
    @Environment(Router.self) var router
    
    var contact: Contact
    
    var body: some View {
        Button {
            router.present(.contact(contact))
        } label: {
            HStack {
                Text(contact.name)
                    .font(.headline)
                
                Spacer()
                
                Text("## days away")
                Spacer()
                    .frame(width: 15)
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    ContentView()
        .applyEnvironment(prePopulate: true)
}
