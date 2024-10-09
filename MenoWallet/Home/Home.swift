//
//  Home.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/12/24.
//

import Foundation
import ComposableArchitecture
import SwiftUI


struct HomeReducer: Reducer {
    
    @Dependency(\.assetsAPI) private var assetsAPI
    
    @ObservableState
    struct State {
        var sendReceive: SendReceiveCryptoFeature.State = .init()
        var assets: [CryptoAsset] = []
        var path = StackState<AssetDetailsReducer.State>()
        @Presents var destination: Destination.State?
    }

    @Reducer
    enum Destination {
        case profile(ProfileFeature)
    }
    
    @CasePathable
    enum Action {
        case onAppear
        case sendReceive(SendReceiveCryptoFeature.Action)
        case onAssetsLoaded([CryptoAsset])
        case path(StackAction<AssetDetailsReducer.State, AssetDetailsReducer.Action>)
        case onProfileButtonTapped
        case destination(PresentationAction<Destination.Action>)
    }
    
    var body: some ReducerOf<Self> {
//        Scope(state: \.sendReceive, action: \.sendReceive) {
//            SendReceiveCryptoFeature()
//        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    try await send(.onAssetsLoaded(assetsAPI.getAssets()))
                }
            case .onAssetsLoaded(let assets):
                state.assets = assets
                return .none
            case .path:
                return .none
            case .sendReceive:
                return .none
            case .onProfileButtonTapped:
                state.destination = .profile(.init())
                return .none
            case .destination:
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            AssetDetailsReducer()
        }
        .ifLet(\.$destination, action: \.destination)
    }
}


struct HomeView: View {
    
    @Bindable var store: StoreOf<HomeReducer>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ZStack {
                Color.Theme.background
                    .ignoresSafeArea()
                content
            }
            .navigationTitle("Asset")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { store.send(.onProfileButtonTapped) }) {
                        Image(systemName: "person")
                    }
                    .foregroundStyle(Color.Theme.veryDarkGray)
                }
            }
        } destination: { store in
            AssetDetailsView(store: store)
        }
        .sheet(item: $store.scope(state: \.destination?.profile, action: \.destination.profile)) { store in
            ProfileView(store: store)
        }
    }
    
    private var content: some View {
        VStack {
//            SendReceiveCryptoView(
//                store: store.scope(state: \.sendReceive, action: \.sendReceive)
//            )
//            .padding()
            assets
//            Spacer()
        }
        .task {
            await store.send(.onAppear).finish()
        }
    }

    private var assets: some View {
        ScrollView {
            VStack(spacing: Dimensions.small.rawValue) {
                ForEach(store.assets) { asset in
                    NavigationLink(state: AssetDetailsReducer.State(code: asset.code)) {
                        AssetRow(
                            imageUrl: asset.iconUrl,
                            title: asset.name,
                            code: asset.code,
                            price: asset.price.asCurrency()
                        )
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    HomeView(
        store: .init(
            initialState: HomeReducer.State(),
            reducer:  {
                HomeReducer()
            }
        )
    )
}
