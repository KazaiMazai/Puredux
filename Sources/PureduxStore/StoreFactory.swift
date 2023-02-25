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
     - Parameter interceptor: Interceptor's closure that takes action and dispatch function as parameters. Interceptor is called right before Reducer on the same DispatchQueue that Store operates on.
     - Parameter qos: defines the DispatchQueue QoS that reducer will be performed on
     - Parameter reducer: The function that is called on every dispatched Action and performs state mutations

     - Returns: `StoreFactory<State, Action>`

     StoreFactory is a factory for Store and StoreObjects.
     It suppports the following store types:
     - store - plain root store
     - scopeStore - scoped store proxy to the root store
     - detachedStore - detached store with `(Root, Local) -> Composition` state mapping and it's own lifecycle

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
     Initializes a new scope Store with state mapping to local substate.

     - Returns: Store with local substate

     Store is a proxy for the root store object.
     All dispatched Actions and subscribtions are forwarded to the root store object.
     Store is thread safe. Actions can be dispatched from any thread. Can be subscribed from any thread.
     */
    func store() -> Store<State, Action> {
        rootStore.store()
    }

    /**
     Initializes a new Store with state mapping to local substate.

     - Returns: Store with local substate

     Store is a proxy for the root store object.
     All dispatched Actions and subscribtions are forwarded to the root store object.
     Store is thread safe. Actions can be dispatched from any thread. Can be subscribed from any thread.
     When the result local state is nill, subscribers are not triggered.
     */
    func scopeStore<LocalState>(_ toLocalState: @escaping (State) -> LocalState?) -> Store<LocalState, Action> {
        rootStore.store().scope(toLocalState)
    }


    /**
     Initializes a new detached store with initial state

     - Returns: Detached StoreObject

     DetachedStore is a composition of root store and newly created local store.
     Detached state is a mapping of the local state and root store's state.

     DetachedStore's lifecycle along with its LocalState is determined by StoreObject's lifecycle.

     RootStore vs DetachedStore Action Dispatch

     When action is dispatched to RootStore:
     - action is delivered to root store's reducer
     - action is not delivered to detached store's reducer
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
    func childStore<LocalState, DetachedState>(
        initialState: LocalState,
        stateMapping: @escaping (State, LocalState) -> DetachedState,
        qos: DispatchQoS = .userInteractive,
        reducer: @escaping Reducer<LocalState, Action>) ->

    StoreObject<DetachedState, Action> {

        rootStore.createDetachedStore(
            initialState: initialState,
            stateMapping: stateMapping,
            qos: qos,
            reducer: reducer
        )
        .storeObject()
    }

    /**
     Initializes a new detached store with initial state

     - Returns: Detached StoreObject

     DetachedStore is a composition of root store and newly created local store.
     Detached state is a mapping of the local state and root store's state.

     DetachedStore's lifecycle along with its LocalState is determined by StoreObject's lifecycle.

     RootStore vs DetachedStore Action Dispatch

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
    func childStore<LocalState>(
        initialState: LocalState,
        qos: DispatchQoS = .userInteractive,
        reducer: @escaping Reducer<LocalState, Action>) -> StoreObject<(State, LocalState), Action> {

            childStore(initialState: initialState,
                       stateMapping: { state, localState in (state, localState) },
                       qos: qos,
                       reducer: reducer)

        }
}

