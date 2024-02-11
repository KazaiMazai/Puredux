//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 24.02.2023.
//

import Foundation

public extension StoreObject {

    /// Closure that handles Store's dispatching Actions
    ///
    typealias Dispatch = (_ action: Action) -> Void

    /// Closure that takes Observer as a parameter and handles Store's subscribtions
    ///
    typealias Subscribe = (_ observer: Observer<State>) -> Void
}

public class StoreObject<State, Action> {
    private let dispatch: Dispatch
    private let subscribe: Subscribe

    public func dispatch(_ action: Action) {
        dispatch(action)
    }

    public func subscribe(observer: Observer<State>) {
        subscribe(observer)
    }

    /// Initializes a new StoreObject
    ///
    /// - Parameter dispatch: Closure that handles Store's dispatching Actions
    /// - Parameter subscribe: Closure that handles Store's subscription
    /// - Returns: StoreObject
    ///
    /// Generally, StoreObject has no reason to be Initialized directly with this initializer
    /// unless you want to mock the StoreObject completely or provide your own implementation.
    ///
    /// For all other cases, StoreFactory should be used to create viable StoreObject.
    /// StoreObject is thread safe. Actions can be dispatched from any thread. Can be subscribed from any thread.
    ///
    public init(dispatch: @escaping Dispatch,
                subscribe: @escaping Subscribe) {
        self.dispatch = dispatch
        self.subscribe = subscribe
    }
}

public extension StoreObject {

    /// Initializes a new scope Store with state mapping to local substate.
    ///
    /// - Returns: Store with local substate
    ///
    /// Store is a proxy store.
    /// All dispatched Actions and subscribtions are forwarded to the root store.
    /// Store is thread safe. Actions can be dispatched from any thread. Can be subscribed from any thread.
    /// When the result local state is nill, subscribers are not triggered.
    ///
    /// **Important to note:** Store only keeps weak reference to the StoreObject,
    /// ensuring that reference cycles will not be created.
    ///
    func scope<LocalState>(_ toLocalState: @escaping (State) -> LocalState?) -> Store<LocalState, Action> {
        Store<LocalState, Action>(
            dispatch: { [weak self] in self?.dispatch($0) },
            subscribe: { [weak self] localStateObserver in
                self?.subscribe(observer: Observer<State>(id: localStateObserver.id) { state, complete in
                    guard let localState = toLocalState(state) else {
                        complete(.active)
                        return
                    }

                    localStateObserver.send(localState, complete: complete)
                })
            }
        )
    }

    /// Initializes a new Store.
    ///
    /// - Returns: Store
    ///
    /// Store is a proxy for the root store object.
    /// All dispatched Actions and subscribtions are forwarded to the root store object.
    /// Store is thread safe. Actions can be dispatched from any thread. Can be subscribed from any thread.
    ///
    /// **Important to note:** Store only keeps weak reference to the StoreObject,
    /// ensuring that reference cycles will not be created.
    ///
    ///
    func store() -> Store<State, Action> {
        Store(dispatch: { [weak self] in self?.dispatch($0) },
              subscribe: { [weak self] in self?.subscribe(observer: $0) }
        )
    }
}
