//
//  Settings.swift
//  Next Candles
//
//  Created by Frank Anderson on 12/3/23.
//

import Foundation

enum SaveError: Error {
    case encoding
}

enum LoadError: Error {
    case decoding, notFound
}

class Settings: ObservableObject, Codable, Equatable {
    static func == (lhs: Settings, rhs: Settings) -> Bool {
        return lhs.janStart == rhs.janStart
        && lhs.dayRange == rhs.dayRange
    }
    
    
    static let defaultsKey = "settings"
    
    static func save(settings: Settings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: defaultsKey)
        } else {
            print("Error saving Settings.")
        }
    }
    
    static func load() -> Settings {
        if let data = UserDefaults.standard.data(forKey: defaultsKey) {    
            do {
                let _ = try JSONDecoder().decode(Settings.self, from: data)
            } catch {
                print(error.localizedDescription)
            }
            
            if let decoded = try? JSONDecoder().decode(Settings.self, from: data) {
                return decoded
            } else {
                print("Error decoding")
            }
        } else {
            print("Not found in defaults")
        }
        
        return Settings()
    }
    
    init() {
        janStart = false
        dayRange = 20
        defaultTime = Calendar.current.nextDate(after: Date(), matching: DateComponents(hour: 0, minute: 0), matchingPolicy: .nextTime) ?? Date()
    }
    
    @Published var janStart: Bool {
        didSet {
            Settings.save(settings: self)
        }
    }
    @Published var dayRange: Int {
        didSet {
            Settings.save(settings: self)
        }
    }
    @Published var defaultTime: Date {
        didSet {
            Settings.save(settings: self)
        }
    }
    
    required init(from decoder: Decoder) throws {
//        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.janStart = try container.decode(Bool.self, forKey: .janStart)
            self.dayRange = try container.decode(Int.self, forKey: .dayRange)
            self.defaultTime = try container.decode(Date.self, forKey: .defaultTime)
//        } catch {
//            print(error.localizedDescription)
//        }
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(janStart, forKey: .janStart)
        try container.encode(dayRange, forKey: .dayRange)
        try container.encode(defaultTime, forKey: .defaultTime)
    }
    
    enum CodingKeys: CodingKey{
        case janStart
        case dayRange
        case defaultTime
    }
}



