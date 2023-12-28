//
//  SetNotificationView.swift
//  Next Candles
//
//  Created by Frank Anderson on 12/27/23.
//

import SwiftUI
import SwiftData

struct SetNotificationView: View {
    
    var contact: Contact
    @Environment(\.dismiss) var dismiss
    
    @State var daysBefore = 14.0
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            HStack {
                Button("Cancel") { dismiss() }
                    .foregroundColor(.secondary)
                Spacer()
                Button("Set", systemImage: "bell.fill", action: setNotif)
                    .tint(.pink)
            }
            .font(.system(.body, design: .rounded, weight: .bold))
            .padding([.horizontal, .bottom])
            
            Text("Set Notification")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
        }
        .padding(.top)
        
        Divider()
        
        ScrollView(.vertical) {
            VStack {
                LabeledContent {
                    CustomStepper(
                        value: $daysBefore,
                        lower: 0,
                        upper: 366,
                        increment: 1.0,
                        tintColor: .pink
                    )
                } label: {
                    Text("Notify me ^[\(daysBefore, specifier: "%.0f") day](inflect: true) before")
                }
            }
            .padding()
        }
        
    }
    
    func setNotif() {
        Task {
            try await contact.setNotifs(distanceFromBD: Int(daysBefore))
            dismiss()
        }
    }
}

#Preview {
    
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, configurations: config)
    
    return SetNotificationView(contact: Contact())
        .modelContainer(container)
}
