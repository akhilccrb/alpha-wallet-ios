// Copyright SIX DAY LLC. All rights reserved.
// Copyright © 2018 Stormbird PTE. LTD.

import UIKit

class LockCreatePasscodeViewController: LockPasscodeViewController {
    private let viewModel: LockCreatePasscodeViewModel

    init(lockCreatePasscodeViewModel: LockCreatePasscodeViewModel) {
        self.viewModel = lockCreatePasscodeViewModel
        super.init(model: lockCreatePasscodeViewModel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        lockView.lockTitle.text = viewModel.initialLabelText
    }

    override func enteredPasscode(_ passcode: String) {
        super.enteredPasscode(passcode)
        if let first = viewModel.firstPasscode {
            if passcode == first {
                viewModel.lock.setPasscode(passcode: passcode)
                finish(withResult: true, animated: true)
            } else {
                lockView.shake()
                viewModel.set(firstPasscode: nil)
                showFirstPasscodeView()
            }
        } else {
            viewModel.set(firstPasscode: passcode)
            showConfirmPasscodeView()
        }
    }

    private func showFirstPasscodeView() {
        lockView.lockTitle.text = viewModel.initialLabelText
    }

    private func showConfirmPasscodeView() {
        lockView.lockTitle.text = viewModel.confirmLabelText
    }
}
