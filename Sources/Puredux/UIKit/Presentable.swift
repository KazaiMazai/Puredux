//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import Dispatch

public protocol PresenterProtocol {
    func subscribeToStore()
}

public protocol Presentable: AnyObject {
    associatedtype Props

    var presenter: PresenterProtocol? { get set }

    func setProps(_ props: Props)
}

public extension Presentable {
    func with<State, Action>(store: StateStore<State, Action>,
                             props: @escaping (State, Store<State, Action>) -> Self.Props,
                             presentationQueue: PresentationQueue = .sharedPresentationQueue,
                             removeStateDuplicates equating: Equating<State>? = nil) {

        let weakRefStore = store.weakStore()
        let observer = Observer(
            self,
            removeStateDuplicates: equating,
            observe: { [weak self] state, complete in
                presentationQueue.dispatchQueue.async {
                    let props = props(state, weakRefStore)

                    PresentationQueue.main.dispatchQueue.async { [weak self] in
                        self?.setProps(props)
                        complete(.active)
                    }
                }
            }
        )

        presenter = Presenter { store.subscribe(observer: observer) }
    }

    func with<State, Action>(store: Store<State, Action>,
                             props: @escaping (State, Store<State, Action>) -> Self.Props,
                             presentationQueue: PresentationQueue = .sharedPresentationQueue,
                             removeStateDuplicates equating: Equating<State>? = nil) {

        let observer = Observer(
            self,
            removeStateDuplicates: equating,
            observe: { [weak self] state, complete in
                presentationQueue.dispatchQueue.async {
                    let props = props(state, store)

                    PresentationQueue.main.dispatchQueue.async { [weak self] in
                        self?.setProps(props)
                        complete(.active)
                    }
                }
            }
        )

        presenter = Presenter { store.subscribe(observer: observer) }
    }
}

struct Presenter: PresenterProtocol {
    let subscribe: () -> Void

    func subscribeToStore() {
        subscribe()
    }
}

