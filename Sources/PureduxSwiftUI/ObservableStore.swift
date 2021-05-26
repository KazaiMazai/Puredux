//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import PureduxStore
import Combine
import SwiftUI

public protocol StoreProtocol {
    associatedtype AppState
    associatedtype Action

    func dispatch(action: Action)

    var state: AppState { get }

    func subscribe(observer: PureduxStore.Observer<AppState>)
}

struct LocalStore<Store: ViewStore, AppState, LocalState>: ViewStore
    where Store.AppState == AppState {

    typealias Action = Store.Action

    private let store: Store

    init(store: Store,
         localState: @escaping (AppState) -> LocalState) {
        self.localState = localState
        self.store = store
        self.statePublisher = store.statePublisher
            .map { localState($0) }
            .eraseToAnyPublisher()
    }

    let localState: (AppState) -> LocalState

    let statePublisher: AnyPublisher<LocalState, Never>

    var state: LocalState {
        localState(store.state)
    }

    func dispatch(action: Action) {
        store.dispatch(action: action)
    }

}

extension PureduxStore.Store: StoreProtocol {

}

protocol ViewStore {
    associatedtype AppState
    associatedtype Action

    var statePublisher: AnyPublisher<AppState, Never> { get }

    func dispatch(action: Action)

    var state: AppState { get }
}

public class ObservableStore<Store>: ObservableObject, ViewStore
    where
    Store: StoreProtocol {

    typealias AppState = Store.AppState
    public typealias Action = Store.Action

    private let store: Store
    private let queue: DispatchQueue

    let stateSubject: PassthroughSubject<AppState, Never>

    var statePublisher: AnyPublisher<Store.AppState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    var state: AppState {
        store.state
    }

    public init(store: Store,
                label: String = "EnvironmentStoreQueue",
                qos: DispatchQoS = .userInteractive) {

        self.store = store
        self.stateSubject = PassthroughSubject<AppState, Never>()
        self.queue = DispatchQueue(label: label, qos: qos)

        store.subscribe(observer: asObserver)
    }

    public func dispatch(action: Action) {
        store.dispatch(action: action)
    }
}

private extension ObservableStore {
    var asObserver: PureduxStore.Observer<AppState> {
        PureduxStore.Observer { [weak self] state in
            guard let self = self else {
                return .dead
            }

            self.queue.async {
                self.stateSubject.send(state)
            }

            return .active
        }
    }
}

