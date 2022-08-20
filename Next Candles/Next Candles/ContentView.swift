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
    @EnvironmentObject var contacts: ContactsVM

    var body: some View {
        YearView(months: contacts.months)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
