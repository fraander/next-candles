//
//  ContactDetailView.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/4/25.
//

import SwiftUI

struct ContactDetailView: View {
    @Environment(Router.self) var router
    @Environment(\.modelContext) var modelContext
    
    @State var showDeleteConfirmation = false
    
    var contact: Contact
    
    var profileImage: some View {
        Group {
            if let imageData = contact.image, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .clipShape(.circle)
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white, .gray)
            }
        }
        .frame(width: 180, height: 180)
        .background { Circle().fill(.white) }
        .overlay { Circle().stroke(.white, lineWidth: 12) }
    }
    var contactName: some View {
        Text(contact.name)
            .font(.system(.largeTitle, design: .rounded, weight: .semibold))
    }
    var contactAge: some View {
        Group {
            if let ca = (contact.age) {
                Text("\(ca) going on \(ca + 1)")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .italic()
                    .foregroundStyle(.secondary)
            }
        }
    }
    var contactBirth: some View {
        Group {
            if (contact.year != nil) {
                Text((contact.birthdate ?? Date()).formatted(.dateTime.day().month(.wide).year()))
            }
            
            if (contact.year == nil) {
                Text((contact.birthdate ?? Date()).formatted(.dateTime.day().month(.wide)))
            }
        }
        .font(.system(.headline, design: .rounded, weight: .semibold))
        .foregroundStyle(.white)
        .padding()
        .background {
            Capsule()
                .fill(.pink.gradient)
        }
    }
    
    var smallButtons: some View {
        HStack(spacing: 0) {
            if !contact.phones.isEmpty {
                
                SmallMenu(
                    text: "Call",
                    systemName: "phone.fill",
                    bg: Color.green.gradient
                ) {
                    ContactActions(prefix: "tel://", choices: contact.phones, symbolName: "phone.fill", color: .green)
                }
                
                Spacer()
                
                SmallMenu(
                    text: "Text",
                    systemName: "message.fill",
                    bg: Color.mint.gradient
                ) {
                    ContactActions(prefix: "sms:", choices: contact.phones, symbolName: "message.fill", color: .mint)
                }
                
                Spacer()
            }
            
            if !contact.emails.isEmpty {
                SmallMenu(
                    text: "Email",
                    systemName: "paperplane.fill",
                    bg: Color.blue.gradient
                ) {
                    ContactActions(prefix: "mailto:", choices: contact.emails, symbolName: "paperplane.fill", color: .blue)
                }
            }
        }
        .padding()
    }
    
    var notifs: some View {
        #warning("TODO: rewrite notif manager; ui for managing")
        Text("notifs")
            .padding()
    }
    
    var largeButtons: some View {
        VStack(spacing: 12) {
            if (contact.emails.isEmpty && contact.phones.isEmpty) {
                WideButton(
                    text: "Notify",
                    systemName: "bell.fill",
                    bg: Color.yellow.gradient
                ) {
                    
                }
            }
            
            WideButton(
                text: contact.hidden ? "Show" : "Hide",
                systemName: contact.hidden ? "eye.fill" : "eye.slash.fill",
                bg: contact.hidden ? Color.secondary.gradient : Color.orange.gradient
            ) {
                contact.hidden.toggle()
            }
            
            WideButton(
                text: "Delete from Next Candles",
                systemName: "trash.fill",
                bg: Color.pink.gradient
            ) { showDeleteConfirmation.toggle() }
            .confirmationDialog(
                "Are you should you would like to delete this contact?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible,
                actions: { Button(role: .destructive) {
                    router.popToHome()
                    modelContext.delete(contact)
                } },
                message: { Text("Deleting from Next Candles does not delete this person from the Contacts app.") }
            )
        }
        .padding()
    }
    
    var body: some View {
        NavigationView {
            ColorWrappedContentView(headerHeight: 200, headerOffsetLimit: 200) {
                VStack {
                    profileImage
                    
                    contactName.padding(.top, 12)
                    
                    contactAge
                    
                    contactBirth
                    
                    Divider().padding(.top, 12)
                    
                    if !(contact.emails.isEmpty && contact.phones.isEmpty) {
                        smallButtons
                        Divider()
                    }
                    
                    notifs
                    
                    Divider()

                    largeButtons
                }
                .offset(y: -120)
            }
            .toolbar { ContactDetailToolbar() }
        }
    }
}

#Preview {
    ContentView()
        .applyEnvironment()
}
