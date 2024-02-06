//
//  ContactView.swift
//  Next Candles
//
//  Created by Frank Anderson on 11/25/23.
//

import SwiftUI
import SwiftData


struct ContactView: View {
    
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var alertRouter: AlertRouter
    var contact: Contact
    
    @State var setNotifSheet = false
    @State var notifsForContact = 0
    
    var hideButton: some View {
        Button("Hide Birthday", systemImage: "eye.slash") { hide(contact)}
            .tint(.orange)
    }
    var deleteButton: some View {
        Button("Delete Birthday", systemImage: "trash", role: .destructive) { modelContext.delete(contact) }
            .tint(.red)
    }
    
    var body: some View {
        HStack {
            Text(contact.name)
                .foregroundColor((contact.withinNextXDays(x: settings.dayRange)) ? .pink : .primary.opacity(0.8))
            #if os(macOS)
                .font(.system(.body, design: .rounded))
            #else
                .font(.system(.headline, design: .rounded))
            #endif
                .lineLimit(2)
                .truncationMode(.tail)
            Spacer()
            HStack {
                
                Text(
                    (contact.birthdate ?? Date())
                        .formatted(
                            .dateTime
                                .day()
                                .month(.abbreviated)
                        )
                )
                .multilineTextAlignment(.leading)
                .font(.system(.subheadline, design: .rounded, weight: .regular))
                .foregroundColor(.secondary)
                
                if (notifsForContact > 0) {
                    Image(systemName: "bell.fill")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.trailing, 4)
        }
        #if os(macOS)
        .padding(.vertical, 8)
        #endif
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            hideButton
            
            deleteButton
        }
        .onAppear {
            Task {
                notifsForContact = await notifsForContact()                
            }
        }
        .onChange(of: setNotifSheet) {
            Task {
                notifsForContact = await notifsForContact()
            }
        }
        .contextMenu {
            Button("Copy Contact Link", systemImage: "barcode.viewfinder") {
                
                var components = URLComponents()
                components.scheme = "nextcandles"
                components.host = "action"
                components.queryItems = [
                    URLQueryItem(name: "id", value: contact.identifier),
                    URLQueryItem(name: "day", value: "0"),
                    URLQueryItem(name: "month", value: "0")
                ]
                
                if let url = components.url?.absoluteString {
                    UIPasteboard.general.string = url
                } else {
                    print("Error creating URL")
                }
                
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button("Notifs", systemImage: "bell") {
                setNotifSheet.toggle()
            }
            .tint(.yellow)
            
            if notifsForContact == 0 {
                Button("Set day of", systemImage: "birthday.cake.fill") {
                    Task { 
                        await setNotification(dist: 0)
                        alertRouter.setAlert( Alert(title: Text("Set notification for the day of!")) )
                    }
                }
                .tint(.secondary)
            } else {
                Button("Remove all notifs", systemImage: "bell.slash") {
                    alertRouter.setAlert(
                        Alert(
                            title: Text("Remove all notifications for \(contact.name)?"),
                            primaryButton: .destructive(
                                Text("Remove"),
                                action: {
                                    Task {
                                        let requests = await NotificationsHelper.nc.pendingNotificationRequests()
                                        let identifiers = requests.compactMap {
                                            NotifWrapper(id: $0.identifier, url: $0.content.targetContentIdentifier ?? "")
                                        }
                                        let filtered = identifiers.filter { $0.url.contains(contact.identifier) }
                                        let mapped = filtered.map { $0.id }
                                        NotificationsHelper.removeNotifs(notifIds: mapped)
                                    }
                                }
                            ),
                            secondaryButton: .cancel()
                        )
                    )
                }
                .tint(.secondary)
            }
        }
        .sheet(isPresented: $setNotifSheet) { SetNotificationView(distance: settings.dayRange, contact: contact) }
    }
    
    func notifsForContact() async -> Int {
        let requests = await NotificationsHelper.nc.pendingNotificationRequests()
        let identifiers = requests.compactMap {
            NotifWrapper(id: $0.identifier, url: $0.content.targetContentIdentifier ?? "")
        }
        let filtered = identifiers.filter { $0.url.contains(contact.identifier) }
        return filtered.count
    }
    
    func setNotification(dist: Double) async {
        do {
            try await contact.setNotifs(distanceFromBD: Int(dist))
            notifsForContact = await notifsForContact()
        } catch {
            alertRouter.setAlert(
                Alert(
                    title: Text("Failed to set notification"),
                    dismissButton: .default(Text("Okay"))
                )
            )
        }
    }
    
    func hide(_ contact: Contact) {
        contact.hidden.toggle()
    }
}
