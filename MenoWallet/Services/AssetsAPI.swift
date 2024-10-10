//
//  AssetsAPI.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/13/24.
//

import ComposableArchitecture
import Foundation
import BigInt
import BitcoinSwift

struct AssetsAPI {
    @Dependency(\.bitcoinService) static  private var bitcoinService
    @Dependency(\.walletService) static private var walletService
    @Dependency(\.keychain) static private var keychain
    @Dependency(\.coinService) static private var coinService
    
    var getAssets: () async throws -> [CryptoAsset]
    var getAssetHistory: (String, TimeInterval, TimeInterval) async throws -> [CoinHistoryDataPoint]
}

extension AssetsAPI: DependencyKey {
    static var liveValue = AssetsAPI(
        getAssets: {

//            let bitcoinAddresses = keychain.getArrayOfStringForKey(.bitcoinAddresses)
//            guard !bitcoinAddresses.isEmpty else {
//                return []
//            }
//            let response = try await bitcoinService.fetchUTXOsForAddresses(bitcoinAddresses)
//            let balance = response.utxos.reduce(0) { $0 + $1.value }
//
//            let coin = try await coinService.fetchCoinDetails("BTC")
            let coins = try await coinService.fetchCoinList()
            
            let assets = coins.map { coin in
                CryptoAsset(
                    iconUrl: coin.png32,
                    name: coin.name,
                    code: coin.code ?? "",
                    price: coin.rate
                )
            }
            
            return assets
        },
        getAssetHistory: { code, start, end in
            let dataHistory = try await coinService.fetchCoinHistory(code, start, end)
            return dataHistory.history.map {
                CoinHistoryDataPoint(
                    date: Date.init(timeIntervalSince1970: TimeInterval($0.date / 1000)),
                    rate: $0.rate,
                    volume: $0.volume,
                    cap: $0.cap
                )
            }
        }
    )
    
    static var previewValue = AssetsAPI(
        getAssets: {
            [
                CryptoAsset(
                    iconUrl: "https://lcw.nyc3.cdn.digitaloceanspaces.com/production/currencies/32/eth.png",
                    name: "Ethereum",
                    code: "ETH",
                    price: 3000
                ),
            ]
        }, getAssetHistory: { _, _, _ in
            []
        }
    )
}

extension DependencyValues {
    var assetsAPI: AssetsAPI {
        get { self[AssetsAPI.self] }
        set { self[AssetsAPI.self] = newValue }
    }
}
