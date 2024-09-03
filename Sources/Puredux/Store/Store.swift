//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02.12.2021.
//

import Foundation

public extension AnyStore {

    /// Closure that handles Store's dispatching Actions
    ///
    typealias Dispatch = (_ action: Action) -> Void

    /// Closure that takes Observer as a parameter and handles Store's subscribtions
    ///
    typealias Subscribe = (_ observer: Observer<State>) -> Void
}

public struct AnyStore<State, Action>: StoreProtocol {
    let dispatchHandler: Dispatch
    let subscribeHandler: Subscribe
    let getStoreObject: () -> AnyStoreObject<State, Action>?
    
    public func eraseToAnyStore() -> AnyStore<State, Action> { self }
}

public extension AnyStore {
    func dispatch(_ action: Action) {
        dispatchHandler(action)
        executeAsyncAction(action)
    }

    func subscribe(observer: Observer<State>) {
        subscribeHandler(observer)
    }
}

extension AnyStore {
    init(dispatcher: @escaping Dispatch,
         subscribe: @escaping Subscribe,
         storeObject: @escaping () -> AnyStoreObject<State, Action>?) {

        dispatchHandler = { dispatcher($0) }
        subscribeHandler = { subscribe($0) }
        getStoreObject = storeObject
    }

    func weakStore() -> AnyStore<State, Action> {
        let storeObject = getStoreObject()
        return AnyStore<State, Action>(
            dispatcher: dispatchHandler,
            subscribe: subscribeHandler,
            storeObject: { [weak storeObject] in storeObject }
        )
    }
}

extension AnyStore {
    func executeAsyncAction(_ action: Action) {
        guard let action = action as? (any AsyncAction) else {
            return
        }

        action.execute(self.dispatchHandler)
    }
}
