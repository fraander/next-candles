//
//  BirthdayView.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/28/22.
//

import SwiftUI

struct BirthdayView: View {
    @Binding var birthday: BirthdayObject
    
    var body: some View {
        HStack {
            Image(systemName: birthday.favorite ? "star.fill" : "star")
                .foregroundColor(.yellow)
                .onTapGesture {
                    birthday.favorite.toggle()
                }
            
            Text(birthday.name)
                .font(.system(.body, design: .rounded, weight: .regular))
            
            Spacer()
            
            Button {
                // do nothing
            } label: {
                Text(birthday.date.formatted(.dateTime.day())
                     + " "
                     + birthday.date.formatted(.dateTime.month()))
                .font(.system(.headline, design: .monospaced, weight: .bold))
            }
            .buttonStyle(.bordered)
            .tint(Color.pink)
            .allowsHitTesting(false)
        }
        .font(.system(.headline, design: .monospaced, weight: .bold))
    }
}

struct BirthdayView_Previews: PreviewProvider {
    static var previews: some View {
        
        List {
            Text(Date().formatted(.dateTime.month(.wide)))
                .font(.system(.title, design: .rounded, weight: .bold))
            ForEach(0..<5) {_ in
                BirthdayView(birthday: .constant(BirthdayObject(name: "Johnny Appleseed", date: Date())))
            }
        }
        .listStyle(.inset)
    }
}
