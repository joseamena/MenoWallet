//
//  MenoWalletApp.swift
//  MenoWallet
//
//  Created by Jose A Mena on 8/29/24.
//

import SwiftUI

@main
struct MenoWalletApp: App {
    
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: .init(
                    initialState: ContentFeature.State(),
                    reducer: { ContentFeature() }
                )
            )
        }
    }
}
