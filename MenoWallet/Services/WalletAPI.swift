//
//  WalletAPI.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/14/24.
//

import ComposableArchitecture
import CryptoKit
import Foundation
import WalletCore
import BitcoinSwift
import BigInt

//protocol WalletServiceAPI {
//    func createNewWallet(passphrase: String) -> [String]
//}

struct WalletService {
    @Dependency(\.configuration) static var configuration
    @Dependency(\.keychain) static var keychain
    
    private static var wallet: HDWallet? = {
        guard let data = keychain.getDataValueForKey(.privateKey) else {
            return nil
        }
        
        let passphrase = keychain.getStringValueForKey(.walletPassphrase) ?? ""
        let wallet = HDWallet(entropy: data, passphrase: passphrase)
        return wallet
    }()
    
    var createNewWallet: (String) -> ([String], Data)
    var getAddressForCoin: (CoinType) -> String?
    var getPrivateKey: () -> Data?
    var getPassphrase: () -> String?
    
    enum CoinType {
        case bitcoin
    }
}

extension WalletService: DependencyKey {
    static var liveValue = WalletService(
        createNewWallet: { passphrase in
            var bytes = [UInt8](repeating: 0, count: 32)
            _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
            let wallet = HDWallet(entropy: bytes.data, passphrase: passphrase)
            
            return (wallet?.mnemonic.components(separatedBy: " ") ?? [], bytes.data)
        },
        getAddressForCoin: { coinType in
            switch configuration.environment.bitcoinNetwork {
            case .mainNet:
                return wallet?.getAddressForCoin(coin: .bitcoin)
            case .testNet:
                return wallet?.getAddressDerivation(coin: .bitcoin, derivation: .bitcoinTestnet)
            case .regTest:
                guard let wallet = wallet else {
                    return nil
                }
                if keychain.hasValueForKey(.bitcoinAddresses) {
                    return keychain.getArrayOfStringForKey(.bitcoinAddresses).first
                }
                let bytes = [UInt8](wallet.entropy)
                let num = BInt(magnitude: bytes)
                let privateKey = BitcoinSwift.PrivateKey(secret: num)
                return privateKey.getAddress(network: .regTest)
            }
        },
        getPrivateKey: {
            guard let key = keychain.getDataValueForKey(.privateKey) else {
                return nil
            }
            return key
        },
        getPassphrase: {
            keychain.getStringValueForKey(.walletPassphrase)
        }
    )
}

extension DependencyValues {
    var walletService: WalletService {
        get { self[WalletService.self] }
        set { self[WalletService.self] = newValue }
    }
}
