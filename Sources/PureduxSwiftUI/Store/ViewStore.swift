//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.05.2021.
//

import Foundation
import Combine

public protocol ViewStore {
    associatedtype AppState
    associatedtype Action

    var statePublisher: AnyPublisher<AppState, Never> { get }

    func dispatch(_ action: Action)
}

extension ViewStore {
    func proxy<LocalState, LocalAction>(
        localState: @escaping (AppState) -> LocalState,
        fromLocalAction: @escaping (LocalAction) -> Action) -> some ViewStore {

        StoreProxy(
            store: self,
            toLocalState: localState,
            fromLocalAction: fromLocalAction)
    }
}

extension ViewStore {
    func proxy<LocalState, LocalAction>(
        fromLocalAction: @escaping (LocalAction) -> Action) -> some ViewStore

        where AppState == LocalState {

        proxy(localState:  { $0 },
              fromLocalAction: fromLocalAction)
    }

    func proxy<LocalState, LocalAction>(
        localState: @escaping (AppState) -> LocalState) -> some ViewStore

        where Action == LocalAction {

        proxy(localState: localState,
              fromLocalAction: { $0 })
    }

    func proxy<LocalState, LocalAction>() -> some ViewStore
        where Action == LocalAction {

        proxy(localState: { $0 },
              fromLocalAction: { $0 })
    }
}



