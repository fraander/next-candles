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
                        // toggle only favorites
                        settings.favoritesOnly.toggle()
                    } label: {
                        Image(systemName: settings.favoritesOnly ? "star.fill" : "star")
                            .foregroundColor(Color.white)
                            .font(.system(.title, design: .monospaced, weight: .bold))
                            .padding(6)
                            .background {
                                Circle()
                                    .fill(Color.yellow.shadow(.drop(radius: 4)))
                            }
                        
                    }
                    .buttonStyle(.plain)
                    
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
                Text("Settings View")
                    .presentationDetents([.medium, .large])
            }
        }
        
    }
}

//struct YearView_Previews: PreviewProvider {
//    static var previews: some View {
//        YearView(months: [
//            [
//                BirthdayObject(name: "Johnny Appleseed", date: Date()),
//                BirthdayObject(name: "Sammy Peachtree", date: Date()),
//                BirthdayObject(name: "Elizabeth Grapevine", date: Date())
//            ],
//            [
//                BirthdayObject(name: "Johnny Appleseed", date: Date()),
//                BirthdayObject(name: "Sammy Peachtree", date: Date()),
//                BirthdayObject(name: "Elizabeth Grapevine", date: Date())
//            ],
//            [
//                BirthdayObject(name: "Johnny Appleseed", date: Date()),
//                BirthdayObject(name: "Sammy Peachtree", date: Date()),
//                BirthdayObject(name: "Elizabeth Grapevine", date: Date())
//            ]
//        ])
//    }
//}
