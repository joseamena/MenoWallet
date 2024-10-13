//
//  Configuration.swift
//  MenoWallet
//
//  Created by Jose A Mena on 8/29/24.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct Configuration {
    let environment: Environment
    var colorScheme: ColorScheme = .light
    
    mutating func updateColorScheme(colorScheme: ColorScheme) {
        self.colorScheme = colorScheme
    }
}

extension Configuration: DependencyKey {
    static var liveValue = Configuration(environment: Production())
}

extension DependencyValues {
    var configuration: Configuration {
        get { self[Configuration.self] }
        set { self[Configuration.self] = newValue }
    }
}
