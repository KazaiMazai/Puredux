//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 07.03.2023.
//

import PureduxStore
import Dispatch

public struct ScopeStore<AppState, LocalState> {
    let toLocalState: (AppState) -> LocalState

    public init(toLocalState: @escaping (AppState) -> LocalState) {
        self.toLocalState = toLocalState
    }
}

public struct ChildStore<AppState, LocalState, ChildState, Action> {
    let initialState: LocalState
    let stateMapping: (AppState, LocalState) -> ChildState
    let qos: DispatchQoS
    let reducer: Reducer<LocalState, Action>

    public init(initialState: LocalState,
                stateMapping: @escaping (AppState, LocalState) -> ChildState,
                qos: DispatchQoS,
                reducer: @escaping Reducer<LocalState, Action>) {

        self.initialState = initialState
        self.stateMapping = stateMapping
        self.qos = qos
        self.reducer = reducer
    }

}

enum StoreType<AppState, LocalState, ChildState, Action> {
    case rootStore
    case childStore(ChildStore<AppState, LocalState, ChildState, Action>)
    case scopeStore(ScopeStore<AppState, ChildState>)
}
