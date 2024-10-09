//
//  Data+PrivateKey.swift
//  MenoWallet
//
//  Created by Jose A Mena on 10/3/24.
//

import Foundation
import WalletCore

extension Data {
    func toMnemonicPhrase(with passphrase: String?) -> String? {
        // use wallet core to make this easier
        let wallet = HDWallet(entropy: self, passphrase: passphrase ?? "")
        return wallet?.mnemonic
    }
}
