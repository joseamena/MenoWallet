//
//  BitcoinWallet.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/10/24.
//

import Foundation
import WalletCore

class BitcoinWallet: Wallet {
    
    private let hdWallet: HDWallet?
    
    private init(mnemonic: String, passphrase: String) {
        hdWallet = HDWallet(mnemonic: mnemonic, passphrase: passphrase)
//        let addressBTC = hdWallet?.getAddressForCoin(coin: .bitcoin)
        if let key = hdWallet?.getKey(coin: .bitcoin, derivationPath: "m/44\'/1\'/0\'/0/0") {
            let address = CoinType.bitcoin.deriveAddress(privateKey: key)
            print("JM", key.getPublicKey(coinType: .bitcoin).data.hexString)
            print("JM", address)
        }
        
        let testAddress = hdWallet?.getAddressDerivation(coin: .bitcoin, derivation: .custom)
        print(DerivationPath(purpose: .bip44, coin: CoinType.bitcoin.rawValue))
        print("bitcoin address:", testAddress ?? "")
    }
    
    static func create() -> any Wallet {
        BitcoinWallet(mnemonic: "ripple scissors kick mammal hire column oak again sun offer wealth tomorrow wagon turn fatal", passphrase: "")
    }
    
    static func importWallet(mnemonic: String, passphrase: String) -> any Wallet {
        BitcoinWallet(mnemonic: mnemonic, passphrase: passphrase)
    }
}
