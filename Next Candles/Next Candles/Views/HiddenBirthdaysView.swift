//
//  HiddenBirthdaysView.swift
//  Next Candles
//
//  Created by frank on 8/17/25.
//

import SwiftUI
import SwiftData

struct HiddenBirthdaysView: View {
    
    @Query(filter: #Predicate<Contact> { $0.hidden == true }) var contacts: [Contact]
    
    @State var query: String = ""
    
    var filteredContacts: [Contact] {
        if query.trimmingCharacters(in: .whitespaces).isEmpty {
            return contacts
        }
        
        let searchText = query.lowercased().trimmingCharacters(in: .whitespaces)
        
        return contacts.filter { contact in
            // Search in names
            if let givenName = contact.givenName, givenName.lowercased().contains(searchText) {
                return true
            }
            if let familyName = contact.familyName, familyName.lowercased().contains(searchText) {
                return true
            }
            if let nickname = contact.nickname, nickname.lowercased().contains(searchText) {
                return true
            }
            
            // Search in full name
            if contact.name.lowercased().contains(searchText) {
                return true
            }
            
            // Search in phone numbers
            for phone in contact.phones {
                if phone.lowercased().contains(searchText) {
                    return true
                }
            }
            
            // Search in emails
            for email in contact.emails {
                if email.lowercased().contains(searchText) {
                    return true
                }
            }
            
            // Search in birthdate components
            if let month = contact.month, let day = contact.day {
                // Check if searching for month name
                let monthName = DateFormatter().monthSymbols[month - 1].lowercased()
                let shortMonthName = DateFormatter().shortMonthSymbols[month - 1].lowercased()
                
                if monthName.contains(searchText) || shortMonthName.contains(searchText) {
                    return true
                }
                
                // Check if searching for day
                if String(day).contains(searchText) {
                    return true
                }
                
                // Check if searching for year
                if let year = contact.year, String(year).contains(searchText) {
                    return true
                }
                
                // Check if searching for formatted date (e.g., "June 15", "6/15", "15/6")
                if let birthdate = contact.birthdate {
                    let formatter = DateFormatter()
                    
                    // Full date formats
                    formatter.dateStyle = .long
                    if formatter.string(from: birthdate).lowercased().contains(searchText) {
                        return true
                    }
                    
                    formatter.dateStyle = .medium
                    if formatter.string(from: birthdate).lowercased().contains(searchText) {
                        return true
                    }
                    
                    formatter.dateStyle = .short
                    if formatter.string(from: birthdate).lowercased().contains(searchText) {
                        return true
                    }
                    
                    // Month/day format
                    formatter.dateFormat = "MMMM d"
                    if formatter.string(from: birthdate).lowercased().contains(searchText) {
                        return true
                    }
                    
                    formatter.dateFormat = "MMM d"
                    if formatter.string(from: birthdate).lowercased().contains(searchText) {
                        return true
                    }
                    
                    formatter.dateFormat = "M/d"
                    if formatter.string(from: birthdate).lowercased().contains(searchText) {
                        return true
                    }
                }
            }
            
            return false
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredContacts) { contact in
                HStack {
                    VStack(alignment: .leading) {
                        Text(contact.name)
                            .font(.headline)
                        
                        Text(contact.birthdate?.formatted(.dateTime.month(.wide).day()) ?? "")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Unhide", systemImage: "eye.fill") {
                        withAnimation { contact.hidden = false }
                    }
                    .foregroundStyle(.cyan)
                    .labelStyle(.iconOnly)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    if !contact.hidden {
                        Button("Hide", systemImage: "eye.slash") {
                            contact.hidden.toggle()
                        }
                        .tint(.orange)
                        .labelStyle(.iconOnly)
                    } else {
                        Button("Show", systemImage: "eye") {
                            contact.hidden.toggle()
                        }
                        .tint(.cyan)
                        .labelStyle(.iconOnly)
                    }
                    
                }
            }
            
            if filteredContacts.isEmpty {
                ContentUnavailableView("No hidden contacts found", systemImage: "person.crop.badge.magnifyingglass")
            }
        }
        .searchable(text: $query, prompt: "Search names, dates, phones, emails...")
    }
}

#Preview {
    NavigationView {
        HiddenBirthdaysView()
    }
    .applyEnvironment(prePopulate: true)
}
