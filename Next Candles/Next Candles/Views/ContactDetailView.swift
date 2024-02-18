//
//  ContactDetailView.swift
//  Next Candles
//
//  Created by Frank Anderson on 12/20/23.
//

// TODO: Refactor

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
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    @Environment(\.horizontalSizeClass) var sizeClass
    var contact: Contact
    var sheetType: ContactSheetType
    
    var body: some View {
        VStack {
            if (contact.phones.isEmpty) {
                ContentUnavailableView("No phone numbers found.", systemImage: sheetType == .call ? "phone.bubble.fill" : "message.badge.filled.fill")
            } else {
                Group {
                    HStack {
                        Spacer()
                        Button("Done", systemImage: "checkmark") { dismiss() }
#if os(macOS)
                            .buttonStyle(.borderless)
#elseif os(iOS)
                            .buttonStyle(.bordered)
#endif
                            .buttonBorderShape(.capsule)
                            .tint(sheetType == .call ? .green : .mint)
                    }
                    .overlay { 
                        Text(sheetType == .call ? "Call" : "Text")
                            .font(.system(.title, design: .rounded, weight: .bold))
                    }
                    .padding([.top, .horizontal])
                    .padding(.bottom, 5)
                    
                    List(contact.phones, id: \.self) { phone in
                        Button(phone, systemImage: sheetType == .call ? "phone" : "message") {
                            if let url = URL(string: (sheetType == .call ? "tel://" : "sms:") + phone) {
                                openURL.callAsFunction(url)
                            }
                        }
                        .foregroundStyle(sheetType == .call ? .green : .mint)
#if os(macOS)
                            .buttonStyle(.borderless)
#elseif os(iOS)
                            .buttonStyle(.bordered)
#endif
                    }
                }
            }
        }
    }
}

struct ContactDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var settings: Settings

    @State var setNotifSheet = false

    @State var showCallSheet = false
    @State var showTextSheet = false
    
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
        #if os(macOS)
        .buttonStyle(.plain)
        #endif
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
        ScrollView {
            VStack(spacing: 8) {
                Rectangle()
                    .fill(Color.pink.gradient)
                    .ignoresSafeArea(.all, edges: .top)
                    .frame(height: 240)
                
                Group {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.white, .gray)
                        .frame(width: 180, height: 180)
                        .background { Circle().fill(.white) }
                        .overlay { Circle().stroke(.white, lineWidth: 12) }
                    
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
                            Text((contact.birthdate ?? Date()).formatted(.dateTime.day().month(.wide).year()))
                        }
                        
                        if (contact.year == nil) {
                            Text((contact.birthdate ?? Date()).formatted(.dateTime.day().month(.wide)))
                        }
                    }
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding()
                    .background { Capsule().fill(.pink.gradient) }
                    
                    Divider()
                        .padding(.top, 12)
                    
#if os(macOS)
                    HStack {
                        customButton(systemName: "phone.fill", text: "Call", bg: Color.green.gradient) {
                            showCallSheet.toggle()
                        }
                        customButton(systemName: "message.fill", text: "Text", bg: Color.mint.gradient) {
                            showTextSheet.toggle()
                        }
                        customButton(systemName: "bell.fill", text: "Notifs", bg: Color.yellow.gradient) {
                            setNotifSheet.toggle()
                        }
                        customButton(systemName: contact.hidden ? "eye.fill" : "eye.slash.fill", text: contact.hidden ? "Show" : "Hide", bg: contact.hidden ? Color.secondary.gradient : Color.orange.gradient ) {
                            contact.hidden.toggle()
                            dismiss()
                        }
                        
                        customButton(systemName: "trash.fill", text: "Delete", bg: Color.pink.gradient) {
                            modelContext.delete(contact)
                        }
                    }
                    .padding()
#else
                    if sizeClass == .compact {
                        HStack(spacing: 0) {
                            customButton(systemName: "phone.fill", text: "Call", bg: Color.green.gradient) {
                                showCallSheet.toggle()
                            }
                            Spacer()
                            customButton(systemName: "message.fill", text: "Text", bg: Color.mint.gradient) {
                                showTextSheet.toggle()
                            }
                            Spacer()
                            customButton(systemName: "bell.fill", text: "Notifs", bg: Color.yellow.gradient) {
                                setNotifSheet.toggle()
                            }
                            Spacer()
                            customButton(systemName: contact.hidden ? "eye.fill" : "eye.slash.fill", text: contact.hidden ? "Show" : "Hide", bg: contact.hidden ? Color.secondary.gradient : Color.orange.gradient ) {
                                contact.hidden.toggle()
                                dismiss()
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
                    } else {
                        VStack {
                            customWideButton(systemName: "phone.fill", text: "Call", bg: Color.green.gradient) {
                                showCallSheet.toggle()
                            }
                            customWideButton(systemName: "message.fill", text: "Text", bg: Color.mint.gradient) {
                                showTextSheet.toggle()
                            }
                            customWideButton(systemName: "bell.fill", text: "Notifs", bg: Color.yellow.gradient) {
                                setNotifSheet.toggle()
                            }
                            customWideButton(systemName: contact.hidden ? "eye.fill" : "eye.slash.fill", text: contact.hidden ? "Show" : "Hide", bg: contact.hidden ? Color.secondary.gradient : Color.orange.gradient ) {
                                contact.hidden.toggle()
                                dismiss()
                            }
                            
                            customWideButton(systemName: "trash.fill", text: "Delete from Next Candles", bg: Color.pink.gradient) {
                                modelContext.delete(contact)
                            }
                        }
                        .padding()
                    }
#endif
                }
                .offset(y: -120)
                Spacer()
            }
        }
        .ignoresSafeArea(.all)
        .background {
            Rectangle()
                .fill(colorScheme == .light ? Color.white.gradient : Color.black.gradient)
                .ignoresSafeArea(.all, edges: .bottom)
        }
        .sheet(isPresented: $showCallSheet) {
            PhoneSheet(contact: contact, sheetType: .call)
                .frame(minWidth: 300, minHeight: 300)
                .presentationDetents(
                    [.height(180)]
                )
        }
        .sheet(isPresented: $showTextSheet) {
            PhoneSheet(contact: contact, sheetType: .text)
                .frame(minWidth: 300, minHeight: 300)
                .presentationDetents(
                    [.height(180)]
                )
        }
        .sheet(isPresented: $setNotifSheet) { SetNotificationView(distance: settings.dayRange, contact: contact) }
    }
}

#Preview {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, configurations: config)
    
    let contact = Contact(givenName: "Frank", familyName: "Anderson", month: 2, day: 7, year: 2003)
    return ContactDetailView(contact: contact)
        .modelContainer(container)
}
