//
//  CoinsService.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/17/24.
//

import ComposableArchitecture
import Foundation

struct CoinService {
    var fetchCoinDetails: (String) async throws -> (Coin)
    var fetchCoinList: () async throws -> ([Coin])
    var fetchCoinHistory: (String, TimeInterval, TimeInterval) async throws -> (HistoryResponse)
}

extension CoinService: DependencyKey {
    static var liveValue = CoinService(
        fetchCoinDetails: { code in
            
            let target = CoinWatchTarget.coin(
                currency: "USD",
                code: code,
                meta: true
            )
            
            let response = try await BitcoinClient.shared.buildRequest(
                target: target,
                type: Coin.self,
                ignoreCache: true,
                debugJson: true
            )
            
            return response
        },
        fetchCoinList: {
            let target = CoinWatchTarget
                .coinsList(
                    currency: "USD",
                    sort: "rank",
                    order: "ascending",
                    offset: 0,
                    limit: 10,
                    meta: true
                )
            
            let response = try await BitcoinClient.shared.buildRequest(
                target: target,
                type: [Coin].self,
                ignoreCache: true,
                debugJson: false
            )
            
            return response
        }, 
        fetchCoinHistory: { code, start, end in
            let target = CoinWatchTarget
                .history(
                    currency: "USD",
                    code: code,
                    start: start,
                    end: end,
                    meta: true
                )
            
            return try await BitcoinClient.shared.buildRequest(
                target: target,
                type: HistoryResponse.self,
                ignoreCache: true,
                debugJson: true
            )
        }
    )
}

extension DependencyValues {
    var coinService: CoinService {
        get { self[CoinService.self] }
        set { self[CoinService.self] = newValue }
    }
}
