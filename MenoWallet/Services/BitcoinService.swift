//
//  BitcoinService.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/16/24.
//

import ComposableArchitecture
import Foundation
import WalletCore

struct BitcoinService {
    @Dependency(\.keychain) static var keychain
    @Dependency(\.walletService) static var walletService
    
    var fetchUTXOsForAddresses: ([String]) async throws -> (BTCBalanceResponse)
    var fetchBalance: () async throws -> Decimal
    var sendToAddress: (String, Decimal) async throws -> ()
}

extension BitcoinService {
    static func fetchUTXOs(for addresses: [String]) async throws -> BTCBalanceResponse {
        let target = BitcoinBalance(
            parameters: [
                "addresses": addresses
            ]
        )
        
        let response = try await BitcoinClient.shared.buildRequest(
            target: target,
            type: BTCBalanceResponse.self,
            ignoreCache: true,
            debugJson: true
        )
        
        return response
    }
    
    static func fetchBalance() async throws -> Decimal {
        let addresses = keychain.getArrayOfStringForKey(.bitcoinAddresses)
        
        guard !addresses.isEmpty else {
            return 0
        }
        let utxos = try await fetchUTXOs(for: addresses)
        
        return utxos.utxos.reduce(0) { $0 + $1.value }
    }
    
    static func sendTo(_ address: String, amount: Decimal) async throws {
//        let addresses = keychain.getArrayOfStringForKey(.bitcoinAddresses)
//        
//        guard !addresses.isEmpty else {
//            return
//        }
//        
//        let utxos = try await fetchUTXOs(for: addresses).utxos
//        
        guard let privateKey = keychain.getDataValueForKey(.privateKey) else {
            return
        }
        
        buildTransaction(utxos: [], privateKey: privateKey)
    }
    
    static func buildTransaction(utxos: [UTXO], privateKey: Data) {
//        let unspentTransactions = utxos.map { utxo in
//            BitcoinUnspentTransaction.with {
//                if let txidData = Data(hexString: utxo.txid) {
//                    $0.outPoint.hash = Data(txidData.reversed())
//                    $0.outPoint.index = utxo.n
//                    $0.outPoint.sequence = UINT32_MAX
//                    let sats = utxo.value * 100000000
//                    $0.amount = NSDecimalNumber(decimal: sats).int64Value
//                    $0.script = BitcoinScript.lockScriptForAddress(address: "bcrt1qg6hat7nxdh5y3redgg0x7dnfzu6u6j0dpuak99", coin: .bitcoin).data
//                }
//            }
//        }
        
        var input = BitcoinSigningInput.with {
            $0.hashType = TWBitcoinSigHashTypeAll.rawValue//BitcoinScript.hashTypeForCoin(coinType: .bitcoin)
            $0.amount = 400
            $0.byteFee = 1
            $0.toAddress = "1Bp9U1ogV3A14FMvKbRJms7ctyso4Z4Tcx"
            $0.changeAddress = "1FQc5LdgGHMHEN9nwkjmz6tWkxhPpxBvBU"
            $0.coinType = CoinType.bitcoin.rawValue
        }
        
        let outPoint = BitcoinOutPoint.with {
                    $0.hash = Data(hexString: "050d00e2e18ef13969606f1ceee290d3f49bd940684ce39898159352952b8ce2")!
                    $0.index = 2
                }
        
        guard let addressBtc = walletService.getAddressForCoin(.bitcoin) else {
            return
        }
        let utxo = BitcoinUnspentTransaction.with {
                    $0.amount = 5151
                    $0.outPoint = outPoint
            $0.script = BitcoinScript.lockScriptForAddress(address: addressBtc, coin: .bitcoin).data
                }
        
//        input.utxo.append(contentsOf: [unspentTransactions])
        input.utxo.append(utxo)
        input.privateKey.append(privateKey)
        
        let plan: BitcoinTransactionPlan = AnySigner.plan(input: input, coin: .bitcoin)
        print("Planned fee:  ", plan.fee, "amount:", plan.amount, "avail_amount:", plan.availableAmount, "change:", plan.change)

        input.plan = plan
        input.amount = plan.amount
        
        let outputBtc: BitcoinSigningOutput = AnySigner.sign(input: input, coin: .bitcoin)

        print("Signed transaction:")
        print(" data:   ", outputBtc.encoded.hexString)
    }
}

extension BitcoinService: DependencyKey {
    static var liveValue = BitcoinService(
        fetchUTXOsForAddresses: fetchUTXOs(for:), 
        fetchBalance: fetchBalance,
        sendToAddress: sendTo(_:amount:)
    )
}

extension DependencyValues {
    var bitcoinService: BitcoinService {
        get { self[BitcoinService.self] }
        set { self[BitcoinService.self] = newValue }
    }
}
