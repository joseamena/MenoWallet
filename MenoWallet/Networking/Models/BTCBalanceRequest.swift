//
//  BTCBalanceRequest.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/16/24.
//

import Foundation

struct BTCBalanceRequest: Encodable {
    let addresses: [String]
}

struct BTCBalanceResponse: Decodable {
    let utxos: [UTXO]
}

struct UTXO: Decodable {
    let bestblock: String
    let confirmations: Int
    let value: Decimal
    let txid: String
//    let scriptPubKey: ScriptPubKey
    let coinbase: Bool
    let n: UInt32
    let address: String
}

struct ScriptPubKey: Decodable {
//    let asm: String
//    let desc: String
//    let hex: String
    let address: String
    let type: String
}
