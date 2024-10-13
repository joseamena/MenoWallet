//
//  AssetDetails.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/13/24.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct AssetDetailsReducer {
    
    @Dependency(\.continuousClock) private var clock
    @Dependency(\.assetsAPI) private var assetsAPI
    
    @ObservableState
    struct State: Equatable {
        var sendReceive: SendReceiveCryptoFeature.State?
        let code: String
        var historyWindow: Calendar.Component = .month
        var historyData: [AssetPriceDataHistoryPoint] = []
        var balance: Decimal = 0
        var currentPrice: Decimal?
        
        init(code: String) {
            self.code = code
            if let coinType = WalletService.CoinType(rawValue: code) {
                sendReceive = SendReceiveCryptoFeature.State(coinType: coinType)
            }
        }
    }
    
    @CasePathable
    enum Action {
        case onAppear
        case sendReceive(SendReceiveCryptoFeature.Action)
        case tick
        case onHistoryDataFetched([AssetPriceDataHistoryPoint])
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .run { send in
                        
                        await send(.tick)
                        
                        for await _ in clock.timer(interval: .seconds(60)) {
                            await send(.tick)
                        }
                    },
                    .run { send in
                        // TODO: talk to bitcoin node to get unspent outputs
                    }
                )
            case .sendReceive:
                return .none
            case .tick:
                return .run { [state] send in
                    let date = Date.now
                    guard let past = Calendar.current.date(byAdding: state.historyWindow, value: -1, to: date) else {
                        return
                    }
                    do {
                        let dataPoints = try await assetsAPI.getAssetHistory(
                            state.code,
                            past.timeIntervalSince1970,
                            date.timeIntervalSince1970
                        ).map {
                            let point = AssetPriceDataHistoryPoint(date: $0.date, price: Decimal($0.rate))
                            return point
                        }
                        
                        await send(.onHistoryDataFetched(dataPoints))
                    } catch {
                        print("JM", error)
                    }
                }
            case .onHistoryDataFetched(let historyData):
                state.historyData = historyData
                state.currentPrice = historyData.last?.price
                return .none
            }
        }
        .ifLet(\.sendReceive, action: \.sendReceive) {
            SendReceiveCryptoFeature()
        }
    }
}

struct AssetDetailsView: View {
    @Bindable var store: StoreOf<AssetDetailsReducer>
    
    var body: some View {
        ZStack {
            Color.Theme.background.ignoresSafeArea()
            content.padding()
        }
        .task {
            await store.send(.onAppear).finish()
        }
    }
    
    var content: some View {
        VStack {
            values
            if let store = store.scope(state: \.sendReceive, action: \.sendReceive) {
                SendReceiveCryptoView(
                    store: store
                )
            }
            XYPlot(dataPoints: store.historyData)
                .frame(height: 300)
                .frame(maxWidth: .infinity)
        }
    }
    
    private var values: some View {
        VStack {
            localCurrencyValue
            currencyValue
        }
    }
    
    var localCurrencyValue: some View {
        Text(store.balance.asCurrency(currencyCode: store.code))
            .typography(.title).bold()
    }
    
    @ViewBuilder
    var currencyValue: some View {
        if let currentPrice = store.currentPrice {
            Text(currentPrice.asCurrency())
                .typography(.title3).bold()
        }
    }
}

#Preview {
    AssetDetailsView(
        store: .init(
            initialState: .init(code: "BTC"),
            reducer: {
                AssetDetailsReducer()
            }
        )
    )
}
