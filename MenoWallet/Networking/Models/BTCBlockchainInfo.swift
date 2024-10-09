//
//  BTCBlockchainInfo.swift
//  MenoWallet
//
//  Created by Jose A Mena on 8/29/24.
//

import Foundation

struct BTCBlockchainInfo: Decodable {
    var bestblockhash: String
    var blocks: Int
    var chain: String
    var chainwork: String
    var difficulty: Double
    var headers: Int
    var initialblockdownload: Bool
    var mediantime: Int
    var pruned: Bool
    var sizeOnDisk: Int
    var time: Int
    var verificationprogress: Int
    var warnings: String
}
