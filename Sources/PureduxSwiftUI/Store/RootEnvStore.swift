//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import PureduxStore
import Combine
import SwiftUI

public final class RootEnvStore<AppState, Action>: ObservableObject {
    private let store: Store<AppState, Action>
    private let queue: DispatchQueue
    private let stateSubject: PassthroughSubject<AppState, Never>

    public convenience init(store: Store<AppState, Action>,
                            label: String = "com.puredux.swiftui-store",
                            qos: DispatchQoS = .userInteractive) {

        self.init(store: store,
                  queue: DispatchQueue(label: label, qos: qos))
    }

    init(store: Store<AppState, Action>,
         queue: DispatchQueue) {

        self.store = store
        self.stateSubject = PassthroughSubject<AppState, Never>()
        self.queue = queue

        store.subscribe(observer: asObserver)
    }
}

public extension RootEnvStore {
    func getStore() -> PublishingStore<AppState, Action>{
        PublishingStore(
            statePublisher: statePublisher,
            dispatch: { [weak self] in self?.dispatch($0) }
        )
    }
}

private extension RootEnvStore {
    func statePublisher() -> AnyPublisher<AppState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    func dispatch(_ action: Action) {
        store.dispatch(action)
    }
}


private extension RootEnvStore {
    var asObserver: Observer<AppState> {
        Observer { [weak self] state, complete in
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

