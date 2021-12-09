//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 29.11.2021.
//

import UIKit
@testable import PureduxUIKit
@testable import PureduxStore

extension StubViewController {
    struct Props {
        let title: String
    }
}

class StubViewController: PresentableViewController {
    var presenter: PresenterProtocol?

    private(set) var props: Props?

    var didSetProps: (() -> Void)?

    func setProps(_ props: Props) {
        self.props = props
        didSetProps?()
    }

    func viewDidLoad() {
        presenter?.subscribeToStore()
    }
}
//
//class StubViewContollerPresenter<Action> {
//
//    typealias ViewController = StubViewController
//
//    var didMakeProps: (() -> Void)?
//
//    func props(state:TestVCState, store: Store<TestVCState, Action>) -> StubViewController.Props {
//        let props = StubViewController.Props(title: state.title)
//        didMakeProps?()
//        return props
//    }
//}
