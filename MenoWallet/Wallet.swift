//
//  Wallet.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/10/24.
//

import Foundation

protocol Wallet {
    static func create() -> Wallet
    static func importWallet(mnemonic: String, passphrase: String) -> Wallet
}
