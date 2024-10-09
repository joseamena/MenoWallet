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
    struct State {
        var destination: Destination? = nil
    }
    
    enum Destination {
        case home
        case welcome
    }
    
    enum Action {
        case onAppear
        case onLoaded(Destination?)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    if keychain.hasValueForKey(.privateKey) {
                        await send(.onLoaded(.home))
                    } else {
                        await send(.onLoaded(.welcome))
                    }
                }
            case .onLoaded(let destination):
                state.destination = destination
                return .none
            }
        }
    }
}

struct ContentView: View {
//    let bitcoinService = BitcoinService()
    
    @Bindable var store: StoreOf<ContentFeature>
    
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    @Dependency(\.configuration) var configuration
    let bitcoinClient = BitcoinClient.shared

    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!")
//        }
//        .padding()
//        .task {
//            let target = BitcoinTarget()
//            let wallet = BitcoinWallet.create()
//            do {
//                let info = try await bitcoinClient.buildRequest(target: target, type: BTCBlockchainInfo.self)
//                print(info)
//            } catch {
//                print(error)
//            }
//        }
//        HomeView(
//            store: .init(
//                initialState: HomeReducer.State(),
//                reducer: { HomeReducer() }
//            )
//        )
        
        Group {
            if let destination = store.destination {
                switch destination {
                case .home:
                    HomeView(
                        store: .init(
                            initialState: HomeReducer.State(),
                            reducer: { HomeReducer() }
                        )
                    )
                case .welcome:
                    WelcomeView(
                        store: .init(
                            initialState: WelcomeFeature.State(),
                            reducer: { WelcomeFeature() }
                        )
                    )
                }
            } else {
               
            }
        }
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
