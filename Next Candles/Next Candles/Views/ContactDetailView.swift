//
//  ContactDetailView.swift
//  Next Candles
//
//  Created by Frank Anderson on 12/20/23.
//

import SwiftUI
import Contacts
import ContactsUI
import SwiftData

enum ContactSheetType: Identifiable {
    var id: Self {
        return self
    }
    
    case call, text
}

struct PhoneSheet: View {
    @Environment(\.openURL) var openURL
    var contact: Contact
    var sheetType: ContactSheetType
    
    var body: some View {
        List(contact.phones, id: \.self) { phone in
            Button(phone, systemImage: sheetType == .call ? "phone" : "message") {
                if let url = URL(string: (sheetType == .call ? "tel://" : "sms:") + phone) {
                    openURL.callAsFunction(url)
                }
            }
            .foregroundStyle(.mint)
        }
    }
}

struct ContactDetailView: View {
    
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    
    @State var phoneSheet: ContactSheetType = .call
    @State var showPhoneSheet = false
    
    var contact: Contact
    
    func customButton(systemName: String, text: String, bg: AnyGradient, action: @escaping () -> Void) -> some View {
        return Button(action: action) {
            VStack {
                Image(systemName: systemName)
                    .foregroundStyle(.white)
                    .imageScale(.large)
                
                Text(text)
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                    .offset(y: 2)
            }
            .frame(width: 80, height: 84)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(bg)
            }
        }
    }
    
    func customWideButton(systemName: String, text: String, bg: AnyGradient, action: @escaping () -> Void) -> some View {
        return Button(action: action) {
            HStack(spacing: 16) {
                VStack {
                    Image(systemName: systemName)
                        .foregroundStyle(.white)
                        .imageScale(.large)
                }
                .frame(width: 60, height: 60)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(bg)
                }
                
                Text(text)
                    .font(.system(.title3, design: .rounded, weight: .medium))
                    .foregroundStyle(
                        colorScheme == .light
                        ? .black.opacity(0.8)
                        : .white.opacity(0.8)
                    )
                
                Spacer()
            }
            .padding(8)
            .background {
                Group {
                    colorScheme == .light ? Color.white : Color.gray.opacity(0.3)
                }
                .cornerRadius(20)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Rectangle()
                .fill(Color.pink.gradient)
                .ignoresSafeArea(.all, edges: .top)
                .frame(height: 180)
            
            Group {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white, .gray)
                    .frame(width: 180, height: 180)
                    .background {
                        Circle().fill(.white)
                    }
                    .overlay {
                        Circle().stroke(.white, lineWidth: 12)
                    }
                
                
                Text(contact.name)
                    .font(.system(.largeTitle, design: .rounded, weight: .semibold))
                    .padding(.top, 12)
                
                if let ca = (contact.age) {
                    Text("\(ca) going on \(ca + 1)")
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .italic()
                        .foregroundStyle(.secondary)
                    
                }
                
                Group {
                    if (contact.year != nil) {
                        Text((contact.birthdate ?? Date()).formatted(
                            .dateTime
                                .day()
                                .month(
                                    .wide
                                )
                                .year()
                        ))
                    }
                    
                    if (contact.year == nil) {
                        Text((contact.birthdate ?? Date()).formatted(
                            .dateTime
                                .day()
                                .month(
                                    .wide
                                )
                        ))
                    }
                }
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundStyle(.white)
                .padding()
                .background {
                    Capsule()
                        .fill(.pink.gradient)
                }
                
                Divider()
                    .padding(.top, 12)
                
                HStack(spacing: 0) {
                    
                    //                    if (contact.contactAppIdentifier != nil) {
                    customButton(systemName: "phone.fill", text: "Call", bg: Color.green.gradient) {
                        phoneSheet = .call
                        showPhoneSheet.toggle()
                    }
                    Spacer()
                    customButton(systemName: "message.fill", text: "Text", bg: Color.mint.gradient) {
                        phoneSheet = .text
                        showPhoneSheet.toggle()
                    }
                    Spacer()
                    //                    }
                    
                    customButton(systemName: "bell.fill", text: contact.hasNotifs ? "Silence" : "Notify", bg: contact.hasNotifs ? Color.secondary.gradient : Color.yellow.gradient) {
                        if (contact.hasNotifs) {
                            if let n = contact.notif {
                                NotificationsHelper.removeNotifs(notifIds: [n])
                                contact.notif = nil
                            }
                        } else {
                            Task {
                                try await contact.setNotifs(distanceFromBD: 0)
                            }
                        }
                    }
                    
                    Spacer()
                    customButton(systemName: contact.hidden ? "eye.fill" : "eye.slash.fill", text: contact.hidden ? "Show" : "Hide", bg: contact.hidden ? Color.secondary.gradient : Color.orange.gradient ) {
                        contact.hidden.toggle()
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal)
                
                Divider()
                
                VStack(spacing: 12) {
                    customWideButton(systemName: "trash.fill", text: "Delete from Next Candles", bg: Color.pink.gradient) {
                        modelContext.delete(contact)
                    }
                }
                .padding()
            }
            .offset(y: -120)
            
            Spacer()
        }
        .background {
            Rectangle()
                .fill(colorScheme == .light ? Color.white.gradient : Color.black.gradient)
                .ignoresSafeArea(.all, edges: .bottom)
        }
        .sheet(isPresented: $showPhoneSheet) {
            switch phoneSheet {
            case .call:
                PhoneSheet(contact: contact, sheetType: .call)
                    .presentationDetents(
                        [.height(180)]
                    )
            case .text:
                PhoneSheet(contact: contact, sheetType: .text)
                    .presentationDetents(
                        [.height(180)]
                    )
            }
        }
    }
}

#Preview {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, configurations: config)
    
    let contact = Contact(givenName: "Frank", familyName: "Anderson", month: 2, day: 7, year: 2003)
    return ContactDetailView(contact: contact)
        .modelContainer(container)
}
