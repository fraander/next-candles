//
//  ContactActions.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/4/25.
//

import SwiftUI

struct ContactActions: View {
    
    @Environment(\.openURL) var openURL
    
    var prefix: String
    var choices: [String]
    var symbolName: String
    var color: Color
    
    var body: some View {
        Group {
            ForEach(choices, id: \.self) { choice in
                Button(choice, systemImage: symbolName) {
                    if let encodedChoice = choice.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                       let url = URL(string: prefix + encodedChoice) {
                        openURL.callAsFunction(url)
                    }
                }
                .foregroundStyle(color)
            }
        }
    }
}
