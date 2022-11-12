//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2021.
//

import Foundation

public enum StoreQueue {
    case main
    case global(qos: DispatchQoS = .userInteractive)
}
 
public typealias Reducer<State, Action> = (inout State, Action) -> Void

public final class RootStore<State, Action> {
    private let internalStore: InternalStore<State, Action>

    /**
    Initializes a new RootStore with provided queue, initial state and reducer

    - Parameter queue: StoreQueue that defines the DispatchQueue that reducer will be performed on
    - Parameter initialState: The initial state for the store
    - Parameter reducer: The function that is called on every dispatched Action and performs state mutations

    - Returns: `RootStore<State, Action>`

    RootStore does not behave like a store.
    It acts like a factory for light-weight stores that are created as proxies for the internal store.

     */
    public init(queue: StoreQueue = .global(qos: .userInteractive),
                initialState: State,
                reducer: @escaping Reducer<State, Action>) {

        internalStore = InternalStore(
            queue: queue,
            initial: initialState,
            reducer: reducer)
    }
}

public extension RootStore {
    /**
     Initializes a new light-weight proxy Store as a proxy for the RootStore's internal store

     - Returns: Light-weight Store

     Store is a light-weight proxy for the RootStore's private internal store.
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
    Set Store's Actions interceptor

    - Parameter interceptor: interceptor's closure that takes action as a parameter

    Interceptor is called right before Reducer on the same DispatchQueue that Store operates on.

     */
    func interceptActions(with interceptor: @escaping (Action) -> Void ) {
        internalStore.setInterceptor { action, _ in
            interceptor(action)
        }
    }
}

