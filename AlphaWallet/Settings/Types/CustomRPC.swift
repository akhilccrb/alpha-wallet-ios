// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct CustomRPC: Hashable {
    let chainID: Int
    let nativeCryptoTokenName: String?
    let chainName: String
    let symbol: String?
    let rpcEndpoint: String
    let explorerEndpoint: String?
    let etherscanCompatibleType: RPCServer.EtherscanCompatibleType
    let isTestNet: Bool
}

//hhh move to WalletAddEthereumChainObject?
extension CustomRPC {
    init(customChain: WalletAddEthereumChainObject) {
        //hhh5 forced unwrap
        let chainId = Int(chainId0xString: customChain.chainId)!
        //hhh5 forced unwrap
        let rpcUrl = customChain.rpcUrls!.first!
        self.init(chainID: chainId, nativeCryptoTokenName: customChain.nativeCurrency?.name, chainName: customChain.chainName ?? "Unknown", symbol: customChain.nativeCurrency?.symbol, rpcEndpoint: rpcUrl, explorerEndpoint: customChain.blockExplorerUrls?.first, etherscanCompatibleType: .blockscout, isTestNet: false)
    }
}