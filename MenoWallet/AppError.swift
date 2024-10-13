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
    case unknown
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

extension AppError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .networkError(let networkError):
            return "Network Error"
        case .cryptoError(let cryptoError):
            return "Crypto Error"
        case .unknown:
            return "Unknown"
        }
    }

    /// A localized message describing the reason for the failure.
    var failureReason: String? {
        switch self {
        case .networkError(let networkError):
            return nil
        case .cryptoError(let cryptoError):
            return nil
        case .unknown:
            return "Unknown failure reason"
        }
    }

    /// A localized message describing how one might recover from the failure.
//    var recoverySuggestion: String? {
//        switch self {
//            return nil
//        }
//    }

    /// A localized message providing "help" text if the user requests help.
//    var helpAnchor: String? { get }
}

extension NetworkingError: LocalizedError {
    
}
