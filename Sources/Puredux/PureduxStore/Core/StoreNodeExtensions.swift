//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 22.02.2023.
//

import Foundation

typealias RootStoreNode<State, Action> = StoreNode<VoidStore<Action>, State, State, Action>

extension StoreNode where LocalState == State {
    static func initRootStore(initialState: State,
                              interceptor: @escaping (Action, @escaping Dispatch<Action>) -> Void = { _, _ in },
                              qos: DispatchQoS = .userInteractive,
                              reducer: @escaping Reducer<State, Action>) -> RootStoreNode<State, Action> {

        RootStoreNode<State, Action>(
            initialState: initialState,
            stateMapping: { _, state in return state },
            parentStore: VoidStore<Action>(
                actionsInterceptor: ActionsInterceptor(
                    storeId: StoreID(),
                    handler: interceptor,
                    dispatcher: { _ in }
                )
            ),
            reducer: reducer
        )
    }
}

extension StoreNode {
    func store() -> Store<State, Action> {
        Store(
            dispatch: { [weak self] in self?.dispatch($0) },
            subscribe: { [weak self] in self?.subscribe(observer: $0) }
        )
    }

    func storeObject() -> StoreObject<State, Action> {
        StoreObject(
            dispatch: { self.dispatch($0) },
            subscribe: { self.subscribe(observer: $0) }
        )
    }
}

extension StoreNode {

    func createChildStore<NodeState, ResultState>(initialState: NodeState,
                                                  stateMapping: @escaping (State, NodeState) -> ResultState,
                                                  qos: DispatchQoS = .userInteractive,
                                                  reducer: @escaping Reducer<NodeState, Action>) ->

    StoreNode<StoreNode<ParentStore, LocalState, State, Action>, NodeState, ResultState, Action> {

        StoreNode<StoreNode<ParentStore, LocalState, State, Action>, NodeState, ResultState, Action>(
            initialState: initialState,
            stateMapping: stateMapping,
            parentStore: self,
            reducer: reducer
        )
    }
}
