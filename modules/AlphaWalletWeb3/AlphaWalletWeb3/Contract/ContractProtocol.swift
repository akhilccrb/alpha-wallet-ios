//
//  ContractProtocol.swift
//  web3swift
//
//  Created by Alexander Vlasov on 04.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

public protocol ContractProtocol {
    var address: EthereumAddress? { get set }
    var options: Web3Options? { get set }
    var allMethods: [String] { get }
    var allEvents: [String] { get }

    init?(abi: String, address: EthereumAddress?)

    func deploy(bytecode: Data, parameters: [AnyObject], extraData: Data, options: Web3Options?) -> EthereumTransaction?
    func method(_ method: String, parameters: [AnyObject], extraData: Data, options: Web3Options?) -> EthereumTransaction?
    func decodeReturnData(_ method: String, data: Data) -> [String: Any]?
    func decodeInputData(_ method: String, data: Data) -> [String: Any]?
    func decodeInputData(_ data: Data) -> [String: Any]?
    func parseEvent(_ eventLog: EventLog) -> (eventName: String?, eventData: [String: Any]?)
    func testBloomForEventPrecence(eventName: String, bloom: EthereumBloomFilter) -> Bool?
}

public protocol EventFilterComparable {
    func isEqualTo(_ other: AnyObject) -> Bool
}

public protocol EventFilterEncodable {
    func eventFilterEncoded() -> String?
}

public protocol EventFilterable: EventFilterComparable, EventFilterEncodable {
    
}

extension BigUInt: EventFilterable {
}
extension BigInt: EventFilterable {
}
extension Data: EventFilterable {
}
extension String: EventFilterable {
}
extension EthereumAddress: EventFilterable {
}

public struct EventFilter {
    public enum Block {
        case latest
        case pending
        case blockNumber(UInt64)
        
        var encoded: String {
            switch self {
            case .latest:
                return "latest"
            case .pending:
                return "pending"
            case .blockNumber(let number):
                return String(number, radix: 16).addHexPrefix()
            }
        }
    }
    
    public init() {
        
    }
    
    public init(fromBlock: Block?, toBlock: Block?, addresses: [EthereumAddress]? = nil, parameterFilters: [[EventFilterable]?]? = nil) {
        self.fromBlock = fromBlock
        self.toBlock = toBlock
        self.addresses = addresses
        self.parameterFilters = parameterFilters
    }
    
    public var fromBlock: Block?
    public var toBlock: Block?
    public var addresses: [EthereumAddress]?
    public var parameterFilters: [[EventFilterable]?]?
    
    public func rpcPreEncode() -> EventFilterParameters {
        var encoding = EventFilterParameters()
        if let fromBlock = fromBlock {
            encoding.fromBlock = fromBlock.encoded
        }
        if let toBlock = toBlock {
            encoding.toBlock = toBlock.encoded
        }
        if let addresses = addresses {
            encoding.address = addresses.map { $0.address }
        }
        return encoding
    }
}
