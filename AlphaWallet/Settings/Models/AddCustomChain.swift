// Copyright © 2021 Stormbird PTE. LTD.

import Foundation
import APIKit
import JSONRPCKit
import PromiseKit

protocol AddCustomChainDelegate: class {
    func notifyAddCustomChainSucceeded(in addCustomChain: AddCustomChain)
    func notifyAddCustomChainFailed(error: DAppError, in addCustomChain: AddCustomChain)
}

class AddCustomChain {
    private let customChain: WalletAddEthereumChainObject
    weak var delegate: AddCustomChainDelegate?

    init(_ customChain: WalletAddEthereumChainObject) {
        self.customChain = customChain
    }

    func run() {
        firstly {
            checkChain(customChain)
        }.then {
            self.addCustomChain(self.customChain)
        }.done {
            self.informDappCustomChainAddedSuccessfully()
        }.catch {
            if let error = $0 as? DAppError {
                NSLog("xxx error. Maybe when checking custom chain? So can't check. DAppError: \(error)")
                self.informDappCustomChainAddingFailed(error)
            } else {
                NSLog("xxx error. Maybe when checking custom chain? So can't check. Not DAppError, make up something")
                self.informDappCustomChainAddingFailed(.nodeError("Uknown Error"))
            }
        }
    }

    private func addCustomChain(_ customChain: WalletAddEthereumChainObject) -> Promise<Void> {
        Promise { seal in
            NSLog("xxx handle walletAddEthereumChain, show UI etc")
            //hhh3 figure out etherscanCompatibleType
            //hhh3 ask about isTestNet too
            guard let chainId = Int(chainId0xString: customChain.chainId) else {
                NSLog("xxx chain from dapp is wrong: \(customChain.chainId)")
                //hhh localize
                throw DAppError.nodeError("Invalid chainId provided: \(customChain.chainId)")
            }
            guard let rpcUrl = customChain.rpcUrls?.first else {
                //Not to spec since RPC URLs are optional according to EIP3085, but it is so much easier to assume it's needed, and quite useless if it isn't provided
                NSLog("xxx no RPC node provided by dapp")
                //hhh localize
                throw DAppError.nodeError("No RPC node URL provided")
            }

            let customRpc = CustomRPC(chainID: chainId, nativeCryptoTokenName: customChain.nativeCurrency?.name, chainName: customChain.chainName ?? "Unknown", symbol: customChain.nativeCurrency?.symbol, rpcEndpoint: rpcUrl, explorerEndpoint: customChain.blockExplorerUrls?.first, etherscanCompatibleType: .blockscout, isTestNet: false)
            RPCServer.servers.append(RPCServer.custom(customRpc))
            NSLog("xxx servers now: \(RPCServer.servers)")
        }
    }

    private func informDappCustomChainAddedSuccessfully() {
        delegate?.notifyAddCustomChainSucceeded(in: self)
    }

    private func informDappCustomChainAddingFailed(_ error: DAppError) {
        delegate?.notifyAddCustomChainFailed(error: error, in: self)
    }

    private func checkChain(_ customChain: WalletAddEthereumChainObject) -> Promise<Void> {
        Promise { seal in
            guard let chainId = Int(chainId0xString: customChain.chainId) else {
                NSLog("xxx chain from dapp is wrong: \(customChain.chainId)")
                //hhh localize
                throw DAppError.nodeError("Invalid chainId provided: \(customChain.chainId)")
            }
            guard let rpcUrl = customChain.rpcUrls?.first else {
                //Not to spec since RPC URLs are optional according to EIP3085, but it is so much easier to assume it's needed, and quite useless if it isn't provided
                NSLog("xxx no RPC node provided by dapp")
                //hhh localize
                throw DAppError.nodeError("No RPC node URL provided")
            }

            let customRpc = CustomRPC(chainID: chainId, nativeCryptoTokenName: customChain.nativeCurrency?.name, chainName: customChain.chainName ?? "Unknown", symbol: customChain.nativeCurrency?.symbol, rpcEndpoint: rpcUrl, explorerEndpoint: customChain.blockExplorerUrls?.first, etherscanCompatibleType: .blockscout, isTestNet: false)
            let server = RPCServer.custom(customRpc)
            let request = EthChainIdRequest()
            firstly {
                Session.send(EtherServiceRequest(server: server, batch: BatchFactory().create(request)))
            }.done { result in
                if let retrievedChainId = Int(chainId0xString: result), retrievedChainId == chainId {
                    NSLog("xxx promise result: \(result) type: \(type(of: result)) matches: \(chainId)")
                    seal.fulfill(())
                } else {
                    NSLog("xxx promise result: \(result) type: \(type(of: result)) NOT match: \(chainId)")
                    throw DAppError.nodeError("chainIds do not match: \(result) vs. \(customChain.chainId)")
                }
                //hhh1 clean up. Since we already have a promise chain
            }.catch {
                NSLog("xxx promise error: \($0)")
                seal.reject($0)
            }
        }
    }
}

//hhh move
extension Int {
    //We'll take both "0x12" and "18" as `18`. The former is as spec like https://eips.ethereum.org/EIPS/eip-695, the latter to be more forgiving of dapps
    init?(chainId0xString string: String) {
        if string.has0xPrefix {
            if let i = Int(string) {
                self = i
            } else {
                return nil
            }
        } else {
            if let i = Int(string.drop0x, radix: 16) {
                self = i
            } else {
                return nil
            }
        }
    }
}