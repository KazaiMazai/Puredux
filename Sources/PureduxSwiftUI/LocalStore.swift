//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.05.2021.
//

import Foundation
import Combine

struct LocalStore<Store: ViewStore, AppState, LocalState, LocalAction>: ViewStore
    where Store.AppState == AppState {

    private let store: Store
    private let localState: (AppState) -> LocalState
    private let storeAction: (LocalAction) -> Store.Action

    let statePublisher: AnyPublisher<LocalState, Never>

    init(store: Store,
         localState: @escaping (AppState) -> LocalState,
         storeAction: @escaping (LocalAction) -> Store.Action) {
        self.localState = localState
        self.storeAction = storeAction
        self.store = store
        self.statePublisher = store.statePublisher
            .map { localState($0) }
            .eraseToAnyPublisher()
    }

    var state: LocalState {
        localState(store.state)
    }

    func dispatch(action: LocalAction) {
        store.dispatch(action: storeAction(action))
    }
}
