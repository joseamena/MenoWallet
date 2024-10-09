//
//  CoinWatch.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/17/24.
//

import Foundation

struct Coin: Decodable {
    let name: String
    let symbol: String?
    let rank: Int
    let age: Int
    let color: String
    let png32: String
    let png64: String
    let rate: Decimal
    let code: String?
//      "webp32": "https://lcw.nyc3.cdn.digitaloceanspaces.com/production/currencies/32/eth.webp",
//      "webp64": "https://lcw.nyc3.cdn.digitaloceanspaces.com/production/currencies/64/eth.webp",
//      "exchanges": 153,
//      "markets": 3717,
//      "pairs": 1773,
//      "allTimeHighUSD": 2036.3088032624153,
//      "circulatingSupply": 115250583,
//      "totalSupply": null,
//      "maxSupply": null,
//      "categories": ["smart_contract_platforms"],
//      "volume": 11522748696,
//      "cap": 205915246068,
//      "delta": {
//        "hour": 1.008,
//        "day": 1.0808,
//        "week": 1.2793,
//        "month": 1.4754,
//        "quarter": 0.4804,
//        "year": 0.7455
//      }
}

struct HistoryResponse: Decodable {
    let code: String
    let name: String
    let symbol: String?
    let rank: Int
    let age: Int
    let color: String
    let png32: URL
    let png64: URL
    let webp32: URL
    let webp64: URL
    let exchanges: Int
    let markets: Int
    let pairs: Int
    let allTimeHighUSD: Double
    let circulatingSupply: Int
    let totalSupply: Int?
    let maxSupply: Int?
    let categories: [String]
    let history: [History]
    
    struct History: Decodable {
        let date: Date
        let rate: Double
        let volume: Int
        let cap: Int
    }
}
