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

struct ContactDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var alertRouter: AlertRouter
    @EnvironmentObject var settings: Settings
    
    @State var setNotifSheet = false
    
    @State var showCallSheet = false
    @State var showTextSheet = false
    @State var showEmailSheet = false
    
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
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.pink.gradient)
                        .ignoresSafeArea(.all, edges: .top)
                        .frame(height: 240)
                        .overlay(alignment: .topTrailing) {
                            Button("Done", systemImage: "checkmark") { dismiss() }
#if os(macOS)
                                .buttonStyle(.borderless)
#elseif os(iOS)
                                .buttonStyle(.bordered)
#endif
                                .buttonBorderShape(.capsule)
                                .tint(.white)
                                .padding()
                        }
                    
                    VStack {
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
                        .background {
                            Capsule()
                                .fill(.pink.gradient)
                        }
                        
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
                                customButton(systemName: "paperplane.fill", text: "Email", bg: Color.blue.gradient) {
                                    showEmailSheet.toggle()
                                }
                                Spacer()
                                customButton(systemName: "bell.fill", text: "Notify", bg: Color.yellow.gradient) {
                                    setNotifSheet.toggle()
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                            
                            Divider()
                            
                            VStack(spacing: 12) {
                                customWideButton(systemName: contact.hidden ? "eye.fill" : "eye.slash.fill", text: contact.hidden ? "Show" : "Hide", bg: contact.hidden ? Color.secondary.gradient : Color.orange.gradient ) {
                                    contact.hidden.toggle()
                                    dismiss()
                                }
                                
                                customWideButton(systemName: "trash.fill", text: "Delete from Next Candles", bg: Color.pink.gradient) {
                                    alertRouter.setAlert(
                                        Alert(
                                            title: Text("Delete this Contact from Next Candles?"),
                                            message: Text("Does not delete from the Contacts app"),
                                            primaryButton: .destructive(Text("Delete")),
                                            secondaryButton: .cancel()
                                        )
                                    )
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
                                customWideButton(systemName: "paperplane.fill", text: "Email", bg: Color.blue.gradient) {
                                    showEmailSheet.toggle()
                                }
                                customWideButton(systemName: "bell.fill", text: "Notify", bg: Color.yellow.gradient) {
                                    setNotifSheet.toggle()
                                }
                                customWideButton(systemName: contact.hidden ? "eye.fill" : "eye.slash.fill", text: contact.hidden ? "Show" : "Hide", bg: contact.hidden ? Color.secondary.gradient : Color.orange.gradient ) {
                                    contact.hidden.toggle()
                                    dismiss()
                                }
                                
                                customWideButton(systemName: "trash.fill", text: "Delete from Next Candles", bg: Color.pink.gradient) {
                                    alertRouter.setAlert(
                                        Alert(
                                            title: Text("Delete this Contact from Next Candles?"),
                                            message: Text("Does not delete from the Contacts app"),
                                            primaryButton: .destructive(Text("Delete")),
                                            secondaryButton: .cancel()
                                        )
                                    )
                                    modelContext.delete(contact)
                                }
                            }
                            .padding()
                        }
#endif
                    }
                    .offset(y: -112)
                    //                .background(.regularMaterial)
                    //                Spacer()
                }
            }
            .ignoresSafeArea(.all)
            .sheet(isPresented: $showEmailSheet) {
                EmailSheet(contact: contact)
                    .padding(.vertical)
                    .frame(minWidth: 300, minHeight: 300)
                    .presentationDetents([.fraction(0.999)])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showCallSheet) {
                PhoneSheet(contact: contact, sheetType: .call)
                    .padding(.vertical)
                    .frame(minWidth: 300, minHeight: 300)
                    .presentationDetents([.fraction(0.999)])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showTextSheet) {
                PhoneSheet(contact: contact, sheetType: .text)
                    .padding(.vertical)
                    .frame(minWidth: 300, minHeight: 300)
                    .presentationDetents([.fraction(0.999)])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $setNotifSheet) { SetNotificationView(settings: settings, contact: contact)
            }
        }
    }
}

#Preview {
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, configurations: config)
    
    let contact = Contact(givenName: "Frank", familyName: "Anderson", month: 2, day: 7, year: 2003)
    
    
    ZStack {
        Color.brown.ignoresSafeArea(.all)
            .sheet(isPresented: .constant(true)) {
                ContactDetailView(contact: contact)
                    .presentationBackground(.regularMaterial)
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.fraction(0.999)])
            }
        
    }
    .modelContainer(container)
}
