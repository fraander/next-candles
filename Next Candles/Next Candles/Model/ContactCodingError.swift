//
//  ContactCodingError.swift
//  Next Candles
//
//  Created by Frank Anderson on 9/12/22.
//

import Foundation

// types of errors from converting CNContact to ContactWrapper
enum ContactCodingError: Error {
    // initializer: doesn't have all valid properties to be wrapped
    // fetch: error in fetching contacts from the store
    case initializer, fetch
}
