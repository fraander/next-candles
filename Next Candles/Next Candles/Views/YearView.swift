//
//  YearView.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/28/22.
//

import SwiftUI

struct YearView: View {
    @EnvironmentObject var settings: SettingsVM
    @State var showSettings = false
    @State var months: [MonthWrapper]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    
                    List() {
                        ForEach($months) { $month in
                            MonthView(birthdays: $month)
                        }
                    }
                    .listStyle(.inset)
                }
                
                HStack(spacing: 20) {
                    
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gear")
                            .foregroundColor(Color.white)
                            .font(.system(.title, design: .monospaced, weight: .bold))
                            .padding(6)
                            .background {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                    Circle()
                                        .fill(Color.secondary.shadow(.drop(radius: 4)))
                                }
                            }
                        
                    }
                    .buttonStyle(.plain)
                }
                .padding()
            }
            .sheet(isPresented: $showSettings) {
                SettingsSheet()
                    .presentationDetents([.medium, .large])
            }
        }
        
    }
}
