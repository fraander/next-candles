//
//  EmailSheet.swift
//  Next Candles
//
//  Created by Frank Anderson on 2/19/24.
//

import SwiftUI

struct EmailSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    @Environment(\.horizontalSizeClass) var sizeClass
    var contact: Contact
    
    var body: some View {
        VStack {
            
            HStack {
                Spacer()
                Button("Done", systemImage: "checkmark") { dismiss() }
#if os(macOS)
                    .buttonStyle(.borderless)
#elseif os(iOS)
                    .buttonStyle(.bordered)
#endif
                    .buttonBorderShape(.capsule)
                    .tint(.blue)
            }
            .overlay {
                Text("Email")
                    .font(.system(.title, design: .rounded, weight: .bold))
            }
            .padding([.top, .horizontal])
            .padding(.bottom, 5)
            
            if (contact.emails.isEmpty) {
                ContentUnavailableView("No email addresses found.", systemImage: "paperplane.fill")
            } else {
                List(contact.emails, id: \.self) { email in
                    Button(email, systemImage: "paperplane.fill") {
                        if let url = URL(string: ("mailto:") + email) {
                            openURL.callAsFunction(url)
                        }
                    }
                    .foregroundStyle(.blue)
                }
            }
        }
    }
}
