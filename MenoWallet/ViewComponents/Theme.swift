//
//  Theme.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/13/24.
//

import ComposableArchitecture
import Foundation
import SwiftUI


extension Color {
    struct Theme {
        static var background: Color {
            @Dependency(\.configuration) var configuration
            switch configuration.colorScheme {
            case .light:
                return .white
            case .dark:
                return .black
            @unknown default:
                return .white
            }
        }
        
        static var primary: Color {
//            @Dependency(\.configuration) var configuration
//            switch configuration.colorScheme {
//            case .light:
//                return .acc
//            case .dark:
//                return .secondary
//            @unknown default:
//                return .white
//            }
            return .accentBlue
        }
        
        static var secondary: Color {
            return .secondary
        }
        
        static var accentBlue: Color {
            Color("AccentBlue")
        }
        
        static var accentGreen: Color {
            Color("AccentGreen")
        }
        
        static var darkTeal: Color {
            Color("DarkTeal")
        }
        
        static var tealBlue: Color {
            Color("TealBlue")
        }
        
        static var veryDarkGray: Color {
            Color("VeryDarkGray")
        }
        
        static var gradientBackground: LinearGradient {
            LinearGradient(gradient: Gradient(colors: [.accentBlue, .tealBlue]), startPoint: .top, endPoint: .bottom)
        }
    }
    
}
