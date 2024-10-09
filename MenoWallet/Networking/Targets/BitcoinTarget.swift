//
//  BitcoinTarget.swift
//  MenoWallet
//
//  Created by Jose A Mena on 8/29/24.
//

import Foundation

struct BitcoinTarget: NetworkTarget {
    var path: String = ""
    
    var method: HTTPMethod = .get
    
    var parameters: [String : Any]?
    
    var headers: [String : String]?
    
    var shouldCache: Bool = false
    
    var baseURL: String? = nil
}

struct BitcoinBalance: NetworkTarget {
    var path: String = "/balance"
    
    var method: HTTPMethod = .post
    
    var parameters: [String : Any]?
    
    var headers: [String : String]?
    
    var shouldCache: Bool = false
    
    var baseURL: String? = nil
}

