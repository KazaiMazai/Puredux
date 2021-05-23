//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import UIKit
import Dispatch
import PureduxStore

struct Presenting<State, Action, ViewController> where ViewController: PresentableViewController {
    private let mainQueue = DispatchQueue.main
    private let workerQueue = DispatchQueue(label: "PresenterQueue",
                                            qos: .userInteractive)

    private weak var viewController: ViewController?
    private let store: Store<State, Action>

    private let props: (_ state: State, _ store: Store<State, Action>) -> ViewController.Props

    init(viewController: ViewController,
         store: Store<State, Action>,
         props: @escaping (State, Store<State, Action>) -> ViewController.Props) {

        self.viewController = viewController
        self.store = store
        self.props = props
    }
}

extension Presenting: PresenterProtocol {
    func subscribeToStore() {
        observe(state: store.state)
        store.subscribe(observer: asObserver)
    }
}

private extension Presenting {
    var asObserver: Observer<State> {
        Observer { state in
            observe(state: state)
        }
    }

    @discardableResult func observe(state: State) -> Observer<State>.Status {
        guard let viewController = viewController else {
            return .dead
        }

        workerQueue.async {
            let newProps = props(state, store)

            mainQueue.async {
                viewController.setProps(newProps)
            }
        }

        return .active
    }
}
