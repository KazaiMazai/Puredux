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
    private let workerQueue = DispatchQueue(label: "com.puredux.presenter",
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
        store.subscribe(observer: asObserver)
    }
}

private extension Presenting {
    var asObserver: Observer<State> {
        Observer { state, handler in
            observe(state: state, complete: handler)
        }
    }

    func observe(state: State, complete: @escaping (Observer<State>.Status) -> Void) {
        workerQueue.async {
            let newProps = props(state, store)

            mainQueue.async { [weak viewController] in
                guard let viewController = viewController else {
                    complete(.dead)
                    return
                }

                viewController.setProps(newProps)
                complete(.active)
            }
        }
    }
}
