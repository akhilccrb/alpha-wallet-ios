//
//  CheckTransactionStateViewModel.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 07.03.2022.
//

import Foundation
import PromiseKit
import AlphaWalletFoundation
import AlphaWalletWeb3

struct CheckTransactionStateViewModel {
    private let serverSelection: ServerSelection
    private let configuration = TransactionConfirmationHeaderView.Configuration(section: 0)

    let textFieldPlaceholder: String = R.string.localizable.checkTransactionStateFieldHashPlaceholder()

    var serverSelectionViewModel: TransactionConfirmationHeaderViewModel {
        return .init(title: .normal(selectedServerString), headerName: serverViewTitle, configuration: configuration)
    }

    let title: String = R.string.localizable.checkTransactionStateTitle()
    var actionButtonTitle: String { return R.string.localizable.checkTransactionStateActionButtonTitle() }
    var serverViewTitle: String { return R.string.localizable.checkTransactionStateFieldServerTitle() }

    var selectedServerString: String {
        switch serverSelection {
        case .server(let serverOrAuto):
            switch serverOrAuto {
            case .server(let server):
                return server.name
            case .auto:
                return ""
            }
        case .multipleServers:
            return ""
        }
    }

    init(serverSelection: ServerSelection) {
        self.serverSelection = serverSelection
    }

}

extension AlphaWalletWeb3.Web3Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .connectionError: return "Connection Error"
        case .inputError(let e): return e
        case .nodeError(let e): return e
        case .generalError(let e): return e.localizedDescription
        case .rateLimited: return "Rate limited"
        case .responseError(let e): return e.localizedDescription
        }
    }
}
extension UndefinedError {
    public var localizedDescription: String {
        R.string.localizable.undefinedError()
    }
}

extension UnknownError {
    public var localizedDescription: String {
        R.string.localizable.unknownError()
    }
}
