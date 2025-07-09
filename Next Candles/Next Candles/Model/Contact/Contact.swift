//
//  Contact.swift
//  Next Candles
//
//  Created by Frank Anderson on 11/20/23.
//

import Foundation
import SwiftData
import Contacts


@Model
class Contact: ObservableObject, Equatable, Identifiable {
    var identifier: String
    var givenName: String?
    var familyName: String?
    var nickname: String?
    var month: Int?
    var day: Int?
    var year: Int?
    var hidden: Bool = false
    var contactAppIdentifier: String?
    var phones: [String] = []
    var emails: [String] = []
    
    @Attribute(.externalStorage) var image: Data?
    
    var name: String {
        let formatter = PersonNameComponentsFormatter()
        
        var components = PersonNameComponents()
        components.givenName = givenName
        components.familyName = familyName
        components.nickname = nickname
        
        return formatter.string(from: components)
    }
    
    var age: Int? {
        if (year != nil) {
            return Calendar.current.dateComponents(
                [.year],
                from: birthdate ?? Date(),
                to: Date()
            ).year
        } else {
            return nil
        }
    }
    
    var birthdate: Date? {
        var components = DateComponents()
        components.month = month
        components.day = day
        components.year = year ?? Calendar.current.component(.year, from: Date())
        
        return Calendar.current.date(from: components)
    }
    
    func withinNextXDays(x: Int) -> Bool {
        let currentDate = Date()
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentDay = Calendar.current.component(.day, from: Date())
        
        if currentMonth == month && currentDay == day {
            return true
        }
        
        let givenComponents = DateComponents(
            year: currentYear + (
                (
                    month ?? 0
                ) < currentMonth ? 1 : 0
            ),
            month: month,
            day: day
        )
        guard let givenDate = Calendar.current.date(from: givenComponents) else { return false }
        
        var xDays = DateComponents()
        xDays.day = x
        
        if let futureDate = Calendar.current.date(byAdding: xDays, to: currentDate) {
            if (currentDate <= givenDate && givenDate <= futureDate) {
                return true
            }
        }
        
        return false
    }
    
    init(identifier: String? = nil,givenName: String? = nil, familyName: String? = nil, nickname: String? = nil, month: Int? = nil, day: Int? = nil, year: Int? = nil, /*notif: String? = nil, */phones: [CNLabeledValue<CNPhoneNumber>] = [], emails: [CNLabeledValue<NSString>] = [], image: Data? = nil) {
        self.identifier = identifier ?? UUID().uuidString
        self.givenName = givenName
        self.familyName = familyName
        self.nickname = nickname
        self.month = month
        self.day = day
        self.year = year
        self.phones = phones.map{ cnpn in
            return cnpn.value.stringValue
        }
        self.emails = emails.compactMap { cnlv in
            cnlv.value as String
        }
        self.image = image
        
        if identifier != nil {
            self.contactAppIdentifier = identifier
        }
    }
    
    static func areDifferent(_ lhs: Contact, _ rhs: Contact) -> Bool {
        return (
            lhs.identifier != rhs.identifier ||
            lhs.givenName != rhs.givenName ||
            lhs.familyName != rhs.familyName ||
            lhs.nickname != rhs.nickname ||
            lhs.month != rhs.month ||
            lhs.day != rhs.day ||
            lhs.year != rhs.year ||
            lhs.phones != rhs.phones ||
            lhs.image != rhs.image ||
            lhs.emails != rhs.emails
        )
    }
    
    private func nextBirthday(from birthDate: Date) -> Date? {
        let calendar = Calendar.current
        let today = Date()
        
        // Get birth month and day
        let birthComponents = calendar.dateComponents([.month, .day], from: birthDate)
        
        // Create this year's birthday
        var thisYearComponents = calendar.dateComponents([.year], from: today)
        thisYearComponents.month = birthComponents.month
        thisYearComponents.day = birthComponents.day
        
        guard let thisYearBirthday = calendar.date(from: thisYearComponents) else { return nil }
        
        // If this year's birthday hasn't passed, return it
        if thisYearBirthday >= today {
            return thisYearBirthday
        }
        
        // Otherwise, return next year's birthday
        thisYearComponents.year! += 1
        return calendar.date(from: thisYearComponents)
    }

    func getNextBirthday() -> Date? {
        guard let d = self.day, let m = self.month else { return nil }
        
        let y = self.year ?? 0
        if let date = Calendar.current.date(from: DateComponents(year: y, month: m, day: d)) {
            return nextBirthday(from: date)
        } else {
            return nil
        }
    }
    
    func daysToNextBirthday() -> Int? {
        guard let nextBirthday = self.getNextBirthday() else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: nextBirthday).day
    }
    
    // MARK: EXAMPLES -
    static let examples = [
        Contact(identifier: "random1", givenName: "John", familyName: "Smith", nickname: "Jack", month: 2, day: 28, year: 1964, phones: [], emails: [], image: nil),
        Contact(identifier: "random1", givenName: "Jamie", familyName: "Benson", month: 9, day: 4, year: 1997, phones: [], emails: [], image: nil)
    ]
}
