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
    private let dispatch: Dispatch
    private let subscribe: Subscribe

    public func dispatch(_ action: Action) {
        dispatch(action)
    }

    public func subscribe(observer: Observer<State>) {
        subscribe(observer)
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
    public init(dispatch: @escaping Dispatch,
                subscribe: @escaping Subscribe) {
        self.dispatch = dispatch
        self.subscribe = subscribe
    }
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
        scope(to: toLocalState)
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
        Store<LocalState, Action>(
            dispatch: dispatch,
            subscribe: { localStateObserver in
                subscribe(observer: Observer<State>(id: localStateObserver.id) { state, complete in
                    guard let localState = localState(state) else {
                        complete(.active)
                        return
                    }

                    localStateObserver.send(localState, complete: complete)
                })
            })
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
    ///
    func scope<LocalState>(to localState: @escaping (State) -> LocalState) -> Store<LocalState, Action> {
        Store<LocalState, Action>(
            dispatch: dispatch,
            subscribe: { localStateObserver in
                subscribe(observer: Observer<State>(id: localStateObserver.id) { state, complete in
                    let localState = localState(state)
                    localStateObserver.send(localState, complete: complete)
                })
            })
    }

}
