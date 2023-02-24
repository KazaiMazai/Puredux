//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 16.02.2023.
//

import Foundation

import Foundation

public final class StoreFactory<State, Action> {
    private let rootStore: RootStoreNode<State, Action>

    /**
    Initializes a new StoreFactory with provided initial state, actions interceptor, qos, and reducer

    - Parameter initialState: The initial state for the store
    - Parameter interceptor: Interceptor's closure that takes action as a parameter. Interceptor is called right before Reducer on the same DispatchQueue that Store operates on.
    - Parameter qos: defines the DispatchQueue QoS that reducer will be performed on
    - Parameter reducer: The function that is called on every dispatched Action and performs state mutations

    - Returns: `StoreFactory<State, Action>`

    StoreFactory is a factory for light-weight stores or detached stores.

     */
    public init(initialState: State,
                interceptor: @escaping (Action, @escaping Dispatch<Action>) -> Void = { _, _ in },
                qos: DispatchQoS = .userInteractive,
                reducer: @escaping Reducer<State, Action>) {

        rootStore = RootStoreNode.initRootStore(
            initialState: initialState,
            interceptor: interceptor,
            qos: qos,
            reducer: reducer)
    }
}

public extension StoreFactory {
    /**
     Initializes a new light-weight proxy Store as a proxy for the StoreFactory's internal store

     - Returns: Light-weight Store

     Store is a light-weight proxy for the StoreFactory's private internal store.
     All dispatched Actions and subscribtions are forwarded to the private internal store.
     Store is thread safe. Actions can be dispatched from any thread. Can be subscribed from any thread.

     */
    func store() -> Store<State, Action> {
        rootStore.weakRefStore()
    }

    /**
     Initializes a new light-weight scoped Store as a proxy for the root store

     - Parameter toLocalState: Mapping of the root state to local state

     - Returns: Light-weight Store

     Store is a light-weight proxy for the root store.
     All dispatched Actions and subscribtions are forwarded to the root store.
     Store is thread safe. Actions can be dispatched from any thread. Can be subscribed from any thread.


     */
    func scopeStore<LocalState>(_ toLocalState: @escaping (State) -> LocalState) -> Store<LocalState, Action> {
        rootStore.weakRefStore().proxy(toLocalState)
    }

    /**
     Initializes a new light-weight scoped Store as a proxy for the root store

     - Parameter toLocalState: Mapping of the root state to local state. If the state mappinng result is nil, observers won't be triggered.

     - Returns: Light-weight Store

     Store is a light-weight proxy for the root store.
     All dispatched Actions and subscribtions are forwarded to the root store.
     Store is thread safe. Actions can be dispatched from any thread.

     */
    func scopeStore<LocalState>(_ toLocalState: @escaping (State) -> LocalState?) -> Store<LocalState, Action> {
        rootStore.weakRefStore().optionalProxy(toLocalState)
    }


    /**
     Initializes a new detached store with initial state

     - Returns: Detached Store

     DetachedStore is a composition of root store and newly created local store.
     Detached state is a mapping of the local state and root store's state.

     RootStore vs DetachedStore Dispatch

     When action is dispatched to RootStore:
     - action is delivered to root store's reducer
     - action is not delivered to detached store's reducer
     - additional interceptor produced actions would be dispatched to root store
     - root state update triggers root store's subscribers
     - root state update triggers detached stores' subscribers
     - Interceptor dispatches additional actions to RootStore

     When action is dispatched to DetachedStore:
     - action is delivered to root store's reducer
     - action is delivered to detached store's reducer
     - root state update triggers root store's subscribers.
     - root state update triggers detached store's subscribers.
     - local state update triggers detached stores' subscribers.
     - Interceptor dispatches additional actions to DetachedStore

     */
    func detachedStore<LocalState, DetachedState>(
        initialState: LocalState,
        stateMapping: @escaping (State, LocalState) -> DetachedState,
        qos: DispatchQoS = .userInteractive,
        reducer: @escaping Reducer<LocalState, Action>) ->

    Store<DetachedState, Action> {

        rootStore.createDetachedStore(
            initialState: initialState,
            stateMapping: stateMapping,
            qos: qos,
            reducer: reducer
        )
        .strongRefStore()
    }
}

