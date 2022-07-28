//
//  ContentView.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/28/22.
//

import SwiftUI

class SettingsVM: ObservableObject {
    @Published var favoritesOnly: Bool = false
}

struct ContentView: View {
    @StateObject var settings = SettingsVM()

    var body: some View {
        // TODO: create an actual model that pulls from Calendar
        // TODO: better org of model to display and hide parts of hierarchy
        YearView(months: [
            [
                BirthdayObject(name: "Johnny Appleseed", date: Date()),
                BirthdayObject(name: "Sammy Peachtree", date: Date()),
                BirthdayObject(name: "Elizabeth Grapevine", date: Date())
            ],
            [
                BirthdayObject(name: "Johnny Appleseed", date: Date()),
                BirthdayObject(name: "Sammy Peachtree", date: Date()),
                BirthdayObject(name: "Elizabeth Grapevine", date: Date())
            ],
            [
                BirthdayObject(name: "Johnny Appleseed", date: Date()),
                BirthdayObject(name: "Sammy Peachtree", date: Date()),
                BirthdayObject(name: "Elizabeth Grapevine", date: Date())
            ]
        ])
        .environmentObject(settings)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
