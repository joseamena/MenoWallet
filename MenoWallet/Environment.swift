//
//  Environment.swift
//  MenoWallet
//
//  Created by Jose A Mena on 8/29/24.
//
import BitcoinSwift
import Foundation

//enum BitcoinNetwork {
//    case mainNet
//    case testNet
//    
//    var prefix: UInt8 {
//        
//    }
//}

protocol Environment {
    /// The url of the primary MenoWallet services.
    var url: String { get }
    /// The version of MenoWallet services.
    var version: String { get }
    /// The client identifier for accessing MenoWallet services.
    var clientId: String { get }
    /// The client secret for accessing MenoWallet services.
    var clientSecret: String { get }
    /// The device making the request of MenoWallet services.
//    var deviceId: String { get }
    /// Additional headers that should be added to the MenoWallet request headers.
    var headers: [String: String]? { get }
    
    var bitcoinNetwork: S256Point.Network { get }
}

class TestEnvironment: Environment {
    var url: String = "http://192.168.86.210:5000"
    
    var version: String = "0.1"
    
    var clientId: String = ""
    
    var clientSecret: String = ""
    
//    var deviceId: String
    
    var headers: [String : String]? = [
        "Content-Type": "application/json"
    ]
    
    var bitcoinNetwork: S256Point.Network  = .regTest
}

class Production: Environment {
    var url: String = "http://192.168.86.210:5000"
    
    var version: String = "0.1"
    
    var clientId: String = ""
    
    var clientSecret: String = ""
    
//    var deviceId: String
    
    var headers: [String : String]? = [
        "Content-Type": "application/json"
    ]
    
    var bitcoinNetwork: S256Point.Network  = .mainNet
}

