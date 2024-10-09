//
//  NetworkTarget.swift
//  MenoWallet
//
//  Created by Jose A Mena on 8/29/24.
//

import ComposableArchitecture
import Foundation


enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol NetworkTarget {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any]? { get }
    var headers: [String: String]? { get }
    var shouldCache: Bool { get }
    var baseURL: String? { get } // If it needs to override the environment
}

extension NetworkTarget {
    private var urlString: String {
        @Dependency(\.configuration) var configuration
        guard let baseURL else {
            return configuration.environment.url + path
        }
        return baseURL + path
    }

    var urlRequest: URLRequest? {
        
        @Dependency(\.configuration) var configuration
        var url: URL?
        
        if method == .get {
            var urlComponents = URLComponents(string: urlString)
            if let parameters = parameters {
                urlComponents?.queryItems = parameters.compactMap {
                    if let value = $0.value as? String {
                        return URLQueryItem(name: $0.key, value: value)
                    }
                    return nil
                }
            }
            url = urlComponents?.url
            
        } else {
            url = URL(string: urlString)
        }
        
        guard let url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if method == .post, let parameters {
            let body = try? JSONSerialization.data(
                withJSONObject: parameters,
                options: .prettyPrinted
            )
            print(body?.prettyPrinted ?? "empty")
            request.httpBody = body
        }
        
        if let defaultHeaders = configuration.environment.headers {
            for (key, value) in defaultHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let headers = self.headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        return request
    }
}

extension NetworkTarget {
    var cacheKey: String {
        var params = "[:]"

        if let parameters = parameters {
            params = "\(parameters.sorted(by: { $0.0 < $1.0 }))"
        }

        return "\(type(of: Self.self))--\(path)--\(method)--\(params)"
    }
}
