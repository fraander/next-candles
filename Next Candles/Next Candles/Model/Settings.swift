//
//  Settings.swift
//  Next Candles
//
//  Created by frank on 8/17/25.
//

struct S {
    // MARK: - Month Top
    static let monthTopKey: String = "monthTop"
    static let monthTopDefault: MonthTopOption = .current
    
    enum MonthTopOption: String, CaseIterable {
        case current
        case january
        
        static let allCases: [S.MonthTopOption] = [.current, .january]
    }
    
    // MARK: - Highlight range
    static let highlightRangeKey: String = "highlightRange"
    static let highlightRangeDefault = 20
    
    // MARK: - Month index
    static let monthIndexKey: String = "monthIndex"
    static let monthIndexDefault: MonthIndexOption = .hashed
    
    enum MonthIndexOption: String, CaseIterable {
        case hashed
        case showAll
        case hidden
    }
    
    // MARK: - Empty month sections
    static let emptyMonthSectionKey: String = "emptyMonthSection"
    static let emptyMonthSectionDefault: EmptyMonthSectionOption = .shown
    
    enum EmptyMonthSectionOption: String, CaseIterable {
        case shown
        case hidden
    }
}
