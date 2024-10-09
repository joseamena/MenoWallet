//
//  AppError.swift
//  MenoWallet
//
//  Created by Jose A Mena on 8/29/24.
//

import Foundation

enum AppError: Error {
    case requestCreationFailed
    case httpError(Int)
    case decodingError(DecodingError?)
    case unknown
    case notConnectedToInternet
}
