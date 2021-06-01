//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import UIKit
import Dispatch
import PureduxStore

struct Presenting<Store: StoreProtocol, ViewController> where ViewController: PresentableViewController {
    private let mainQueue = DispatchQueue.main
    private let workerQueue = DispatchQueue(label: "com.puredux.presenter",
                                            qos: .userInteractive)

    private weak var viewController: ViewController?
    private let store: Store

    private let props: (_ state: Store.AppState, _ store: Store) -> ViewController.Props

    init(viewController: ViewController,
         store: Store,
         props: @escaping (Store.AppState, Store) -> ViewController.Props) {

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
    var asObserver: Observer<Store.AppState> {
        Observer { state, handler in
            observe(state: state, complete: handler)
        }
    }

    func observe(state: Store.AppState, complete: @escaping (ObserverStatus) -> Void) {
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
