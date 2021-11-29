//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import UIKit
import Dispatch
import PureduxStore

struct Presenting<Store, ViewController> where ViewController: PresentableViewController,
                                                              Store: StoreProtocol {
    private let mainQueue = DispatchQueue.main
    private let workerQueue = DispatchQueue(label: "com.puredux.presenter",
                                            qos: .userInteractive)

    private weak var viewController: ViewController?
    private let store: Store

    private let prevState: Ref<Store.AppState?> = Ref(value: nil)

    private let props: (_ state: Store.AppState, _ store: Store) -> ViewController.Props
    private let isEqual: (Store.AppState, Store.AppState) -> Bool

    init(viewController: ViewController,
         store: Store,
         props: @escaping (Store.AppState, Store) -> ViewController.Props,
         distinctStateChangesBy isEqual: @escaping (Store.AppState, Store.AppState) -> Bool) {

        self.viewController = viewController
        self.store = store
        self.props = props
        self.isEqual = isEqual
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
            if isPrevStateEqualTo(state) {
                complete(.active)
                return
            }

            prevState.value = state
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

private extension Presenting {
    func isPrevStateEqualTo(_ state: Store.AppState) -> Bool {
        guard let prevState = prevState.value else {
            return false
        }

        return isEqual(prevState, state)
    }
}

private extension Presenting {
    final class Ref<T> {
        var value: T

        init(value: T) {
            self.value = value
        }
    }
}
