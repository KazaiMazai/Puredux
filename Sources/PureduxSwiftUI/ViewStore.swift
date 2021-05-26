//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.05.2021.
//

import Foundation
import Combine

protocol ViewStore {
    associatedtype AppState
    associatedtype Action

    var statePublisher: AnyPublisher<AppState, Never> { get }

    func dispatch(action: Action)

    var state: AppState { get }
}

extension ViewStore {
    func localStore<LocalState, LocalAction>(
        localState: @escaping (AppState) -> LocalState,
        storeAction: @escaping (LocalAction) -> Action) -> some ViewStore {

        LocalStore(
            store: self,
            localState: localState,
            storeAction: storeAction)
    }
}

extension ViewStore {
    func localStore<LocalState, LocalAction>(
        storeAction: @escaping (LocalAction) -> Action) -> some ViewStore where AppState == LocalState {

        LocalStore(
            store: self,
            localState: { $0 },
            storeAction: storeAction)
    }

    func localStore<LocalState, LocalAction>(
        localState: @escaping (AppState) -> LocalState) -> some ViewStore where Action == LocalAction {

        LocalStore(
            store: self,
            localState: localState,
            storeAction: { $0 })
    }
}



