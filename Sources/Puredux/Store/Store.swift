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

typealias AnyStoreObjectProtocol = AnyObject

public struct Store<State, Action> {
    let dispatchHandler: Dispatch
    let subscribeHandler: Subscribe
    let getStoreObject: () -> AnyStoreObjectProtocol?
}

public extension Store {
    func dispatch(_ action: Action) {
        dispatchHandler(action)
        executeAsyncAction(action)
    }

    func subscribe(observer: Observer<State>) {
        subscribeHandler(observer)
    }

    /// Initializes a new light-weight Store
    ///
    /// - Parameter dispatch: Closure that handles Store's dispatching Actions
    /// - Parameter subscribe: Closure that handles Store's subscription
    /// - Returns: Light-weight Store
    ///
    /// Generally, Store has no reason to be Initialized directly with this initializer
    /// unless you want to mock the Store completely or provide your own implementation.
    ///
    /// For all other cases, RootStore or StoreFactory should be used to create viable light-weight Store.
    ///
    ///
    @available(*, deprecated, renamed: "Store.mockStore(dispatch:subscribe:)", message: "Will be removed in the next major release")
    init(dispatch: @escaping Dispatch,
         subscribe: @escaping Subscribe) {
        self.init(dispatcher: dispatch, subscribe: subscribe, storeObject: { nil })
    }

    /// Initializes a mock Store
    ///
    /// - Parameter dispatch: Closure that handles Store's dispatching Actions
    /// - Parameter subscribe: Closure that handles Store's subscription
    /// - Returns: Store
    ///
    /// Generally, Store has no reason to be Initialized this way
    /// unless you want to mock the Store completely.
    ///
    /// For all other cases, RootStore or StoreFactory should be used to create viable light-weight Store.
    ///
    ///
    static func mockStore(
        dispatch: @escaping Dispatch,
        subscribe: @escaping Subscribe) -> Store<State, Action> {

            Store(
                dispatcher: dispatch,
                subscribe: subscribe,
                storeObject: { nil }
            )
    }
}
                         
extension Store: StoreProtocol {
    public typealias State = State
    public typealias Action = Action
    
    public var instance: Store<State, Action> { self }
}

public extension Store {

    /// Initializes a new scope Store with state mapping to local substate.
    ///
    /// - Returns: Store with local substate
    ///
    /// Store is a proxy store.
    /// All dispatched Actions and subscribtions are forwarded to the root store.
    /// Store is thread safe. Actions can be dispatched from any thread. Can be subscribed from any thread.
    ///
    @available(*, deprecated, message: "Will be removed in the next major release. Consider migrating to scope(...)")
    func proxy<LocalState>(_ toLocalState: @escaping (State) -> LocalState) -> Store<LocalState, Action> {
        map(toLocalState)
    }
}

public extension Store {

    /// Initializes a new scope Store with state mapping to local substate.
    ///
    /// - Returns: Store with local substate
    ///
    /// Store is a proxy for the root store.
    /// All dispatched Actions and subscribtions are forwarded to the root store.
    /// Store is thread safe. Actions can be dispatched from any thread. Can be subscribed from any thread.
    /// When the result local state is nill, subscribers are not triggered.
    ///
    ///
    func scope<LocalState>(toOptional localState: @escaping (State) -> LocalState?) -> Store<LocalState, Action> {
        compactMap(localState)
    }

    /// Initializes a new scope Store with state mapping to local substate.
    ///
    /// - Returns: Store with local substate
    ///
    /// Store is a proxy for the root store.
    /// All dispatched Actions and subscribtions are forwarded to the root store.
    /// Store is thread safe. Actions can be dispatched from any thread. Can be subscribed from any thread.
    /// When the result local state is nill, subscribers are not triggered.
    ///
    func scope<LocalState>(to localState: @escaping (State) -> LocalState) -> Store<LocalState, Action> {
        map(localState)
    }
}

extension Store {
    init(dispatcher: @escaping Dispatch,
         subscribe: @escaping Subscribe,
         storeObject: @escaping () -> AnyStoreObjectProtocol?) {

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
