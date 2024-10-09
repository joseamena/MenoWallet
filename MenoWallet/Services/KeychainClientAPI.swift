//
//  KeychainClientAPI.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/13/24.
//

import ComposableArchitecture
import Foundation

struct KeychainClientAPI {
    var getDataValueForKey: (Key) -> Data?
    var saveDataValueForKey: (Data, Key) -> ()
    var hasValueForKey: (Key) -> Bool
    var saveArrayOfStringsForKey: ([String], Key) -> ()
    var getArrayOfStringForKey: (Key) -> [String]
    var getStringValueForKey: (Key) -> String?
    var saveStringValueForKey: (String, Key) -> ()
    
    enum Key: String {
        case privateKey
        case bitcoinAddresses
        case walletPassphrase
    }
    
    static private func setValue(_ data: Data, forKey: Key) {
        KeychainWrapper.standard.set(
            data,
            forKey: forKey.rawValue,
            withAccessibility: .whenUnlockedThisDeviceOnly
        )
    }
    
    static private func data(forKey: Key) -> Data? {
        KeychainWrapper.standard.data(forKey: forKey.rawValue)
    }
    
    static private func hasValue(forKey: Key) -> Bool {
        KeychainWrapper.standard.hasValue(forKey: forKey.rawValue)
    }
    
    static private func setArrayOfStrings(_ strings: [String], forKey: Key) {
        guard let data = try? JSONSerialization.data(withJSONObject: strings, options: []) else {
            return
        }
        self.setValue(data, forKey: .bitcoinAddresses)
    }
    
    static private func getArrayOfStrings(forKey: Key) -> [String] {
        guard let data = data(forKey: .bitcoinAddresses) else {
            return []
        }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String]) ?? []
    }
    
    static private func getString(forKey: Key) -> String? {
        KeychainWrapper.standard.string(forKey: forKey.rawValue)
    }
    
    static private func saveString(_ string: String, forKey: Key) {
        KeychainWrapper.standard.set(string, forKey: forKey.rawValue)
    }
}

extension KeychainClientAPI: DependencyKey {
    static var liveValue = KeychainClientAPI(
        getDataValueForKey: data(forKey:),
        saveDataValueForKey: setValue(_:forKey:),
        hasValueForKey: hasValue(forKey:),
        saveArrayOfStringsForKey: setArrayOfStrings(_:forKey:),
        getArrayOfStringForKey: getArrayOfStrings(forKey:),
        getStringValueForKey: getString(forKey:),
        saveStringValueForKey: saveString(_:forKey:)
    )
    
    static var previewValue = KeychainClientAPI(
        getDataValueForKey: { _ in
            Data()
        },
        saveDataValueForKey: { _, _ in
        },
        hasValueForKey: { _ in true },
        saveArrayOfStringsForKey: { _, _ in },
        getArrayOfStringForKey: { _ in [] },
        getStringValueForKey: { _  in nil },
        saveStringValueForKey: { _, _ in }
    )
}

extension DependencyValues {
    var keychain: KeychainClientAPI {
        get { self[KeychainClientAPI.self] }
        set { self[KeychainClientAPI.self] = newValue }
    }
}
