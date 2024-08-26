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

    public func stateStore<T>(
        _ state: T,
        qos: DispatchQoS = .userInitiated,
        reducer: @escaping Reducer<T, Action>
        
    ) -> StateStore<(State, T), Action> {
        
        stateStore(
            state,
            stateMapping: { ($0, $1) },
            qos: qos,
            reducer: reducer
        )
    }
}
