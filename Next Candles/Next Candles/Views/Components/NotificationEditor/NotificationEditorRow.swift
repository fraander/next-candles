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
    
    var body: some View {
        Group {
            if let nextDate = request.nextFireDate {
                
                let daysBetween = Calendar.current.dateComponents([.day], from: nextDate, to: contact.getNextBirthday() ?? Date()).day ?? 0
                
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
            }
        }
    }
}
