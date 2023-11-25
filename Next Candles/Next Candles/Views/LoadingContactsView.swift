//
//  LoadingContactsView.swift
//  Next Candles
//
//  Created by Frank Anderson on 11/25/23.
//

import SwiftUI

struct LoadingContactsView: View {
    
    let loadingContacts: LoadingState
    
    var body: some View {
        Group {
            if (loadingContacts == .loading) {
                ProgressView()
            } else if (loadingContacts == .failed) {
                ContentUnavailableView("Could not find birthdays to import from Contacts.", systemImage: "birthday.cake")
            }
        }
    }
}

#Preview {
    LoadingContactsView(loadingContacts: .loading)
}
