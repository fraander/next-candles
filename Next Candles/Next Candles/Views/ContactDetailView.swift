//
//  ContactDetailView.swift
//  Next Candles
//
//  Created by Frank Anderson on 12/20/23.
//

import SwiftUI
import Contacts
import ContactsUI

struct ContactDetailView: View {
    
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    
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
                    .foregroundStyle(.primary.opacity(0.8))
                
                Spacer()
            }
            .padding(8)
            .background {
                Group {
                    colorScheme == .light ? Color.black : Color.white
                }
                .cornerRadius(20)
                .shadow(color: .pink, radius: 4, x: 0, y: 0)
            }
        }
    }
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.pink.gradient)
                .ignoresSafeArea(.all, edges: .top)
                .frame(height: 180)
            
            Group {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white, .secondary)
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
                
                Text((contact.birthdate ?? Date())
                    .formatted(
                        .dateTime
                            .day()
                            .month(
                                .wide
                            )
                    )
                )
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
                
                
                Divider()
                    .padding(.top, 12)
                
                HStack(spacing: 0) {
                    
                    if (contact.contactAppIdentifier != nil) {
                        customButton(systemName: "phone.fill", text: "Call", bg: Color.green.gradient) {
                            
                        }
                        Spacer()
                        customButton(systemName: "message.fill", text: "Text", bg: Color.mint.gradient) {
                            
                        }
                        Spacer()
                    }
                    
                    customButton(systemName: "bell.fill", text: contact.hasNotifs ? "Silence" : "Notify", bg: contact.hasNotifs ? Color.secondary.gradient : Color.yellow.gradient) {
                        if (contact.hasNotifs) {
                            if let n = contact.notif {
                                NotificationsHelper.removeNotifs(notifIds: [n])
                                contact.notif = nil
                            }
                        } else {
                            Task {
                                try await contact.setNotifs(dayRange: 0)
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
                    
                    // TODO: Finish "edit in contacts" feature
                    if let _ = contact.contactAppIdentifier {
                        customWideButton(systemName: "person.text.rectangle.fill", text: "Edit in Contacts", bg: Color.secondary.gradient) {
//                            CNContactViewController(for: c)
                        }
                    }
                    
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
    }
}

#Preview {
    ContactDetailView(contact: Contact())
}
