//
//  PhoneSheet.swift
//  Next Candles
//
//  Created by Frank Anderson on 2/19/24.
//

import SwiftUI

enum ContactSheetType: Identifiable {
    var id: Self {
        return self
    }
    
    case call, text
}

struct PhoneSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    @Environment(\.horizontalSizeClass) var sizeClass
    var contact: Contact
    var sheetType: ContactSheetType
    
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
                    .tint(sheetType == .call ? .green : .mint)
            }
            .overlay {
                Text(sheetType == .call ? "Call" : "Text")
                    .font(.system(.title, design: .rounded, weight: .bold))
            }
            .padding([.top, .horizontal])
            .padding(.bottom, 5)
            
            if (contact.phones.isEmpty) {
                ContentUnavailableView("No phone numbers found.", systemImage: sheetType == .call ? "phone.fill" : "message.badge.filled.fill")
            } else {
                List(contact.phones, id: \.self) { phone in
                    Button(phone, systemImage: sheetType == .call ? "phone.fill" : "message.fill") {
                        if let url = URL(string: (sheetType == .call ? "tel://" : "sms:") + phone) {
                            openURL.callAsFunction(url)
                        }
                    }
                    .foregroundStyle(sheetType == .call ? .green : .mint)
                }
            }
        }
    }
}
