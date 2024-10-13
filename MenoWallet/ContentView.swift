//
//  ContentView.swift
//  MenoWallet
//
//  Created by Jose A Mena on 8/29/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct ContentFeature {
    
    @Dependency(\.keychain) private var keychain
    
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case home(HomeReducer)
        case welcome(WelcomeFeature)
    }
    
    enum Action {
        case onAppear
        case onPrivateKeyAvailableFetched(Bool)
        case destination(PresentationAction<Destination.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    if keychain.hasValueForKey(.privateKey) {
                        await send(.onPrivateKeyAvailableFetched(true))
                    } else {
                        await send(.onPrivateKeyAvailableFetched(false))
                    }
                }
            case .onPrivateKeyAvailableFetched(let hasPrivateKey):
                if hasPrivateKey {
                    state.destination = .home(.init())
                } else {
                    state.destination = .welcome(.init())
                }
                return .none
            case .destination(let action):
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

struct ContentView: View {
    @Bindable var store: StoreOf<ContentFeature>
    
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    @Dependency(\.configuration) var configuration
    let bitcoinClient = BitcoinClient.shared

    var body: some View {
//        NavigationStack {
            Text("MenoWallet")
                .fullScreenCover(
                    item: $store.scope(
                        state: \.destination?.home,
                        action: \.destination.home
                    )
                ) { store in
                    HomeView(store: store)
                }
                .fullScreenCover(
                    item: $store.scope(
                        state: \.destination?.welcome,
                        action: \.destination.welcome
                    )
                ) { store in
                    WelcomeView(store: store)
                }
//                .navigationDestination(
//                    item: $store.scope(
//                        state: \.destination?.home,
//                        action: \.destination.home
//                    )
//                ) { store in
//                    HomeView(store: store)
//                }
//                .navigationDestination(
//                    item: $store.scope(
//                        state: \.destination?.welcome,
//                        action: \.destination.welcome
//                    )
//                ) { store in
//                    WelcomeView(store: store)
//                }
//        }
        .task {
            await store.send(.onAppear).finish()
        }
        
    }
}

#Preview {
    ContentView(
        store: .init(
            initialState: ContentFeature.State(),
            reducer: { ContentFeature() }
        )
    )
}
