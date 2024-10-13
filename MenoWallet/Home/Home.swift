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
    struct State: Equatable {
        var assets: [CryptoAsset] = []
        var path = StackState<AssetDetailsReducer.State>()
        var loadStatus = LoadStatus.loading
        @Presents var destination: Destination.State?
    }

    @Reducer(state: .equatable)
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
        case onError(Error)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    do {
                        try await send(.onAssetsLoaded(assetsAPI.getAssets()))
                    } catch {
                        await send(.onError(error))
                    }
                }
            case .onAssetsLoaded(let assets):
                state.assets = assets
                state.loadStatus = .none
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
            case .onError(let error):
                if let localizedError = error as? LocalizedError {
                    state.loadStatus = .error(localizedError)
                } else {
                    state.loadStatus = .error(AppError.unknown)
                }
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
            .navigationTitle("Assets")
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
            loadingView
        }
        .task {
            await store.send(.onAppear).finish()
        }
    }
    
    @ViewBuilder
    private var loadingView: some View {
        switch store.loadStatus {
        case .loading:
            ProgressView()
        case .none:
            assets
        case .error(let error):
            Text(error.localizedDescription)
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
