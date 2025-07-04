//
//  ContactDetailView.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/4/25.
//

import SwiftUI

/*
 List(contact.emails, id: \.self) { email in
     Button(email, systemImage: "paperplane.fill") {
         if let url = URL(string: ("mailto:") + email) {
             openURL.callAsFunction(url)
         }
     }
     .foregroundStyle(.blue)
 }
 */

struct ContactDetailView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.openURL) var openURL
    
    var contact: Contact
    
    @State var showPhoneActions = false
    
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
                SmallButton(
                    text: "Call",
                    systemName: "phone.fill",
                    bg: Color.green.gradient
                ) { showPhoneActions.toggle() }
                    .confirmationDialog(
                        "Phone Numbers",
                        isPresented: $showPhoneActions) {
                            ForEach(contact.emails, id: \.self) { email in
                                Button(email, systemImage: "paperplane.fill") {
                                    if let url = URL(string: ("mailto:") + email) {
                                        openURL.callAsFunction(url)
                                    }
                                }
                                .foregroundStyle(.blue)
                            }
                        }
                
                Spacer()
                
                SmallButton(
                    text: "Text",
                    systemName: "message.fill",
                    bg: Color.mint.gradient
                ) {
                    
                }
                
                Spacer()
            }
            
            if !contact.emails.isEmpty {
                SmallButton(
                    text: "Email",
                    systemName: "paperplane.fill",
                    bg: Color.blue.gradient
                ) {
                    
                }
                
                Spacer()
            }
            
            
            if !(contact.emails.isEmpty && contact.phones.isEmpty) {
                SmallButton(
                    text: "Notify",
                    systemName: "bell.fill",
                    bg: Color.yellow.gradient
                ) {
                    
                }
            }
        }
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
            ) { }
            
            WideButton(
                text: "Delete from Next Candles",
                systemName: "trash.fill",
                bg: Color.pink.gradient
            ) { }
        }
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
                        smallButtons.padding()
                        Divider()
                    }

                    largeButtons.padding()
                }
                .offset(y: -120)
            }
            .toolbar { ContactDetailToolbar() }
        }
        .task {
            Task {
                let (existing, diffs) = try await ContactsUtils.fetch(existingContacts: allContacts)
                if (existing.count > 0) {
                    existing.forEach { modelContext.insert($0) }
                } else if diffs.count != 0 {
                    showResolveDiffs = true
                    toResolve = diffs
                } else {
                    if showNoNewAlert {
                        alertRouter.setAlert(
                            Alert(title: Text("No new contacts to import."))
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    BackgroundView()
        .sheet(isPresented: .constant(true)) {
            ContactDetailView(contact: Contact.examples.randomElement()!)
        }
        .applyEnvironment(prePopulate: true)
}
