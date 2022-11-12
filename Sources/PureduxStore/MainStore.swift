//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 12.11.2022.
//

import Foundation

public final class MainStore<State, Action> {
    private let internalStore: InternalStore<State, Action>

    /**
    Initializes a new MainStore with provided queue, initial state and reducer

    - Parameter qos: defines the DispatchQueue QoS that reducer will be performed on
    - Parameter initialState: The initial state for the store
    - Parameter reducer: The function that is called on every dispatched Action and performs state mutations

    - Returns: `MainStore<State, Action>`

    MainStore is factory for light-weight stores proxies or detached stores.

     */
    public init(qos: DispatchQoS = .userInteractive,
                initialState: State,
                reducer: @escaping Reducer<State, Action>) {

        internalStore = InternalStore(
            queue: StoreQueue.global(qos: qos),
            initial: initialState,
            reducer: reducer)
    }
}

public extension MainStore {
    /**
     Initializes a new light-weight proxy Store as a proxy for the MainStore's internal store

     - Returns: Light-weight Store

     Store is a light-weight proxy for the MainStore's private internal store.
     All dispatched Actions and subscribtions are forwarded to the private internal store.
     Internal store is thread safe, the same as its proxies.

     **Important to note:** Proxy store only keeps weak reference to the internal store,
     ensuring that reference cycles will not be created.

     */
    func store() -> Store<State, Action> {
        Store(dispatch: { [weak internalStore] in internalStore?.dispatch($0) },
              subscribe: { [weak internalStore] in internalStore?.subscribe(observer: $0) })
    }

    /**
     Initializes a new detached store with initial state

     - Returns: Detached Store

     DetachedStore is a proxy for the MainStore store on the one hand.
     On another hand it's separate store with it's own state which is mapping of the local state and main store's state
     Dispatched Actions are forwarded both to main and local reducers
     Actions are intercepted once in a local store

     **Important to note:** Proxy store only keeps weak reference to the internal store,
     ensuring that reference cycles will not be created.

     */
    func detachedStore<LocalState, DetachedState>(initialState: LocalState,
                       stateMapping: @escaping (State, LocalState) -> DetachedState,
                       qos: DispatchQoS = .userInteractive,
                       reducer: @escaping Reducer<LocalState, Action>) -> DetachedStore<State, LocalState, DetachedState, Action> {

        DetachedStore(initialState: initialState,
                      stateMapping: stateMapping,
                      rootStore: internalStore,
                      reducer: reducer)
    }

    /**
    Set Store's Actions interceptor

    - Parameter interceptor: interceptor's closure that takes action as a parameter

    Interceptor is called right before Reducer on the same DispatchQueue that Store operates on.

     */
    func setInterceptor(_ interceptor: @escaping Interceptor<Action>) {
        internalStore.setInterceptor(with: interceptor)
    }
}


