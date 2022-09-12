//
//  SettingsView.swift
//  Next Candles
//
//  Created by Frank Anderson on 9/12/22.
//

import SwiftUI

struct SettingsSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: SettingsVM
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Label("Settings", systemImage: "gear")
                        .font(.system(Font.TextStyle.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(.indigo)
                    
                    Spacer()
                    
                    Button  {
                        dismiss()
                    } label: {
                        Label("Done", systemImage: "checkmark")
                            .labelStyle(.titleAndIcon)
                            .font(.system(.body, design: .monospaced, weight: .bold))
                    }
                    .buttonStyle(.bordered)
                    .tint(Color.mint)
                }
                
                GroupBox {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("Next-up Days:")
                                .font(.headline)
                            Spacer()
                            CustomStepper(value: $settings.nextUpDays, lower: 0, upper: 365, increment: 1.0, tintColor: Color.indigo)
                        }
                        
                        Text("Highlight birthdays within this many days of the current date.")
                            .font(.system(.caption, design: .monospaced, weight: .regular))
                            .foregroundColor(.secondary)
                            .padding(.top, 12)
                    }
                }
            }
            .padding()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static let settings = SettingsVM()
    static var previews: some View {
        SettingsSheet()
            .environmentObject(settings)
    }
}
