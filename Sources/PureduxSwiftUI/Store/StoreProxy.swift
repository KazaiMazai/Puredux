//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.05.2021.
//

import Foundation
import Combine

struct StoreProxy<Store: ViewStore, LocalState, LocalAction>: ViewStore {
    private var store: Store
    private let toLocalState: (Store.AppState) -> LocalState
    private let fromLocalAction: (LocalAction) -> Store.Action

    let statePublisher: AnyPublisher<LocalState, Never>

    init(store: Store,
         toLocalState: @escaping (Store.AppState) -> LocalState,
         fromLocalAction: @escaping (LocalAction) -> Store.Action) {
        self.toLocalState = toLocalState
        self.fromLocalAction = fromLocalAction
        self.store = store
        self.statePublisher = store.statePublisher
            .map { toLocalState($0) }
            .eraseToAnyPublisher()
    }

    func dispatch(action: LocalAction) {
        store.dispatch(action: fromLocalAction(action))
    }
}
