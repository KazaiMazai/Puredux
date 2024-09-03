//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 16.02.2023.
//

import Foundation
/*
@available(*, deprecated, message: "Use StateStore directly")
public final class StateStore<State, Action> {
    let rootStateStore: StateStore<State, Action>

    /// Initializes a new StoreFactory with provided initial state, actions interceptor, qos, and reducer
    ///
    /// - Parameter initialState: The initial state for the store
    /// - Parameter interceptor: Interceptor's closure that takes action and dispatch function as parameters.
    /// Interceptor is called right before Reducer on the same DispatchQueue that Store operates on.
    /// - Parameter qos: defines the DispatchQueue QoS that reducer will be performed on
    /// - Parameter reducer: The function that is called on every dispatched Action and performs state mutations
    ///
    /// - Returns: `StoreFactory<State, Action>`
    ///
    /// StoreFactory is a factory for Store.
    /// It suppports the following store types:
    /// - Root Store - plain root store of the factory
    /// - Scope Store - scoped store proxy to the root store
    /// - Child Store - child store with `(Root, Local) -> Composition` state mapping and it's own lifecycle
    ///
    @available(*, deprecated, message: "Use StateStore(init:) directly")
    public init(initialState: State,
                interceptor: @escaping (Action, @escaping Dispatch<Action>) -> Void = { _, _ in },
                qos: DispatchQoS = .userInteractive,
                reducer: @escaping Reducer<State, Action>) {

        rootStateStore = StateStore(
            initialState,
            interceptor: interceptor,
            qos: qos,
            reducer: reducer)
    }
}

public extension StateStore {

    /// Initializes a new Store as a proxy to internal factory root store.
    ///
    /// - Returns: Store
    ///
    /// Store is a proxy for the factory root store.
    /// All dispatched Actions and subscribtions are forwarded to the factory root store object.
    /// Store is thread safe. Actions can be dispatched from any thread. Can be subscribed from any thread.
    @available(*, deprecated, message: "Use StateStore's store() method instead")
    func rootStore() -> Store<State, Action> {
        rootStateStore.weakStore()
    }

    /// Initializes a new Store with state mapping to local substate.
    ///
    /// - Returns: Store with local substate
    ///
    /// Store is a proxy for the root store object.
    /// All dispatched Actions and subscribtions are forwarded to the root store.
    /// Store is thread safe. Actions can be dispatched from any thread. Can be subscribed from any thread.
    @available(*, deprecated, message: "Use store's scope(to:) method instead")
    func scopeStore<LocalState>(to localState: @escaping (State) -> LocalState) -> Store<LocalState, Action> {
        rootStateStore.weakStore().scope(to: localState)
    }

    /// Initializes a new child StateStore with initial state
    ///
    /// - Returns: Child StateStore
    ///
    /// ChildStore is a composition of root store and newly created local store.
    /// Local state is a mapping of the child state and root store's state.
    ///
    /// ChildStore's lifecycle along with its Child's State is determined by StateStore's lifecycle.
    ///
    /// RootStore vs ChildStore Action Dispatch
    ///
    /// When action is dispatched to RootStore:
    /// - action is delivered to root store's reducer
    /// - action is not delivered to child store's reducer
    /// - root state update triggers root store's subscribers
    /// - root state update triggers child stores' subscribers
    /// - Interceptor dispatches additional actions to RootStore
    ///
    /// When action is dispatched to ChildStore:
    /// - action is delivered to root store's reducer
    /// - action is delivered to child store's reducer
    /// - root state update triggers root store's subscribers.
    /// - root state update triggers child store's subscribers.
    /// - local state update triggers child stores' subscribers.
    /// - Interceptor dispatches additional actions to ChildStore
    ///
    @available(*, deprecated, message: "Use StateStore's stateStore(...) method instead")
    func childStore<ChildState, LocalState>(
        initialState: ChildState,
        stateMapping: @escaping (State, ChildState) -> LocalState,
        qos: DispatchQoS = .userInteractive,
        reducer: @escaping Reducer<ChildState, Action>) ->

    StateStore<LocalState, Action> {

        rootStateStore.stateStore(
            initialState,
            stateMapping: stateMapping,
            qos: qos,
            reducer: reducer
        )
    }

    /// Initializes a new child StateStore with initial state
    ///
    /// - Returns: Child StateStore
    ///
    /// ChildStore is a composition of root store and newly created local store.
    /// Local state is a mapping of the child state and root store's state.
    ///
    /// ChildStore's lifecycle along with its Child's State is determined by StateStore's lifecycle.
    ///
    /// RootStore vs ChildStore Action Dispatch
    ///
    /// When action is dispatched to RootStore:
    /// - action is delivered to root store's reducer
    /// - action is not delivered to child store's reducer
    /// - additional interceptor produced actions would be dispatched to root store
    /// - root state update triggers root store's subscribers
    /// - root state update triggers child stores' subscribers
    /// - Interceptor dispatches additional actions to RootStore
    ///
    /// When action is dispatched to ChildStore:
    /// - action is delivered to root store's reducer
    /// - action is delivered to child store's reducer
    /// - root state update triggers root store's subscribers.
    /// - root state update triggers child store's subscribers.
    /// - local state update triggers child stores' subscribers.
    /// - Interceptor dispatches additional actions to ChildStore
    ///
    @available(*, deprecated, message: "Use StateStore's stateStore(...) method instead")
    func childStore<ChildState>(
        initialState: ChildState,
        qos: DispatchQoS = .userInteractive,
        reducer: @escaping Reducer<ChildState, Action>) -> StateStore<(State, ChildState), Action> {

            childStore(initialState: initialState,
                       stateMapping: { state, childState in (state, childState) },
                       qos: qos,
                       reducer: reducer)

        }
}
*/
