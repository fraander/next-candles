//
//  SetNotificationView.swift
//  Next Candles
//
//  Created by Frank Anderson on 12/27/23.
//

import SwiftUI
import SwiftData
import NotificationCenter

struct NotifWrapper: Identifiable {
    let id: String
    let url: String
}

struct SetNotificationView: View {
    
    var contact: Contact
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var alertRouter: AlertRouter
    @State var distance: Double = 4
    
    init(distance: Int, contact: Contact) {
        self.contact = contact
        _distance = State(initialValue: Double(distance))
    }
    
    @State var notifs: [NotifWrapper] = []
    
    var body: some View {
        
        VStack {
            HStack {
                if (!notifs.contains { nw in
                    if let nd = notifDate(from: nw.url), let dist = difference(notifDate: nd, birthMonth: contact.month, birthDay: contact.day) {
                        return dist == 0
                    } else { return false }
                }) {
                    Button("Notify day of", systemImage: "birthday.cake.fill") {
                        Task { await setNotification(dist: 0) }
                    }
                    .tint(.yellow)
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.bordered)
                }
                
                Spacer()
                
                Button("Done", systemImage: "checkmark") { dismiss() }
                    .tint(.mint)
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.bordered)
            }
            .padding([.horizontal, .top])
            Text(contact.name)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .padding(.top)
            if let cbd = contact.birthdate {
                Text(cbd.formatted(.dateTime.day().month(.wide)))
                    .font(.system(.subheadline, design: .rounded, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            
            Group {
                LabeledContent {
                    CustomStepper(
                        value: $distance,
                        lower: 0,
                        upper: 365,
                        increment: 1.0,
                        tintColor: .pink
                    )
                } label: {
                    HStack {
                        Group {
                            Text("Notify me \n")
                            + Text("^[\(distance, specifier: "%.0f")\u{00a0}day](inflect: true)")
                                .foregroundStyle(.pink)
                            + Text(" before")
                        }
                        .font(.system(.body, design: .rounded, weight: .regular))
                        .padding(.vertical, 8)
                        Spacer()
                    }
                }
               
            }
            
            .padding(.horizontal)
            .padding(.top, 10)
            
            HStack {
                
                Button("Reset", systemImage: "bell.slash", role: .destructive, action: removeAllNotifsForContact)
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.bordered)
                    .tint(.pink)
                
                Spacer()
                
                Button("Set Notification", systemImage: "bell.fill") {
                    Task { await setNotification(dist: distance) }
                }
                .buttonBorderShape(.capsule)
                .buttonStyle(.bordered)
                .tint(.mint)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            if notifs.isEmpty {
                ContentUnavailableView(
                    "No notifications set",
                    systemImage: "bell.slash",
                    description: Text("Click ")
                    + Text("\(Image(systemName: "bell.fill")) Set Notification")
                        .foregroundStyle(.mint)
                        .bold()
                    + Text(" to create a notification for this contact.")
                )
            } else {
                List {
                    ForEach(notifs) { notif in
                        HStack {
                            if let notifDate = notifDate(from: notif.url) {
                                if let dist = difference(notifDate: notifDate, birthMonth: contact.month, birthDay: contact.day) {
                                    Text(dist == 0 ? "On the day" : "^[\(dist) day](inflect: true) before")
                                    Spacer()
                                } else {
                                    Text("INVALID DATE COMPARISON")
                                        .foregroundStyle(.pink)
                                        .font(.system(.body, design: .rounded, weight: .bold))
                                    Spacer()
                                }
                                
                                Text(notifDate.formatted(
                                    .dateTime
                                        .day()
                                        .month(
                                            .wide
                                        )
                                ))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            } else {
                                Text("INVALID NOTIFICATION DATE")
                                    .foregroundStyle(.pink)
                                    .font(.system(.body, design: .rounded, weight: .bold))
                                Spacer()
                            }
                            
                            Button("Remove", systemImage: "bell.slash") {
                                NotificationsHelper.removeNotifs(notifIds: [notif.id])
                                Task { notifs = await notifsForContact() }
                            }
                            .labelStyle(.iconOnly)
                            .font(.caption)
                            .tint(.pink)
                            .buttonBorderShape(.circle)
                            .buttonStyle(.bordered)
                        }
                    }
                    .onDelete { offsets in
                        offsets.forEach { offset in
                            NotificationsHelper.removeNotifs(notifIds: [notifs[offset].id])
                        }
                        Task { notifs = await notifsForContact() }
                    }
                }
            }
        }
        .task {
            notifs = await notifsForContact()
        }
    }
    
    func sortNotifWrappers(_ notifs: [NotifWrapper]) -> [NotifWrapper] {
        return notifs.sorted {
            if let lhs = notifDate(from: $0.url),
               let rhs = notifDate(from: $1.url),
               let lhsDist = difference(notifDate: lhs, birthMonth: contact.month, birthDay: contact.day),
               let rhsDist = difference(notifDate: rhs, birthMonth: contact.month, birthDay: contact.day) {
                return lhsDist < rhsDist
            } else {
                return false
            }
        }
    }
    
    func difference(notifDate: Date, birthMonth: Int?, birthDay: Int?) -> Int? {
        
        let notifDateComponents = Calendar.current.dateComponents([.day, .month], from: notifDate)
        if (notifDateComponents.day == birthDay && notifDateComponents.month == birthMonth) {
            return 0
        }
        
        let bdc = DateComponents(month: birthMonth, day: birthDay)
        guard let nextBd = Calendar.current.nextDate(after: notifDate, matching: bdc, matchingPolicy: .nextTime),
              let dist = Calendar.current.dateComponents([.day], from: notifDate, to: nextBd).day else {
            return nil
        }
        
        if dist < 0 {
            print(nextBd.description, notifDate.description)
            return dist
        } else {
            return dist
        }
        
    }
    
    func notifDate(from urlString: String) -> Date? {
        guard let url = URL(string: urlString),
              let components = URLComponents(
                url: url,
                resolvingAgainstBaseURL: true
              ),
              let dayString = components.queryItems?.first(where: {
                  $0.name == "day"
              })?.value,
              let monthString = components.queryItems?.first(where: {
                  $0.name == "month"
              })?.value,
              let day = Int(dayString),
              let month = Int(monthString),
              let result = Calendar.current.nextDate(
                after: Date(),
                matching: DateComponents(month: month, day: day),
                matchingPolicy: .nextTime
              ) else { return nil }
        
        return result
    }
    
    func notifsForContact() async -> [NotifWrapper] {
        let requests = await NotificationsHelper.nc.pendingNotificationRequests()
        let identifiers = requests.compactMap {
            NotifWrapper(id: $0.identifier, url: $0.content.targetContentIdentifier ?? "")
        }
        let filtered = identifiers.filter { $0.url.contains(contact.identifier) }
        
        var output: [NotifWrapper] = []
        filtered.forEach { nw in
            if !(output.contains { $0.url == nw.url }) {
                output.append(nw)
            } else {
                NotificationsHelper.removeNotifs(notifIds: [nw.id])
            }
        }
        
        return sortNotifWrappers(output)
    }
    
    func setNotification(dist: Double) async {
        do {
            try await contact.setNotifs(distanceFromBD: Int(dist))
            notifs = await notifsForContact()
        } catch {
            alertRouter.setAlert(
                Alert(
                    title: Text("Failed to set notification"),
                    dismissButton: .default(Text("Okay"))
                )
            )
        }
    }
    
    func removeAllNotifsForContact() {
        // remove all notifs for this contact
        notifs.forEach { _ in
            NotificationsHelper.removeNotifs(notifIds: notifs.compactMap { nw in
                nw.id
            })
        }
        
        // refresh
        Task {
            notifs = await notifsForContact()
        }
    }
}

#Preview {
    
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, configurations: config)
    
    return SetNotificationView(distance: 15, contact: Contact())
        .modelContainer(container)
}
