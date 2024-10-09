//
//  CoinWatchTarget.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/17/24.
//

import Foundation

enum CoinWatchTarget {
    case coin(currency: String, code: String, meta: Bool)
    case coinsList(currency: String, sort: String, order: String, offset: Int, limit: Int, meta: Bool)
    case history(currency: String, code: String, start: TimeInterval, end: TimeInterval, meta: Bool)
}

extension CoinWatchTarget: NetworkTarget {
    var path: String {
        switch self {
        case .coin:
            "/coins/single"
        case .coinsList:
            "/coins/list"
        case .history:
            "/coins/single/history"
        }
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .coin(let currency, let code, let meta):
            [
                "currency": currency,
                "code": code,
                "meta": meta
            ]
        case .coinsList(currency: let currency, sort: let sort, order: let order, offset: let offset, limit: let limit, meta: let meta):
            [
                "currency": currency,
                "sort": sort,
                "order": order,
                "offset": offset,
                "limit": limit,
                "meta": meta
            ]
        case .history(currency: let currency, code: let code, start: let start, end: let end, meta: let meta):
            [
                "currency": currency,
                "code": code,
                "start": Int64(start * 1000),
                "end": Int64(end * 1000),
                "meta": meta
            ]
        }
    }
    
    var headers: [String : String]? {
        [
            :
        ]
    }
    
    var shouldCache: Bool {
        false
    }
    
    var baseURL: String? {
        "https://api.livecoinwatch.com"
    }
}
