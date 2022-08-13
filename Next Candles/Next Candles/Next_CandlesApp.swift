//
//  Next_CandlesApp.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/28/22.
//

import SwiftUI

@main
struct Next_CandlesApp: App {
    
    @StateObject var settings = SettingsVM()
    @StateObject var contacts = ContactsVM()
    
    var body: some Scene {
        WindowGroup {
//            ContentView()
            List {
                ForEach(contacts.contacts) { c in
                    HStack {
                        Text(c.name)
                        
                        Spacer()
                        
                        Text(c.formattedBirthday)
                    }
                }
            }
            .task {
                contacts.fetch()
            }
            .environmentObject(settings)
            .environmentObject(contacts)
            
        }
    }
}
