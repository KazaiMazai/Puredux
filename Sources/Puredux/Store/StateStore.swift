//
//  File.swift
//
//
//  Created by Sergey Kazakov on 04/04/2024.
//

import Foundation

@available(*, deprecated, renamed: "StateStore", message: "Will be removed in the next major release. StateStore is a former StoreObject replacement")
public typealias StoreObject = StateStore

public struct StateStore<State, Action> {
    let storeObject: any StoreProtocol<State, Action>
    let currentStore: Store<State, Action>
    
    public func store() -> Store<State, Action> {
        currentStore
    }
    
    public func dispatch(_ action: Action) {
        currentStore.dispatch(action)
    }
    
    public func subscribe(observer: Observer<State>) {
        currentStore.subscribe(observer: observer)
    }
    
    init(storeObject: any StoreProtocol<State, Action>) {
        self.storeObject = storeObject
        self.currentStore = Store<State, Action>(
            dispatcher: { [weak storeObject] in storeObject?.dispatch($0) },
            subscribe: { [weak storeObject] in storeObject?.subscribe(observer: $0) }
        )
    }
}


public extension StateStore {
    /** Initializes a new StateStore with provided initial state, qos, and reducer
        - Parameter initialState: The initial state for the store
        - Parameter qos: defines the DispatchQueue QoS that reducer will be performed on
        - Parameter reducer: The function that is called on every dispatched Action and performs state mutations
        - Returns: `StateStore<State, Action>`
    */
    init(_ initialState: State,
         qos: DispatchQoS = .userInteractive,
         reducer: @escaping Reducer<State, Action>) {
        
        self.init(storeObject: RootStoreNode.initRootStore(
            initialState: initialState,
            interceptor: { _, _ in },
            qos: qos,
            reducer: reducer
        ))
    }
}

extension StateStore {
    func weakStore() -> Store<State, Action> {
       currentStore
    }
    
    func strongStore() -> Store<State, Action> {
        Store<State, Action>(
            dispatcher: { [storeObject] in storeObject.dispatch($0) },
            subscribe: { [storeObject] in storeObject.subscribe(observer: $0) })
    }
}

public extension StateStore {
    /**
     Initializes a new child StateStore with initial state
     - Parameter initialState: The initial state for the store
     - Parameter reducer: The function that is called on every dispatched Action and performs state mutations
     - Returns: `StateStore<State, Action>`
   
     ChildStore is a composition of root store and newly created local store.

     When action is dispatched to RootStore:
     - action is delivered to root store's reducer
     - action is not delivered to child store's reducer
     - root & child stores subscribers receive updates
     - AsyncAction dispatches result actions to RootStore

     When action is dispatched to ChildStore:
     - action is delivered to root store's reducer
     - action is delivered to child store's reducer
     - root & child stores subscribers receive updates
     - AsyncAction dispatches result actions to ChildStore
     */
    func with<T>(_ initialState: T,
                 reducer: @escaping Reducer<T, Action>) -> StateStore<(State, T), Action> {
        
        StateStore<(State, T), Action>(
            storeObject: storeObject.createChildStore(
                initialState: initialState,
                stateMapping: { ($0, $1) },
                reducer: reducer
            )
        )
    }
}

public extension StateStore {
    @available(*, deprecated, renamed: "init(_:qos:reducer:)", message: "Actions Interceptor will be removed in 2.0, use AsyncAction instead.")
    init(_ initialState: State,
         interceptor: @escaping (Action, @escaping Dispatch<Action>) -> Void,
         qos: DispatchQoS = .userInteractive,
         reducer: @escaping Reducer<State, Action>) {
        
        self.init(storeObject: RootStoreNode.initRootStore(
            initialState: initialState,
            interceptor: interceptor,
            qos: qos,
            reducer: reducer
        ))
    }
}

public extension StateStore {
    @available(*, deprecated, renamed: "stateStore(_:stateMapping:qos:reducer:)", message: "Will be removed in 2.0")
    func childStore<LocalState, ResultState>(
        initialState: LocalState,
        stateMapping: @escaping (State, LocalState) -> ResultState,
        qos: DispatchQoS = .userInteractive,
        reducer: @escaping Reducer<LocalState, Action>) -> StateStore<ResultState, Action> {
           
            stateStore(
                initialState,
                stateMapping: stateMapping,
                qos: qos,
                reducer: reducer
            )
    }

    @available(*, deprecated, message: "Use with(_:reducer) and store transformations instead. Will be removed in 2.0. ")
    func stateStore<LocalState, ResultState>(
        _ initialState: LocalState,
        stateMapping: @escaping (State, LocalState) -> ResultState,
        qos: DispatchQoS,
        reducer: @escaping Reducer<LocalState, Action>
    
    ) -> StateStore<ResultState, Action> {
            
            StateStore<ResultState, Action>(
                storeObject: storeObject.createChildStore(
                    initialState: initialState,
                    stateMapping: stateMapping,
                    qos: qos,
                    reducer: reducer
                )
            )
        }
    
    @available(*, deprecated, message: "Use with(_:reducer) and store transformations instead. Will be removed in 2.0.")
    func stateStore<LocalState, ResultState>(
        _ initialState: LocalState,
        stateMapping: @escaping (State, LocalState) -> ResultState,
        reducer: @escaping Reducer<LocalState, Action>
    
    ) -> StateStore<ResultState, Action> {
            
            StateStore<ResultState, Action>(
                storeObject: storeObject.createChildStore(
                    initialState: initialState,
                    stateMapping: stateMapping,
                    reducer: reducer
                )
            )
        }
}

extension StateStore {
    @available(*, deprecated, message: "Qos parameter will have no effect. Root store's QoS is used. Use with(_:reducer) and store transformations instead. Will be removed in 2.0.")
    public func stateStore<T>(
        _ state: T,
        qos: DispatchQoS = .userInitiated,
        reducer: @escaping Reducer<T, Action>
        
    ) -> StateStore<(State, T), Action> {
        
        with(state, reducer: reducer)
    }
}
