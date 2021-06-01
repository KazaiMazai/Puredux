//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.06.2021.
//

import Foundation
import PureduxStore

struct StoreProxy<Store: StoreProtocol, LocalState, LocalAction>: StoreProtocol {
    private var store: Store
    private let toLocalState: (Store.AppState) -> LocalState
    private let fromLocalAction: (LocalAction) -> Store.Action

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

    func dispatch(_ action: LocalAction) {
        store.dispatch(fromLocalAction(action))
    }

    func subscribe(observer: Observer<LocalState>) {
        store.subscribe(Observer { state, complete in
            observer.observe(toLocalState(state), complete)
        })
    }
}
