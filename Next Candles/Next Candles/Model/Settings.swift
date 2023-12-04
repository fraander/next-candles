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
    
    @Published var janStart = false {
        didSet {
            Settings.save(settings: self)
        }
    }
    @Published var dayRange = 20 {
        didSet {
            Settings.save(settings: self)
        }
    }
    
    init() {
        self.janStart = false
        self.dayRange = 20
    }
    
    init(dayRangeAlert: Bool = false, janStart: Bool = false, dayRange: Int = 20) {
        self.janStart = janStart
        self.dayRange = dayRange
    }
    
    
    required init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.janStart = try container.decode(Bool.self, forKey: .janStart)
            self.dayRange = try container.decode(Int.self, forKey: .dayRange)
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(janStart, forKey: .janStart)
        try container.encode(dayRange, forKey: .dayRange)
    }
    
    enum CodingKeys: CodingKey{
        case janStart
        case dayRange
    }
}



