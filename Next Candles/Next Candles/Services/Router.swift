//
//  Router.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/4/25.
//


import Observation
import SwiftUI

@Observable
class Router {
    private(set) var sheet: Route? = nil
    var sheetIsPresentedBinding: Binding<Bool> {
        .init(
            get: { self.sheet != nil },
            set: { newValue in
                if !newValue {
                    self.sheet = nil
                }
            }
        )
    }
    
    func present(_ route: Route) { sheet = route }
    
    func popToHome() { sheet = nil }
}
