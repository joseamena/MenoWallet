//
//  ViewModifiers.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/21/24.
//

import Foundation
import SwiftUI

struct DisabledOpacityModifier: ViewModifier {
    var isDisabled: Bool
    
    func body(content: Content) -> some View {
        content
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.5 : 1.0) // Change opacity based on the disabled state
    }
}

extension View {
    func isDisabled(_ disabled: Bool) -> some View {
        modifier(DisabledOpacityModifier(isDisabled: disabled))
    }
}
