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
    
    @AppStorage("newTime") var newTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
    @AppStorage("newDays") var newDaysBefore: Int = 0
    
    var notificationsForContact: [UNNotificationRequest] {
        notifs
            .pendingRequests
            .filter { unr in
                let idComponents = unr.identifier.split(separator: "%%%")
                
//                print("idc:", idComponents)
                
                let prefix = idComponents[0 ..< idComponents.endIndex - 1].joined(separator: "")
                
//                print("prefix:", prefix)
                
                return prefix == contact.identifier
            }
            .sorted { $0.nextFireDate ?? Date() > $1.nextFireDate ?? Date() }
    }
    
    var body: some View {
        VStack {
            HStack {
                DatePicker("Time", selection: $newTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .frame(height: 36)
                
                
                Picker("Days before", selection: $newDaysBefore) {
                    ForEach([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 20, 21, 25, 30, 31, 40, 50, 60, 90, 100, 120, 150, 180, 270, 365], id: \.self) { day in
                        if day == 0 {
                            Text("On the day")
                                .tag(day)
                        } else {
                            Text("^[\(day) day](inflect: true) before")
                                .tag(day)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 36)
                .labelsHidden()
                .tint(.primary)
                .background(Color(uiColor: UIColor.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 8.0))
                
//                Spacer()
                
                Button("Set", systemImage: "bell.fill") { Task { await setNotification() } }
                    .bold()
                    .buttonStyle(.bordered)
                    .tint(.accentColor)
                    .frame(height: 36)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.3), in: .rect(cornerRadius: 16))
            .padding([.top, .horizontal])
            
            VStack(alignment: .leading) {
                
                if notificationsForContact.isEmpty {
                    ContentUnavailableView("No notifications have been set for this contact.", systemImage: "bell.slash")
                } else {
                    ForEach(notificationsForContact, id: \.identifier) { request in
                        NotificationEditorRow(contact: contact, request: request) { deleteNotification(request: request) }
                        
                        if (request != notificationsForContact.last) {
                            Divider()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding()
            .background(Color.gray.opacity(0.3), in: .rect(cornerRadius: 16))
            .padding([.bottom, .horizontal])
            .id(notificationsForContact.count)
        }
    }
    
    func deleteNotification(request: UNNotificationRequest) {
        Task {
            await notifs.removePendingNotificationRequests(
                withIdentifiers: [request.identifier]
            )
        }
    }
    
    func setNotification() async {
        if let d = contact.getNextBirthday() {
            // TITLE CALCULATION
            let displayName = {
                if let nickname = contact.nickname, !nickname.isEmpty {
                    return nickname
                } else {
                    return [contact.givenName, contact.familyName]
                        .compactMap { $0 }
                        .filter { !$0.isEmpty }
                        .joined(separator: " ")
                }
            }()
            
            let possessiveName = displayName.hasSuffix("s") ?
            "\(displayName)'" :
            "\(displayName)'s"
            
            let title = newDaysBefore == 0 ?
            "\(possessiveName) birthday is today! 🥳" :
            "\(possessiveName) birthday is in \(newDaysBefore) days"
            
            // DATE CALCULATION
            let currentDate = Date()
            // Calculate the first candidate notification date for this year
            var notificationDate = Calendar.current.date(byAdding: .day, value: -newDaysBefore, to: d)!
            let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: newTime)
            var date = Calendar.current.date(bySettingHour: timeComponents.hour!, minute: timeComponents.minute!, second: 0, of: notificationDate)!

            // If that date/time is in the past, use next year's birthday
            if date < currentDate {
                let nextYearBirthday = Calendar.current.date(byAdding: .year, value: 1, to: d)!
                notificationDate = Calendar.current.date(byAdding: .day, value: -newDaysBefore, to: nextYearBirthday)!
                date = Calendar.current.date(bySettingHour: timeComponents.hour!, minute: timeComponents.minute!, second: 0, of: notificationDate)!
            }
            
            // CREATE NOTIFICATION
            try? await notifs.createYearlyNotification(
                on: date,
                contact: contact,
                title: title,
                body: newDaysBefore == 0 ? "It's time to wish them a happy birthday." : "Their birthday is coming up!"
            )
        }
    }
}

#Preview {
    ContactDetailView(contact: Contact.examples.randomElement()!)
        .applyEnvironment(prePopulate: true)
}
