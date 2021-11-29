//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.06.2021.
//

import Foundation
import PureduxStore

struct StoreProxy<Store: StoreProtocol, LocalState>: StoreProtocol {
    private var store: Store
    private let toLocalState: (Store.AppState) -> LocalState

    init(store: Store,
         toLocalState: @escaping (Store.AppState) -> LocalState) {
        self.toLocalState = toLocalState
        self.store = store
    }

    func dispatch(_ action: Store.Action) {
        store.dispatch(action)
    }

    func subscribe(observer: Observer<LocalState>) {
        let stateObserver = Observer<Store.AppState> { state, complete in
            observer.observe(toLocalState(state), complete: complete)
        }

        store.subscribe(observer: stateObserver)
    }
}
