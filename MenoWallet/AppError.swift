//
//  AppError.swift
//  MenoWallet
//
//  Created by Jose A Mena on 8/29/24.
//

import Foundation

enum AppError: Error {
//    case requestCreationFailed
//    case httpError(Int)
//    case decodingError(DecodingError?)
//    case unknown
//    case notConnectedToInternet
    case networkError(NetworkingError)
    case cryptoError(CryptoError)
}

enum NetworkingError: Error {
    case requestCreationFailed
    case httpError(Int)
    case decodingError(DecodingError?)
    case notConnectedToInternet
    case unknown
}

enum CryptoError: Error {
    case unknown
}
