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
    @EnvironmentObject var notifsHelper: NotificationsHelper
    @EnvironmentObject var settings: Settings
    @State var distance: Double = 4
    
    init(settings: Settings, contact: Contact) {
        self.contact = contact
        _distance = State(initialValue: Double(settings.dayRange))
        _time = State(initialValue: settings.defaultTime)
    }
    
    @State var notifs: [NotifWrapper] = []
    
    @State var time: Date// = Calendar.current.nextDate(after: Date(), matching: DateComponents(hour: 0, minute: 0), matchingPolicy: .nextTime) ?? Date()
    
    var body: some View {
        
        VStack {
            HStack {
                if (!notifs.contains { nw in
                    if let nd = notifsHelper.notifDate(from: nw.url), let dist = notifsHelper.difference(notifDate: nd, birthMonth: contact.month, birthDay: contact.day) {
                        return dist == 0
                    } else { return false }
                }) {
                    Button("Notify day of", systemImage: "birthday.cake.fill") {
                        let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
                        if let hour = comps.hour, let minute = comps.minute {
                            Task { await setNotification(dist: 0, hour: hour, minute: minute) }
                        } else {
                            alertRouter.setAlert(Alert(title: Text("Error setting notification at the given time.")))
                        }
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
                        Spacer()
                    }
                }
                
                DatePicker(
                    "Time of notification:",
                    selection: $time,
                    in: Date()...,
                    displayedComponents: .hourAndMinute
                )
                .onChange(of: time) { old, new in
                    settings.defaultTime = new
                }
                .tint(.pink)
                .padding(.bottom, 6)
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
                    let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
                    if let hour = comps.hour, let minute = comps.minute {
                        Task { await setNotification(dist: distance, hour: hour, minute: minute) }
                    } else {
                        alertRouter.setAlert(Alert(title: Text("Error setting notification at the given time.")))
                    }
                    
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
                            if let notifDate = notifsHelper.notifDate(from: notif.url) {
                                if let dist = notifsHelper.difference(notifDate: notifDate, birthMonth: contact.month, birthDay: contact.day) {
                                    Group {
                                        Text(dist == 0 ? "On the day" : "^[\(dist) day](inflect: true) before")
                                        + Text(", \(notifDate.formatted(date: .omitted, time: Date.FormatStyle.TimeStyle.shortened))")
                                    }
                                    Spacer()
                                } else {
                                    Text("INVALID DATE COMPARISON")
                                        .foregroundStyle(.pink)
                                        .font(.system(.body, design: .rounded, weight: .bold))
                                    Spacer()
                                }
                                
                                Group {
                                    Text("Next: ")
                                    + Text(notifDate.formatted(
                                        .dateTime
                                            .day()
                                            .month(.wide)
                                            .year()))
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            } else {
                                Text("INVALID NOTIFICATION DATE")
                                    .foregroundStyle(.pink)
                                    .font(.system(.body, design: .rounded, weight: .bold))
                                Spacer()
                            }
                            
                            Button("Remove", systemImage: "bell.slash") {
                                notifsHelper.removeNotifs(notifIds: [notif.id])
                                Task { notifs = await notifsHelper.notifsFor(contact: contact) }
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
                            notifsHelper.removeNotifs(notifIds: [notifs[offset].id])
                        }
                        Task { notifs = await notifsHelper.notifsFor(contact: contact) }
                    }
                }
            }
        }
        .task {
            notifs = await notifsHelper.notifsFor(contact: contact) }
    }
    
    
    func setNotification(dist: Double, hour: Int, minute: Int) async {
        do {
            try await notifsHelper.setNotifFor(contact: contact, distanceFromBD: Int(dist), hour: hour, minute: minute)
            notifs = await notifsHelper.notifsFor(contact: contact)
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
            notifsHelper.removeNotifs(notifIds: notifs.compactMap { nw in
                nw.id
            })
        }
        
        // refresh
        Task {
            notifs = await notifsHelper.notifsFor(contact: contact)
        }
    }
}

#Preview {
    
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, configurations: config)
    
    return SetNotificationView(settings: Settings(), contact: Contact())
        .modelContainer(container)
}
