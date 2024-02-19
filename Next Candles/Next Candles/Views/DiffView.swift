//
//  DiffView.swift
//  Next Candles
//
//  Created by Frank Anderson on 12/26/23.
//

import SwiftUI
import SwiftData

struct DiffView: View {
    
    @Environment(\.dismiss) var dismiss
    @Query private var allContacts: [Contact]
    @Binding var toResolve: [(Contact, Contact)]
    
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                HStack {
                    Spacer()
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .tint(.mint)
                }
                .padding(.top)
                Text("Changes")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                Group {
                    Text("Tap ")
                    + Text("\(Image(systemName: "checkmark.circle.fill")) Update")
                        .foregroundStyle(.mint)
                        .bold()
                    + Text(" to approve changes. \nTap ")
                    + Text("Done")
                        .foregroundStyle(.mint)
                        .bold()
                    + Text(" when you're finished.")
                }
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom)
            }
            
            Divider()
            
            ScrollView(.vertical) {
                VStack {
                    
                    if toResolve.count > 0 {
                        
                    } else {
                        ContentUnavailableView {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.secondary)
                        } description: {
                            Text("All updates resolved.")
                                .foregroundStyle(.secondary)
                        } /* actions: {
                            Button("Done", systemImage: "checkmark", action: {dismiss()})
                                .tint(.mint)
                                .buttonStyle(.bordered)
                        } */
                    }
                    
                    ForEach(toResolve, id: \.0.identifier) { new, old in
                        HStack {
                            VStack {
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
                                
                                VStack(alignment: .leading) {
                                    Text("New")
                                        .font(.system(.caption, design: .rounded, weight: .semibold))
                                    Text(new.name)
                                        .bold()
                                    if let on = new.nickname {
                                        if old.nickname != new.nickname {
                                            Text(on)
                                        }
                                    }
                                    if old.birthdate != new.birthdate {
                                        Text((new.birthdate ?? Date()).formatted(
                                            .dateTime.day().month(.wide)
                                        ))
                                    }
                                    
                                    if let oy = new.year {
                                        if old.year != new.year {
                                            Text(verbatim: "\(oy)")
                                        }
                                    }
                                    
                                    if old.phones != new.phones {
                                        Text("Phone Numbers:")
                                        ForEach(new.phones, id: \.self) { phone in
                                            if (!old.phones.contains(phone)) {
                                                Text("   \(phone)")
                                                    .font(.caption)
                                            }
                                        }
                                    }
                                    
                                    if old.emails != new.emails {
                                        Text("Email Addresses:")
                                        ForEach(new.emails, id: \.self) { email in
                                            if (!old.emails.contains(email)) {
                                                Text("   \(email)")
                                                    .font(.caption)
                                            }
                                        }
                                    }
                                    
                                    if old.image != new.image {
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
                                
                                // Remove from queue
                                toResolve.removeAll { contacts in
                                    contacts.0.identifier == old.identifier
                                }
                            } label: {
                                VStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Update")
                                }
                                .foregroundStyle(.mint)
                                .bold()
                            }
                            .padding(.leading, 10)
                        }
                        .padding(.bottom)
                    }
                }
                .padding(.vertical)
            }
            
        }
        .padding(.horizontal)
    }
}
