//
//  PrimaryButton.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/13/24.
//

import SwiftUI

struct PrimaryButton: View {
    
    let action: () -> ()
    let text: String
    
    var body: some View {
        Button(action: action, label: {
            Text(text)
                .padding()
                .foregroundStyle(.black)
                .typography(.body)
                .frame(height: Dimensions.xxl.rawValue)
                .frame(maxWidth: .infinity)
                .background(Color.Theme.primary)
                .cornerRadius(Dimensions.xxl.rawValue / 2)
        })
    }
}

#Preview {
    PrimaryButton(action: { }, text: "Teto")
}
