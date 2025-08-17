//
//  AddManuallySheet.swift
//  Next Candles
//
//  Created by frank on 8/17/25.
//

import SwiftUI
import Contacts

struct AddManuallySheet: View {
    @State var givenName = ""
    @State var familyName = ""
    @State var nickname = ""
    @State var birthdate = Date()
    @State var phones: [String] = []
    @State var emails: [String] = []
    @State var image: UIImage?
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Name") {
                    TextField("First Name", text: $givenName)
                    TextField("Last Name", text: $familyName)
                    TextField("Nickname (optional)", text: $nickname)
                }
                
                Section("Birthday") {
                    DatePicker("Birthday", selection: $birthdate, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
                
                Section("Photo") {
                    Button(action: { /* Add image picker */ }) {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                        } else {
                            Label("Add Photo", systemImage: "camera")
                        }
                    }
                }
                
                Section("Phone Numbers") {
                    ForEach(phones.indices, id: \.self) { index in
                        HStack {
                            TextField("Phone", text: $phones[index])
                                .keyboardType(.phonePad)
                            Button(action: {
                                phones.remove(at: index)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        phones.remove(atOffsets: indexSet)
                    }
                    
                    Button("Add Phone") {
                        phones.append("")
                    }
                }
                
                Section("Emails") {
                    ForEach(emails.indices, id: \.self) { index in
                        HStack {
                            TextField("Email", text: $emails[index])
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            Button(action: {
                                emails.remove(at: index)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        emails.remove(atOffsets: indexSet)
                    }
                    
                    Button("Add Email") {
                        emails.append("")
                    }
                }
            }
            .navigationTitle("Add Contact manually")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .confirm) { addContact() }
                        .disabled(givenName.isEmpty && familyName.isEmpty && nickname.isEmpty)
                }
            }
        }
    }
    
    private func addContact() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day, .year], from: birthdate)
        
        let phoneNumbers = phones.filter { !$0.isEmpty }.map { phone in
            CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: phone))
        }
        
        let emailAddresses = emails.filter { !$0.isEmpty }.map { email in
            CNLabeledValue(label: CNLabelHome, value: email as NSString)
        }
        
        let imageData = image?.jpegData(compressionQuality: 0.8)
        
        let newContact = Contact(
            identifier: UUID().uuidString,
            givenName: givenName.isEmpty ? nil : givenName,
            familyName: familyName.isEmpty ? nil : familyName,
            nickname: nickname.isEmpty ? nil : nickname,
            month: components.month,
            day: components.day,
            year: components.year,
            phones: phoneNumbers,
            emails: emailAddresses,
            image: imageData
        )
        modelContext.insert(newContact)
        dismiss()
    }
}

#Preview {
    Text("")
        .sheet(isPresented: .constant(true)) {
            AddManuallySheet()
        }
}
