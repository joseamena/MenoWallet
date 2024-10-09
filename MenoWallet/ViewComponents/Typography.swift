//
//  Typography.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/12/24.
//

import Foundation
import SwiftUI

enum Typography: ViewModifier {
    
    case caption
    case body
    case title
    case title2
    case title3
    
    var font: Font {
        switch self {
        case .caption:
            return .caption
        case .body:
            return .body
        case .title:
            return .title
        case .title2:
            return .title2
        case .title3:
            return .title3
        }
    }
    
    var color: Color {
        switch self {
        case .body:
            return Color.Theme.veryDarkGray
        case .title:
            return Color.Theme.veryDarkGray
        case .title2:
            return Color.Theme.veryDarkGray
        default:
            return .black
        }
    }
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(color)
            .font(font)
    }
}

//extension Typography.Style {
//    var font: Font {
//        switch self {
//        case .caption:
//            return .caption
//        case .body:
//            return .body
//        case .title:
//            return .title
//        case .title2:
//            return .title2
//        case .title3:
//            return .title3.bold()
//        }
//    }
//    
//    var color: Color {
//        switch self {
//        case .body:
//            return Color.Theme.veryDarkGray
//        case .title:
//            return Color.Theme.veryDarkGray
//        case .title2:
//            return Color.Theme.veryDarkGray
//        default:
//            return .black
//        }
//    }
//    
//
//}

extension View {
    func typography(_ typography: Typography) -> some View {
        modifier(typography)
    }
}
