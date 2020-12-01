//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import PureduxStore
import SwiftUI

public class EnvironmentStore<State, Action>: ObservableObject {
    let store: PureduxStore.Store<State, Action>

    @Published private (set) var state: State

    public init(store: PureduxStore.Store<State, Action>) {
        self.store = store
        self.state = store.state

        store.subscribe(observer: asObserver)
    }

    public func dispatch(_ action: Action) {
        store.dispatch(action: action)
    }

    private var asObserver: PureduxStore.Observer<State> {
        PureduxStore.Observer(queue: .main) { state in
            self.state = state
            return .active
        }
    }
}
