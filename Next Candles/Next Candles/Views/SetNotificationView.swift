//
//  SetNotificationView.swift
//  Next Candles
//
//  Created by Frank Anderson on 12/27/23.
//

import SwiftUI
import SwiftData
import NotificationCenter

struct SetNotificationView: View {
    
    var contact: Contact
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var alertRouter: AlertRouter
    
    @State var daysBefore = 14.0
    @State var notifsForContact: [(UUID, Date)] = []
    
    func sectionHeader(title: () -> String) -> some View {
        Text(title())
            .textCase(.uppercase)
            .font(.system(.caption, design: .monospaced, weight: .regular))
            .foregroundColor(.secondary)
            .padding(.top, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func distance(notifDate: Date, contact c: Contact) -> Int {
        let birthdate = Calendar.current.nextDate(after: Date(), matching: DateComponents(month: c.month, day: c.day), matchingPolicy: .nextTime) ?? Date()
        let dist = Date.daysRelative(primaryDate: notifDate, otherDate: birthdate)
        return dist < 0 ? dist + 365 : dist
    }
    
    func message(notifDate: Date, contact c: Contact) -> Text {
        let dist = distance(notifDate: notifDate, contact: c)
        
        return dist == 0 ? Text("On the day") : Text("^[\(dist)\u{00a0}days](inflect: true) before")
    }
    
    var body: some View {
        
        VStack {
            // TITLE
            HStack {
                Spacer()
                Button("Done", systemImage: "checkmark") {
                    dismiss()
                }
                .tint(.mint)
            }
            .padding([.top, .horizontal])
            
            Text("Notifications")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .padding(.top, 10)
            
            Divider()
            
            // NOTIFY BEFORE
            VStack {
                sectionHeader { "Set Notification" }
                
                HStack {
                    LabeledContent {
                        CustomStepper(
                            value: $daysBefore,
                            lower: 0,
                            upper: 366,
                            increment: 1.0,
                            tintColor: .pink
                        )
                    } label: {
                        Group {
                            Text("Notify me \n") + Text("^[\(daysBefore, specifier: "%.0f")\u{00a0}day](inflect: true)").foregroundStyle(.pink) + Text(" before")
                        }
                        .font(.system(.body, design: .rounded, weight: .regular))
                        .padding(.vertical, 8)
                    }
                }
                
                HStack {
                    Spacer()
                    
                    Button("Add Notification", systemImage: "arrow.right") {
                        Task {
                            try await contact.setNotifs(distanceFromBD: Int(daysBefore))
                            notifsForContact = await fetchNotifsForContact()
                        }
                    }
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.bordered)
                    .tint(.mint)
                    .labelStyle(.titleAndIcon)
                        .padding(.bottom, 8)
                }
                
            }
            .padding(.horizontal)
            
            Divider()
            
            sectionHeader { "Existing Notifications" }
                .padding(.horizontal)
            
            ScrollView(.vertical) {
                ForEach(notifsForContact, id: \.0.self) { i in
                    HStack {
                        HStack {
                            Circle()
                                .fill(Color.pink.opacity(0.5))
                                .overlay {
                                    Text("\(distance(notifDate: i.1, contact: contact))")
                                        .font(.system(.caption, design: .monospaced, weight: .bold))
                                }
                                .frame(width: 28, height: 28, alignment: .center)
                            message(notifDate: i.1, contact: contact)
                                .font(.system(.body, design: .rounded))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background {
                            Capsule()
                                .fill(.pink.opacity(0.2))
                        }

                        Button("Remove Notification", systemImage: "bell.slash") {
                            Task {
                                if let n = contact.notif {
                                    NotificationsHelper.removeNotifs(notifIds: [n])
                                    contact.notif = nil
                                }
                                notifsForContact = await fetchNotifsForContact()
                            }
                        }
                        .tint(.yellow)
                        .buttonStyle(.bordered)
                        .labelStyle(.iconOnly)
                        .buttonBorderShape(.circle)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .task {
            notifsForContact = await fetchNotifsForContact()
        }
    }
    
    func setNotif() {
        Task {
            try await contact.setNotifs(distanceFromBD: Int(daysBefore))
            dismiss()
            notifsForContact = await fetchNotifsForContact()
        }
    }
    
    func fetchNotifsForContact() async -> [(UUID, Date)] {
        let requests = await NotificationsHelper.nc.pendingNotificationRequests()
        //        let notifs = requests.filter { $0.content.targetContentIdentifier == contact.identifier }
        let notifs = requests.filter { $0.content.targetContentIdentifier?.replacingOccurrences(of: "nextcandles://open?contact=", with: "") == contact.identifier
        }
        
        let dates: [Date] = notifs.compactMap { unr in
            if let c = (unr.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate() {
                return c
            } 
            return nil
        }
        
        return dates.map { (UUID(), $0) }
    }
}

#Preview {
    
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, configurations: config)
    
    return SetNotificationView(contact: Contact())
        .modelContainer(container)
}
