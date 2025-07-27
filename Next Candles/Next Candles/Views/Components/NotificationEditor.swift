//
//  NotificationEditor.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/8/25.
//

import SwiftUI

struct NotificationEditor: View {
    
    @Environment(NotificationManager.self) var notifs
    var contact: Contact
    
    @State var newTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
    @State var newDaysBefore: Int = 0
    
    var notificationsForContact: [UNNotificationRequest] {
        notifs
            .pendingRequests
            .filter { unr in
                let idComponents = unr.identifier.split(separator: "%%%")
                
                print("idc:", idComponents)
                
                let prefix = idComponents[0 ..< idComponents.endIndex - 1].joined(separator: "")
                
                print("prefix:", prefix)
                
                return prefix == contact.identifier
            }
            .sorted { $0.nextFireDate ?? Date() < $1.nextFireDate ?? Date() }
    }
    
    var body: some View {
        VStack {
            HStack {
                DatePicker("Time", selection: $newTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()

                
                Picker("Days before", selection: $newDaysBefore) {
                    ForEach(0..<366) { day in
                        Text("^[\(day) day](inflect: true) before")
                            .tag(day)
                    }
                }
                .labelsHidden()
                .tint(.primary)
                .background(Color(uiColor: UIColor.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 8.0))
                
                Spacer()
                
                Button("Set", systemImage: "bell.fill") {
                    if let d = contact.getNextBirthday() {
                        Task {
                            try await notifs.createYearlyNotification(
                                for: d,
                                contact: contact,
                                title: "Testing",
                                body: "test test test"
                            )
                            
                        }
                    }
                }
                .bold()
                .buttonStyle(.bordered)
                .tint(.accentColor)
            }
            .padding()
            .background(.white, in: .rect(cornerRadius: 16))
            .padding([.top, .horizontal])
            
            VStack(alignment: .leading) {
                
                if notificationsForContact.isEmpty {
                    ContentUnavailableView("No notifications have been set for this contact.", systemImage: "bell.slash")
                } else {
                    ForEach(notificationsForContact, id: \.identifier) { request in
                        if let nextDate = request.nextFireDate {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(nextDate, style: .date)
                                    
                                    Text(nextDate, style: .time)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                // Swipe-to-delete action for removing notifications
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    Task {
                                        await notifs.removePendingNotificationRequests(
                                            withIdentifiers: [request.identifier]
                                        )
                                    }
                                }
                                .labelStyle(.iconOnly)
                                .buttonStyle(.bordered)
                                .tint(.secondary)
                            }
                        }
                        
                        if (request != notificationsForContact.last) {
                            Divider()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding()
            .background(.white, in: .rect(cornerRadius: 16))
            .padding([.bottom, .horizontal])
        }
    }
}

#Preview {
    ContactDetailView(contact: Contact.examples.randomElement()!)
        .applyEnvironment(prePopulate: true)
}
