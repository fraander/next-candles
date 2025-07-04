//
//  DiffView.swift
//  Next Candles
//
//  Created by Frank Anderson on 12/26/23.
//

import SwiftUI
import SwiftData

struct DiffViewRow: View {
    @Environment(\.modelContext) var modelContext
    @Query private var allContacts: [Contact]
    
    @Binding var toResolve: [(Contact?, Contact)]
    var old: Contact?
    var new: Contact
    
    var body: some View {
        HStack {
            VStack {
                if let old = old {
                    VStack(alignment: .leading) {
                        Text("Existing")
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                        Text(old.name)
                            .bold()
                        
                        if let on = old.nickname {
                            if old.nickname != new.nickname {
                                Text(on)
                            }
                        }
                        if old.birthdate != new.birthdate {
                            Text((old.birthdate ?? Date()).formatted(
                                .dateTime.day().month(.wide)
                            ))
                        }
                        
                        if let oy = old.year {
                            if old.year != new.year {
                                Text(verbatim: "\(oy)")
                            }
                        }
                        
                        if old.phones != new.phones {
                            Text("Phone Numbers:")
                            ForEach(old.phones, id: \.self) { phone in
                                if (!new.phones.contains(phone)) {
                                    Text("   \(phone)")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.pink.opacity(0.2), in: RoundedRectangle(cornerRadius: 12))
                }
                
                VStack(alignment: .leading) {
                    Text("New")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                    Text(new.name)
                        .bold()
                    if let on = new.nickname {
                        if old?.nickname != new.nickname {
                            Text(on)
                        }
                    }
                    if old?.birthdate != new.birthdate {
                        Text((new.birthdate ?? Date()).formatted(
                            .dateTime.day().month(.wide)
                        ))
                    }
                    
                    if let oy = new.year {
                        if old?.year != new.year {
                            Text(verbatim: "\(oy)")
                        }
                    }
                    
                    if old?.phones != new.phones {
                        Text("Phone Numbers:")
                        ForEach(new.phones, id: \.self) { phone in
                            if (((old?.phones.contains(phone)) == nil)) {
                                Text("   \(phone)")
                                    .font(.caption)
                            }
                        }
                    }
                    
                    if old?.emails != new.emails {
                        Text("Email Addresses:")
                        ForEach(new.emails, id: \.self) { email in
                            if ((old?.emails.contains(email)) != nil) {
                                Text("   \(email)")
                                    .font(.caption)
                            }
                        }
                    }
                    
                    if old?.image != new.image {
                        Text("Image updated")
                            .font(.caption)
                            .italic()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.mint.opacity(0.2), in: RoundedRectangle(cornerRadius: 12))
            }
            
            Button {
                resolveContact()
            } label: {
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text(old == nil ? "Insert" : "Update")
                }
                .foregroundStyle(.mint)
                .bold()
            }
            .padding(.leading, 10)
        }
        .padding(.bottom)
    }
    
    func resolveContact() {
        
        if let old = old {
            // find in query
            let found = allContacts.filter { contact in
                contact.identifier == old.identifier
            }.first
            
            // update
            found?.familyName = new.familyName
            found?.givenName = new.givenName
            found?.day = new.day
            found?.month = new.month
            found?.year = new.year
            found?.nickname = new.nickname
            found?.phones = new.phones
            found?.image = new.image
            found?.emails = new.emails
        } else {
            modelContext.insert(new)
        }
        
        // Remove from queue
        toResolve.removeAll { contacts in
            contacts.1.identifier == new.identifier
        }
    }
}

struct DiffView: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var toResolve: [(Contact?, Contact)]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView(.vertical) {
                    VStack {
                        
                        if !(toResolve.count > 0) {
                            ContentUnavailableView {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            } description: {
                                Text("All updates resolved.")
                                    .foregroundStyle(.secondary)
                            }
                            .transition(.scale)
                        }
                        
                        ForEach(toResolve, id: \.1.identifier) { old, new in
                            DiffViewRow(toResolve: $toResolve, old: old, new: new)
                        }
                    }
                    .padding(.vertical)
                    .animation(.default, value: !(toResolve.count > 0))
                }
                
            }
            .padding(.horizontal)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Changes")
                        .font(.headline)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close", systemImage: "chevron.down", role: .close) { dismiss() }
                }
            }
        }
    }
}
