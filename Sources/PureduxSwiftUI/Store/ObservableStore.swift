//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import PureduxStore
import Combine
import SwiftUI

public final class ObservableStore<AppState, Action>: ObservableObject, ObservableStoreProtocol {
    private let store: Store<AppState, Action>
    private let queue: DispatchQueue
    private let stateSubject: PassthroughSubject<AppState, Never>

    public var statePublisher: AnyPublisher<AppState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    public convenience init(store: Store<AppState, Action>,
                label: String = "com.puredux.observable-store",
                qos: DispatchQoS = .userInteractive) {

        self.init(store: store,
                  queue: DispatchQueue(label: label, qos: qos))
    }

    public init(store: Store<AppState, Action>,
                queue: DispatchQueue) {

        self.store = store
        self.stateSubject = PassthroughSubject<AppState, Never>()
        self.queue = queue

        store.subscribe(observer: asObserver)
    }

    public func dispatch(_ action: Action) {
        store.dispatch(action)
    }
}

private extension ObservableStore {
    var asObserver: PureduxStore.Observer<AppState> {
        PureduxStore.Observer { [weak self] state, complete in
            guard let self = self else {
                complete(.dead)
                return
            }

            self.queue.async { [weak self] in
                guard let self = self else {
                    complete(.dead)
                    return
                }

                self.stateSubject.send(state)
                complete(.active)
            }
        }
    }
}

