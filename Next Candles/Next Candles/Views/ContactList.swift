//
//  ContactList.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/4/25.
//

import SwiftUI
import SwiftData

struct ContactListSection: View {
    @Environment(\.modelContext) var modelContext
    @Query var contacts: [Contact]
    let monthSymbol: String
    
    init(month: String) {
        
        var m = 0
        switch month {
        case "January": m = 1
        case "February": m = 2
        case "March": m = 3
        case "April": m = 4
        case "May": m = 5
        case "June": m = 6
        case "July": m = 7
        case "August": m = 8
        case "September": m = 9
        case "October": m = 10
        case "November": m = 11
        case "December": m = 12
        default: break
        }
        
        _contacts = .init(
            filter: #Predicate {
                $0.month == m
            },
            sort: [ SortDescriptor(\Contact.day) ],
            animation: .default
        )
        self.monthSymbol = month
    }
    
    var shortSymbol: String {
        if contacts.isEmpty { "-" } else {
            String(monthSymbol.first ?? Character(""))
        }
    }
    
    var body: some View {
        Section {
            ForEach(contacts) { ContactListRow(contact: $0) }
        } header: {
            HStack {
                Text(monthSymbol)
                
                Spacer()
                
                if contacts.isEmpty { Text("-") }
            }
        }
        .sectionIndexLabel(Text(shortSymbol))
        
    }
}

struct ContactList: View {
    let months = Calendar.current.monthSymbols
    
    var body: some View {
        List(months, id: \.self) { ContactListSection(month: $0) }
    }
}

#Preview {
    ContentView()
        .applyEnvironment(prePopulate: true)
}
