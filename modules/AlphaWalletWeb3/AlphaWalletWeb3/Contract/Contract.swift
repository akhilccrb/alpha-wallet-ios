//
//  ContractV1.swift
//  web3swift
//
//  Created by Alexander Vlasov on 10.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

@available(*, deprecated)
public struct ContractV1: ContractProtocol {
    public var allEvents: [String] {
        return events.keys.flatMap { $0 }
    }
    public var allMethods: [String] {
        return methods.keys.flatMap { $0 }
    }
    
    public var address: EthereumAddress?
    var abi: [ABIElement]
    public var methods: [String: ABIElement] {
        var toReturn: [String: ABIElement] = [:]
        for m in self.abi {
            switch m {
            case .function(let function):
                guard let name = function.name else { continue }
                toReturn[name] = m
            default:
                continue
            }
        }
        return toReturn
    }
    
    public var constructor: ABIElement? {
        var toReturn: ABIElement?
        for elem in self.abi {
            if toReturn != nil {
                break
            }
            switch elem {
            case .constructor:
                toReturn = elem
            default:
                continue
            }
        }

        return toReturn ?? ABIElement.constructor(ABIElement.Constructor.init(inputs: [], constant: false, payable: false))
    }
    
    public var events: [String: ABIElement] {
        var toReturn: [String: ABIElement] = [:]
        for elem in self.abi {
            switch elem {
            case .event(let event):
                let name = event.name
                toReturn[name] = elem
            default:
                continue
            }
        }
        return toReturn
    }
    
    public var options: Web3Options? = Web3Options.defaultOptions()
    
    public init?(abi abiString: String, address: EthereumAddress? = nil) {
        do {
            guard let jsonData = abiString.data(using: .utf8) else { return nil }
            
            self.abi = try JSONDecoder().decode([ABIRecord].self, from: jsonData).map { try $0.parse() }
            self.address = address
        } catch {
            print(error)
            return nil
        }
    }
    
    public init(abi: [ABIElement]) {
        self.abi = abi
    }
    
    public init(abi: [ABIElement], at: EthereumAddress) {
        self.abi = abi
        self.address = at
    }
    
    public func deploy(bytecode: Data, parameters: [AnyObject] = [AnyObject](), extraData: Data = Data(), options: Web3Options?) -> EthereumTransaction? {
        let to: EthereumAddress = EthereumAddress.contractDeploymentAddress()
        let mergedOptions = Web3Options.merge(self.options, with: options)
        
        var gasLimit: BigUInt
        if let gasInOptions = mergedOptions?.gasLimit {
            gasLimit = gasInOptions
        } else {
            return nil
        }
        
        var gasPrice: BigUInt
        if let gasPriceInOptions = mergedOptions?.gasPrice {
            gasPrice = gasPriceInOptions
        } else {
            return nil
        }
        
        var value: BigUInt
        if let valueInOptions = mergedOptions?.value {
            value = valueInOptions
        } else {
            value = BigUInt(0)
        }
        guard let constructor = self.constructor else { return nil }
        guard let encodedData = constructor.encodeParameters(parameters) else { return nil }
        var fullData = bytecode
        if encodedData != Data() {
            fullData.append(encodedData)
        } else if extraData != Data() {
            fullData.append(extraData)
        }

        return EthereumTransaction(gasPrice: gasPrice, gasLimit: gasLimit, to: to, value: value, data: fullData)
    }
    
    public func method(_ method: String = "fallback", parameters: [AnyObject] = [AnyObject](), extraData: Data = Data(), options: Web3Options?) -> EthereumTransaction? {
        var to: EthereumAddress
        let mergedOptions = Web3Options.merge(self.options, with: options)
        if self.address != nil {
            to = self.address!
        } else if let toFound = mergedOptions?.to, toFound.isValid {
            to = toFound
        } else {
            return nil
        }
        
        var gasLimit: BigUInt
        if let gasInOptions = mergedOptions?.gasLimit {
            gasLimit = gasInOptions
        } else {
            return nil
        }
        
        var gasPrice: BigUInt
        if let gasPriceInOptions = mergedOptions?.gasPrice {
            gasPrice = gasPriceInOptions
        } else {
            return nil
        }
        
        var value: BigUInt
        if let valueInOptions = mergedOptions?.value {
            value = valueInOptions
        } else {
            value = BigUInt(0)
        }
        
        if method == "fallback" {
            return EthereumTransaction(gasPrice: gasPrice, gasLimit: gasLimit, to: to, value: value, data: extraData)
        }
        let foundMethod = self.methods.filter { $0.key == method }
        guard foundMethod.count == 1 else { return nil }
        let abiMethod = foundMethod[method]
        guard let encodedData = abiMethod?.encodeParameters(parameters) else { return nil }

        return EthereumTransaction(gasPrice: gasPrice, gasLimit: gasLimit, to: to, value: value, data: encodedData)
    }
    
    public func parseEvent(_ eventLog: EventLog) -> (eventName: String?, eventData: [String: Any]?) {
        for (eName, ev) in self.events {
            guard let parsed = ev.decodeReturnedLogs(eventLog) else { continue }
            return (eName, parsed)
        }
        
        return (nil, nil)
    }
    
    public func decodeReturnData(_ method: String, data: Data) -> [String: Any]? {
        guard method != "fallback" else { return [:] }
        guard let function = methods[method] else { return nil }
        guard case .function = function else { return nil }
        return function.decodeReturnData(data)
    }
    
    public func testBloomForEventPrecence(eventName: String, bloom: EthereumBloomFilter) -> Bool? {
        return false
    }
    
    public func decodeInputData(_ method: String, data: Data) -> [String: Any]? {
        return nil
    }
    
    public func decodeInputData(_ data: Data) -> [String: Any]? {
        return nil
    }
}
