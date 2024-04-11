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

    public func store() -> Store<State, Action> {
        weakStore()
    }

    public func dispatch(_ action: Action) {
        storeObject.dispatch(action)
    }

    public func subscribe(observer: Observer<State>) {
        storeObject.subscribe(observer: observer)
    }
}

extension StateStore {
    init(initialState: State,
         interceptor: @escaping (Action, @escaping Dispatch<Action>) -> Void = { _, _ in },
         qos: DispatchQoS = .userInteractive,
         reducer: @escaping Reducer<State, Action>) {

        storeObject = RootStoreNode.initRootStore(
            initialState: initialState,
            interceptor: interceptor,
            qos: qos,
            reducer: reducer)
    }
}

extension StateStore {
    func weakStore() -> Store<State, Action> {
        Store<State, Action>(
            dispatcher: { [weak storeObject] in storeObject?.dispatch($0) },
            subscribe: { [weak storeObject] in storeObject?.subscribe(observer: $0) })
    }

    func strongStore() -> Store<State, Action> {
        Store<State, Action>(
            dispatcher: dispatch,
            subscribe: subscribe)
    }

    func createChildStore<LocalState, ResultState>(initialState: LocalState,
                                                   stateMapping: @escaping (State, LocalState) -> ResultState,
                                                   qos: DispatchQoS,
                                                   reducer: @escaping Reducer<LocalState, Action>) -> StateStore<ResultState, Action> {

        StateStore<ResultState, Action>(
            storeObject: storeObject.createChildStore(
                initialState: initialState,
                stateMapping: stateMapping,
                qos: qos,
                reducer: reducer
            )
        )
    }

    func appending<T>(_ state: T,
                      qos: DispatchQoS = .userInitiated,
                      reducer: @escaping Reducer<T, Action>) -> StateStore<(State, T), Action> {

        createChildStore(
            initialState: state,
            stateMapping: { ($0, $1) },
            qos: qos,
            reducer: reducer
        )
    }
}
