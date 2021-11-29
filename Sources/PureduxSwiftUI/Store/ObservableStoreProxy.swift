//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.05.2021.
//

import Foundation
import Combine

struct ObservableStoreProxy<Store: ObservableStoreProtocol, LocalState>: ObservableStoreProtocol {
    private var store: Store
    private let toLocalState: (Store.AppState) -> LocalState

    let statePublisher: AnyPublisher<LocalState, Never>

    init(store: Store,
         toLocalState: @escaping (Store.AppState) -> LocalState) {
        self.toLocalState = toLocalState
        self.store = store
        self.statePublisher = store.statePublisher
            .map { toLocalState($0) }
            .eraseToAnyPublisher()
    }

    func dispatch(_ action: Store.Action) {
        store.dispatch(action)
    }
}
