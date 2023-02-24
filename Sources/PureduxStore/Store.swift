//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2021.
//

import Foundation

public struct Store<State, Action> {
    /**
     Closure that handles Store's dispatching Actions
    */
    public typealias Dispatch = (_ action: Action) -> Void

    /**
     Closure that takes Observer as a parameter and handles Store's subscribtions
    */
    public typealias Subscribe = (_ observer: Observer<State>) -> Void

    private let dispatch: (_ action: Action) -> Void

    private let subscribe: (_ observer: Observer<State>) -> Void

    public func dispatch(_ action: Action) {
        dispatch(action)
    }

    public func subscribe(observer: Observer<State>) {
        subscribe(observer)
    }

    /**
     Initializes a new light-weight Store

     - Parameter dispatch: Closure that handles Store's dispatching Actions
     - Parameter subscribe: Closure that handles Store's subscription
     - Returns: Light-weight Store

     Generally, Store has no reason to be Initialized directly with this initializer
     unless you want to mock the Store completely or provide your own implementation.

     For all other cases, RootStore or StoreFactory should be used to create viable light-weight Store.
     */
    public init(dispatch: @escaping Dispatch,
                subscribe: @escaping Subscribe) {
        self.dispatch = dispatch
        self.subscribe = subscribe
    }
}

public extension Store {
    /**
     Initializes a new light-weight proxy Store with state mapping to local substate.

     - Returns: Light-weight Store with local substate

     Store is a light-weight proxy for the private internal stores.
     All dispatched Actions and subscribtions are forwarded to the private internal store.
     Store is thread safe. Actions can be dispatched from any thread. Can be subscribed from any thread.

     */

    func proxy<LocalState>(_ toLocalState: @escaping (State) -> LocalState) -> Store<LocalState, Action> {
        optionalProxy(toLocalState)
    }
}


extension Store {
    func optionalProxy<LocalState>(_ toLocalState: @escaping (State) -> LocalState?) -> Store<LocalState, Action> {
        Store<LocalState, Action>(
            dispatch: dispatch,
            subscribe: { localStateObserver in
                subscribe(observer: Observer<State>(id: localStateObserver.id) { state, complete in
                    guard let localState = toLocalState(state) else {
                        complete(.active)
                        return
                    }

                    localStateObserver.send(localState, complete: complete)
                })
            })
    }
}
