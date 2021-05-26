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
        storeAction: @escaping (LocalAction) -> Action,
        distinctStateChangesBy: @escaping (LocalState, LocalState) -> Bool) -> some ViewStore {

        LocalStore(
            store: self,
            localState: localState,
            storeAction: storeAction,
            distinctStateChangesBy: distinctStateChangesBy)
    }
}

extension ViewStore {
    func localStore<LocalState, LocalAction>(
        storeAction: @escaping (LocalAction) -> Action,
        distinctStateChangesBy: @escaping (LocalState, LocalState) -> Bool = { _,_ in true }) -> some ViewStore where AppState == LocalState {

        LocalStore(
            store: self,
            localState: { $0 },
            storeAction: storeAction,
            distinctStateChangesBy: distinctStateChangesBy)
    }

    func localStore<LocalState, LocalAction>(
        localState: @escaping (AppState) -> LocalState,
        distinctStateChangesBy: @escaping (LocalState, LocalState) -> Bool = { _,_ in true }) -> some ViewStore where Action == LocalAction {

        LocalStore(
            store: self,
            localState: localState,
            storeAction: { $0 },
            distinctStateChangesBy: distinctStateChangesBy)
    }
}



