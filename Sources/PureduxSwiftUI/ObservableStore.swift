//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import PureduxStore
import Combine
import SwiftUI

public class ObservableStore<AppState, Action>: ObservableObject, ViewStore {
    private let store: Store<AppState, Action>
    private let queue: DispatchQueue

    let stateSubject: PassthroughSubject<AppState, Never>

    var statePublisher: AnyPublisher<AppState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    var state: AppState {
        store.state
    }

    public init(store: Store<AppState, Action>,
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

