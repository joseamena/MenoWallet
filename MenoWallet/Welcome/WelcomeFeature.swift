//
//  WelcomeFeature.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/13/24.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct WelcomeFeature {
    
    @Reducer(state: .equatable)
    enum Path {
        case createWallet(CreateWalletFeature)
        case importWallet(ImportWalletFeature)
    }
    
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
    }
    
//    @CasePathable
    enum Action {
        case path(StackActionOf<Path>)
//        case onCreateWalletTapped
    }
    
    
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
//            case .path(.element(id: _, action: .importWallet(.)))
//            case .path(.element(id: _, action: .list(.onCreateWalletTapped)))
            case .path(let pathAction):
                return .none
//            case .onCreateWalletTapped:
//                state.path.append(.createWallet(CreateWalletFeature.State()))
//                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

struct WelcomeView: View {
    
    @Bindable var store: StoreOf<WelcomeFeature>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ZStack {
                Color.Theme.background
                    .ignoresSafeArea()
                content
                    .padding()
            }
        } destination: { store in
            switch store.case {
            case .createWallet(let store):
                CreateWalletView(store: store)
            case .importWallet(let store):
                ImportWalletView(store: store)
            }
        }
    }
    
    private var content: some View {
        VStack {
            Text("Welcome")
            NavigationLink(state: WelcomeFeature.Path.State.createWallet(CreateWalletFeature.State())) {
                Text("Create Wallet")
            }
            NavigationLink(state: WelcomeFeature.Path.State.importWallet(ImportWalletFeature.State())) {
                Text("Import Wallet")
            }
//            PrimaryButton(action: { store.send(.onCreateWalletTapped) }, text: "Create Wallet")
//            NavigationLink(state: WelcomeFeature.Path.State.importWallet(ImportWalletFeature.State())) {
//                PrimaryButton(action: {}, text: "Create a wallet")
//                Text("Import Wallet")
//            }
        }
    }
}
