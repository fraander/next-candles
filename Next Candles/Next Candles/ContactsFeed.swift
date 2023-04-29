//
//  ContactsFeed.swift
//  Next Candles
//
//  Created by Frank Anderson on 4/29/23.
//

import SwiftUI

extension Color {
    static let bgGradient = LinearGradient(colors: [
        Color.blue,
        Color.cyan
    ], startPoint: .top, endPoint: .bottom)
}

struct C_Birthday: Identifiable {
    var id = UUID()
    var name: String
    var date: Date
}

struct MonthCard: View {
    
    let birthdays: [C_Birthday]
    let month: String
    
    var body: some View {
        VStack(spacing: 0) {
            MonthCardHeading(month: "February", count: birthdays.count)
            ForEach(birthdays) { bd in
                ContactCard(name: bd.name, date: bd.date, last: false)
            }
            .padding(.leading, 16)
        }
    }
}

struct MonthCardHeading: View {
    
    let month: String
    let count: Int
    
    var body: some View {
        HStack {
            Text(month)
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            Text("\(count) birthday\(count != 1 ? "s" : "")")
                .foregroundColor(.white.opacity(0.8))
                .italic()
                .font(.system(.callout, design: .monospaced, weight: .medium))
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.bgGradient)
        }
    }
}

struct ContactCard: View {
    
    let name: String
    let date: Date
    let last: Bool
    
    var passed: Bool {
        return Date() >= date
    }
    
    var body: some View {
        HStack {
                Text("\(7)")
                .font(.system(.title3, design: .monospaced, weight: .heavy))
                .foregroundColor(.white)
                .padding(12)
                .background {
                    Circle()
                        .fill(Color.bgGradient)
                }
            VStack(alignment: .leading) {
                Text("Frank Anderson")
                    .font(.system(.title2, design: .rounded, weight: .semibold))
                Text("24 days away")
                    .italic()
            }
            
            Spacer()
        }
        .padding(.vertical, 10)
        .background {
            if (last) {
                GeometryReader { geo in
                    HStack(alignment: .top) {
                        Rectangle()
                            .fill(Color.indigo)
                            .frame(maxWidth: 4, maxHeight: geo.size.height / 2)
                            .padding(.leading, 16)
                        Spacer()
                    }
                }
            } else if (passed) {
                HStack {
                    Rectangle()
                        .fill(Color.indigo)
                        .frame(maxWidth: 4, maxHeight: .infinity)
                        .padding(.leading, 16)
                    Spacer()
                }
            } else {
                HStack {
                    Spacer()
                }
            }
        }
    }
}

struct ContactsFeed: View {
    var body: some View {
        ScrollView {
            MonthCard(birthdays: [
                C_Birthday(name: "Frank Anderson", date: Date(timeIntervalSince1970: 0)),
                C_Birthday(name: "Frank Anderson", date: Date()),
                C_Birthday(name: "Frank Anderson", date: Date()),
                C_Birthday(name: "Frank Anderson", date: Date(timeIntervalSince1970: 1000000000)),
                C_Birthday(name: "Frank Anderson", date: Date(timeIntervalSince1970: 1000000000)),
                C_Birthday(name: "Frank Anderson", date: Date(timeIntervalSince1970: 1000000000))
            ], month: "February")
        }
        .padding(.horizontal)
    }
}

struct ContactsFeed_Previews: PreviewProvider {
    static var previews: some View {
        ContactsFeed()
    }
}
