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
                $0.month == m && $0.hidden == false
            },
            sort: [ SortDescriptor(\Contact.day) ],
            animation: .default
        )
        self.monthSymbol = month
    }
    
    @AppStorage(S.monthIndexKey) var monthIndex = S.monthIndexDefault
    var shortSymbol: String {
        if monthIndex == .hashed && contacts.isEmpty { "-" } else {
            String(monthSymbol.first ?? Character(""))
        }
    }
    
    @AppStorage(S.emptyMonthSectionKey) var emptyMonthSection = S.emptyMonthSectionDefault
    
    var body: some View {
        Group {
            if emptyMonthSection == .shown || !contacts.isEmpty {
                Section {
                    ForEach(contacts) { ContactListRow(contact: $0) }
                } header: {
                    HStack {
                        Text(monthSymbol)
                        
                        Spacer()
                        
                        if contacts.isEmpty { Text("-") }
                    }
                }
                .sectionIndexLabel(monthIndex == .hidden ? Text("") : Text(shortSymbol)
                )
                .id(monthIndex.rawValue)
            }
        }
    }
}

struct ContactList: View {
    @AppStorage(S.monthTopKey) var monthTop = S.monthTopDefault
    
    let months = Calendar.current.monthSymbols
    
    var sortedMonths: [String] {
        
        if monthTop == .current { 
            let currentMonth = Calendar.current.component(.month, from: Date())
            let remainingThisYear = months[(currentMonth-1)...]
            let startOfNextYear = months[..<(currentMonth-1)]
            return Array(remainingThisYear) + Array(startOfNextYear)
        } else {
            return months
        }
    }
    
    var yearDivider: some View {
        if monthTop == .current {
            VStack {
                Text(String(Calendar.current.component(.year, from: Date())))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Line()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .fill(.secondary)
                    .frame(height: 1)
                
                Text(String(Calendar.current.component(.year, from: Date()) + 1))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } else {
            VStack {
                Text(String(Calendar.current.component(.year, from: Date()) + 1))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Line()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .fill(.secondary)
                    .frame(height: 1)
                
                Text(String(Calendar.current.component(.year, from: Date())))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    var body: some View {
        List(Array(sortedMonths.enumerated()), id: \.offset) { index, month in
            
            let m = DateFormatter().monthSymbols[Calendar.current.component(.month, from: Date()) - 1]
            
            if monthTop == .january && (month == m && sortedMonths.last != m) {
               yearDivider
               .listRowSeparator(.hidden)
               .listRowBackground(Color.clear)
            }
            
            ContactListSection(month: month)
            
            if monthTop == .current && (month == "December" && sortedMonths.last != "December") {
               yearDivider
               .listRowSeparator(.hidden)
               .listRowBackground(Color.clear)
            }
        }
    }
}



#Preview {
    ContentView()
        .applyEnvironment(prePopulate: true)
}
