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

    - Parameter qos: defines the DispatchQueue QoS that reducer will be performed on
    - Parameter initialState: The initial state for the store
    - Parameter interceptor: Interceptor's closure that takes action as a parameter. Interceptor is called right before Reducer on the same DispatchQueue that Store operates on.
    - Parameter reducer: The function that is called on every dispatched Action and performs state mutations

    - Returns: `StoreFactory<State, Action>`

    StoreFactory is factory for light-weight stores proxies or detached stores.

     */
    public init(initialState: State,
                interceptor: @escaping (Action, @escaping Dispatch<Action>) -> Void = { _, _ in },
                qos: DispatchQoS = .userInteractive,
                reducer: @escaping Reducer<State, Action>) {

        rootStore = RootStoreNode.root(
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
     Internal store is thread safe, the same as its proxies.

     **Important to note:** Proxy store only keeps weak reference to the internal store,
     ensuring that reference cycles will not be created.

     */
    func store() -> Store<State, Action> {
        Store(dispatch: { [weak rootStore] in rootStore?.dispatch($0) },
              subscribe: { [weak rootStore] in rootStore?.subscribe(observer: $0) })
    }

    /**
     Initializes a new detached store with initial state

     - Returns: Detached Store

     DetachedStore is a proxy for the StoreFactory store on the one hand.
     On another hand it's separate store with it's own state which is mapping of the local state and main store's state
     Dispatched Actions are forwarded both to main and local reducers
     Actions are intercepted once in a local store

     **Important to note:** Proxy store only keeps weak reference to the internal store,
     ensuring that reference cycles will not be created.

     */
    func detachedStore<LocalState, DetachedState>(initialState: LocalState,
                                                  stateMapping: @escaping (State, LocalState) -> DetachedState,
                                                  qos: DispatchQoS = .userInteractive,
                                                  reducer: @escaping Reducer<LocalState, Action>) -> Store<DetachedState, Action> {

        rootStore.node(initialState: initialState,
             stateMapping: stateMapping,
             qos: qos,
             reducer: reducer
        )
        .strongRefStore()
    }
}

