//
//  NotificationEditorRow.swift
//  Next Candles
//
//  Created by frank on 8/2/25.
//


import SwiftUI

struct NotificationEditorRow: View {
    
    var contact: Contact
    var request: UNNotificationRequest
    var onDelete: () -> Void
    
    @State var showDeleteConfirmation: Bool = false
    
    private func nextBirthday(after date: Date) -> Date? {
        guard let month = contact.month, let day = contact.day else { return nil }
        let cal = Calendar.current
        var comps = cal.dateComponents([.year], from: date)
        comps.month = month
        comps.day = day
        if let thisYear = cal.date(from: comps), thisYear > date {
            return thisYear
        } else {
            comps.year = (comps.year ?? 0) + 1
            return cal.date(from: comps)
        }
    }
    
    var body: some View {
        Group {
            if let nextDate = request.nextFireDate {
                
                let cal = Calendar.current
                let nextBirthdayDate = nextBirthday(after: nextDate)
                let isBirthday = {
                    guard let month = contact.month, let day = contact.day else { return false }
                    let comps = cal.dateComponents([.month, .day], from: nextDate)
                    return comps.month == month && comps.day == day
                }()
                let daysBetween: Int = {
                    guard let nextBirthdayDate else { return 0 }
                    let startOfNotif = cal.startOfDay(for: nextDate)
                    let startOfBirthday = cal.startOfDay(for: nextBirthdayDate)
                    let components = cal.dateComponents([.day], from: startOfNotif, to: startOfBirthday)
                    return isBirthday ? 0 : (components.day ?? 0)
                }()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(daysBetween == 0 ? "On the day" : "\(daysBetween) days before")
                        
                        Text(nextDate, format: .dateTime.day().month().year().hour().minute())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        showDeleteConfirmation.toggle()
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.bordered)
                    .tint(.secondary)
                    .confirmationDialog(
                        "Are you sure you'd like to delete this notification?",
                        isPresented: $showDeleteConfirmation,
                        titleVisibility: .visible
                    ) { Button(role: .destructive, action: onDelete) }
                }
//                .contextMenu {
//                    Button("Copy Link", systemImage: "document.on.document") {
//                        print(request.identifier)
//                    }
//                }
            }
        }
    }
}
