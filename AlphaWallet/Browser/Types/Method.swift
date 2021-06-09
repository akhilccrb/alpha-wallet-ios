// Copyright DApps Platform Inc. All rights reserved.

import Foundation

enum Method: String, Decodable {
    //case getAccounts
    case sendTransaction
    case signTransaction
    case signPersonalMessage
    case signMessage
    case signTypedMessage
    case ethCall
    //hhh2 might remove this, not in method here?
    //case walletAddEthereumChain
    case unknown

    init(string: String) {
        self = Method(rawValue: string) ?? .unknown
    }
}
