//
//  LoadStatus.swift
//  MenoWallet
//
//  Created by Jose A Mena on 10/13/24.
//
import Foundation

/// The state of a data load.
///
/// - loading: A load is in progress.
/// - empty: No data has been loaded.
/// - error: An error occurred when loading.
/// - none: No load is in progress. This represents both "a load is complete" and "a load has not started."
public enum LoadStatus: Equatable {
    case loading
    case error(LocalizedError)
    case none

    public static func == (lhs: LoadStatus, rhs: LoadStatus) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.none, .none), (.error(_), .error(_)):
            return true
        default:
            return false
        }
    }

    public static func != (lhs: LoadStatus, rhs: LoadStatus) -> Bool {
        !(lhs == rhs)
    }
}

public extension LoadStatus {
    var isLoading: Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }
}
