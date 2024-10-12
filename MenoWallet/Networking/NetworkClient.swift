//
//  NetworkClient.swift
//  MenoWallet
//
//  Created by Jose A Mena on 8/29/24.
//

import Combine
import Foundation
import Network

protocol NetworkClient {
    var session: URLSession { get }
    var cache: Cache<String, Data> { get }
    var connectivity: Bool { get }
    func buildRequest<T: Decodable>(target: NetworkTarget, type _: T.Type, ignoreCache: Bool, debugJson: Bool) async throws -> T
}

// MARK: - Protocol Default Implementations -

extension NetworkClient {

    // MARK: - NetworkClient Async Await Implementation -

    func buildRequest<T: Decodable>(
        target: NetworkTarget,
        type _: T.Type,
        ignoreCache: Bool = true,
        debugJson: Bool = false
    ) async throws -> T {
        // Check if there is cached data
        if !ignoreCache, let cachedData = cache.value(forKey: target.cacheKey) {
            return try decode(from: cachedData)
        }

        guard connectivity else {
            throw AppError.networkError(.notConnectedToInternet)
        }
        guard let request = target.urlRequest else {
            throw AppError.networkError(.requestCreationFailed)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.networkError(.requestCreationFailed)
        }
        guard 200 ..< 300 ~= httpResponse.statusCode else {
            throw AppError.networkError(.httpError(httpResponse.statusCode))
        }
        do {
            let decoded: T = try decode(from: data)
            if debugJson {
                print(data.prettyPrinted)
            }
            if target.shouldCache {
                cache.insert(data, forKey: target.cacheKey)
            }
            return decoded
        } catch {
            throw AppError.networkError(.decodingError(error as? DecodingError)) 
        }
    }
}

// MARK: - Private Extensions -

extension NetworkClient {
    private func decode<T: Decodable>(
        type _: T.Type = T.self,
        from data: Data
    ) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw error
        }
    }
}

// MARK: - Concrete Implementation -

class BitcoinClient: NetworkClient {
    let session: URLSession = .shared
    let cache = Cache<String, Data>()
    private let monitor = NWPathMonitor()
    private let connectivitySubject = CurrentValueSubject<Bool, Never>(false)

    static let shared = BitcoinClient()

    private init() {
        setupNetworkMonitor()
    }

    var connectivity: Bool {
        connectivitySubject.value
    }

    private func setupNetworkMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.connectivitySubject.send(path.status == .satisfied)
        }

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
}
