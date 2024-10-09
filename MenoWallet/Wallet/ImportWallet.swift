//
//  ImportWallet.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/13/24.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct ImportWalletFeature {
    
    @ObservableState
    struct State: Equatable {
        
    }
    
    enum Action {
        case onAppear
    }
}

struct ImportWalletView: View {
    
    @Bindable var store: StoreOf<ImportWalletFeature>
    
    var body: some View {
        EmptyView()
    }
}
