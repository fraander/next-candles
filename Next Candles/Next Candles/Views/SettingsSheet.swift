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
                
                let nextUpDaysString = Binding<String> {
                    String(format: "%.0f", settings.nextUpDays)
                } set: { newValue in
                    let prep = newValue.replacingOccurrences(of: " ", with: "")
                    if let nv = Double(prep) {
                        settings.nextUpDays = nv
                    }
                    return
                }

                
                GroupBox {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("Next-up Days:")
                                .font(.headline)
                            Spacer()
                            #if os(iOS)
                            CustomStepper(value: $settings.nextUpDays, lower: 0, upper: 365, increment: 1.0, tintColor: Color.indigo)
                            #elseif os(macOS)
                            TextField("Next up days", text: nextUpDaysString)
                                .labelsHidden()
                                .font(.system(.body, design: .monospaced, weight: .regular))
                                .frame(minWidth: 35, maxWidth: 35)
                            Stepper(String(format: "%.0f", settings.nextUpDays), value: $settings.nextUpDays, in: 0...365, step: 1.0)
                                .tint(.indigo)
                                .labelsHidden()
                                .font(.system(.body, design: .monospaced, weight: .regular))
                            #endif
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
