//
//  Foundation+Extensions.swift
//  MenoWallet
//
//  Created by Jose A Mena on 8/29/24.
//

import Foundation
import WalletCore

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = removingDuplicates()
    }
}

extension Data {
    var prettyPrinted: String {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: self, options: [])
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8) ?? "Invalid JSON"
        } catch {
            return "Invalid JSON"
        }
    }
}

extension UInt32 {
    var currency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
//        formatter.maximumFractionDigits = 2

        let number = NSNumber(value: self)
        let formattedValue = formatter.string(from: number)!
        return "\(formattedValue)"
    }
}

extension Decimal {
    func asCurrency(currencyCode: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        return formatter.string(for: self) ?? "0"
    }
}

extension String {
//    var isValidBitcoinAddress: Bool {
// 
//        guard let address = AnyAddress(string: self, coin: .bitcoin) else {
//            return false
//        }
//      
//        return true
//    }
}

extension String {
    var isValidBitcoinAddress: Bool {
        // Step 1: Check length
        guard (26...35).contains(self.count) else {
            return false
        }

        // Step 2: Check character set
        let base58Chars = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
        for character in self {
            if !base58Chars.contains(character) {
                return false
            }
        }

        // Step 3: Base58Check decode
        guard let decoded = base58CheckDecode(self) else {
            return false
        }

        // Check length of decoded result (should be 25 bytes)
        return decoded.count == 25
    }

    private func base58CheckDecode(_ address: String) -> Data? {
        let base58Chars = Array("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")
        var result = Data()

        for character in address {
            guard let index = base58Chars.firstIndex(of: character) else {
                return nil
            }
            let value = base58Chars.distance(from: base58Chars.startIndex, to: index)
            var carry = value
            for i in 0..<result.count {
                carry += 58 * Int(result[i])
                result[i] = UInt8(carry % 256)
                carry /= 256
            }
            while carry > 0 {
                result.append(UInt8(carry % 256))
                carry /= 256
            }
        }

        // Reverse the result
        result.reverse()

        // Remove leading zeroes (representing '1's in base58)
        let leadingZeroCount = address.prefix(while: { $0 == "1" }).count
        let decodedLength = leadingZeroCount + (result.count - leadingZeroCount)
        return Data(repeating: 0, count: leadingZeroCount) + result
    }
}
