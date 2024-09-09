//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 29.11.2021.
//

@testable import Puredux

extension StubViewController {
    struct Props {
        let title: String
    }
}

final class StubViewController: Presentable, @unchecked Sendable {
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
