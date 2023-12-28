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
    
    @State var daysBefore = 14.0
    @State var notifsForContact: [(UUID, Date)] = []
    
    var body: some View {
        
        VStack {
            // TITLE
            Text("Notifications")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
            
            Divider()
            
            // NOTIFY BEFORE
            VStack {
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
                            Text("Notify me ") + Text("^[\(daysBefore, specifier: "%.0f")\u{00a0}day](inflect: true)").foregroundStyle(.pink) + Text(" before")
                        }
                        .font(.system(.body, design: .rounded, weight: .regular))
                        .padding(.vertical, 8)
                    }
                }
                
                HStack {
                    Spacer()
                    
                    Button("Add", systemImage: "arrow.right", action: {})
                        .buttonBorderShape(.capsule)
                        .buttonStyle(.bordered)
                        .tint(.mint)
                        .labelStyle(.titleAndIcon)
                        .padding(.bottom, 8)
                }
                
            }
            .padding(.horizontal)
            
            Divider()
            
            ScrollView(.vertical) {
                ForEach(notifsForContact, id: \.0.self) { i in
                    Text("\(i.1.formatted())")
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
