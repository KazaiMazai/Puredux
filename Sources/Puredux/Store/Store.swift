//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02.12.2021.
//

import Foundation

public extension Store {

    /// Closure that handles Store's dispatching Actions
    ///
    typealias Dispatch = (_ action: Action) -> Void

    /// Closure that takes Observer as a parameter and handles Store's subscribtions
    ///
    typealias Subscribe = (_ observer: Observer<State>) -> Void
}

public struct Store<State, Action> {
    let dispatchHandler: Dispatch
    let subscribeHandler: Subscribe
    let getStoreObject: () -> AnyStoreObject<State, Action>?
}

public extension Store {
    func dispatch(_ action: Action) {
        dispatchHandler(action)
        executeAsyncAction(action)
    }

    func subscribe(observer: Observer<State>) {
        subscribeHandler(observer)
    }
}

extension Store: StoreProtocol {
    public typealias State = State
    public typealias Action = Action

    public func eraseToAnyStore() -> Store<State, Action> { self }
}

extension Store {
    init(dispatcher: @escaping Dispatch,
         subscribe: @escaping Subscribe,
         storeObject: @escaping () -> AnyStoreObject<State, Action>?) {

        dispatchHandler = { dispatcher($0) }
        subscribeHandler = { subscribe($0) }
        getStoreObject = storeObject
    }

    func weakStore() -> Store<State, Action> {
        let storeObject = getStoreObject()
        return Store<State, Action>(
            dispatcher: dispatchHandler,
            subscribe: subscribeHandler,
            storeObject: { [weak storeObject] in storeObject }
        )
    }
}

extension Store {
    func executeAsyncAction(_ action: Action) {
        guard let action = action as? (any AsyncAction) else {
            return
        }

        action.execute(self.dispatchHandler)
    }
}
