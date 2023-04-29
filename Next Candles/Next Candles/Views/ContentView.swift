//
//  ContentView.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/28/22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var contacts: ContactsVM
    @State var showInfoPage = false
    
    var body: some View {
        Group {
            if contacts.contacts.isEmpty {
                if showInfoPage {
                    VStack {
                        Text("🎂")
                            .font(.largeTitle)
                        Text("Error reading birthdays...")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Check you have done all of the following:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 4)
                        Text("\(Image(systemName: "checkmark")) Allowed access to contacts.\n\(Image(systemName: "checkmark")) You have contacts which have birthdays.\n\(Image(systemName: "checkmark")) Given it a few seconds to load.")
                            .multilineTextAlignment(.leading)
                    }
                    .task {
                        showInfoPage = true
                    }
                }
                
            } else {
                YearView(months: contacts.months)
            }
        }
        .transition(AnyTransition.slide)
        .task {
            async let fetched = try? contacts.fetch()
            if let fetched = await fetched {
                contacts.contacts = fetched
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ContactsVM())
    }
}
