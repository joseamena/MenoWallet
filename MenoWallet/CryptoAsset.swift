//
//  CryptoAsset.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/13/24.
//

import Foundation

struct CryptoAsset: Identifiable {
    let iconUrl: String
    let name: String
    let code: String
    let price: Decimal
    
    var id: String {
        name
    }
}

struct CoinHistoryDataPoint {
    let date: Date
    let rate: Double
    let volume: Int
    let cap: Int
}
