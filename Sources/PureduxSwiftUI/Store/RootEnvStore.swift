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
    private let rootStore: RootStore<AppState, Action>
    private let stateSubject: PassthroughSubject<AppState, Never>

    public init(rootStore: RootStore<AppState, Action>) {

        self.rootStore = rootStore
        self.stateSubject = PassthroughSubject<AppState, Never>()
        rootStore.getStore().subscribe(observer: asObserver)
    }
}

public extension RootEnvStore {
    func store() -> PublishingStore<AppState, Action>{
        PublishingStore(
            statePublisher: statePublisher(),
            dispatch: { [weak self] in self?.dispatch($0) }
        )
    }
}

private extension RootEnvStore {
    func statePublisher() -> AnyPublisher<AppState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    func dispatch(_ action: Action) {
        rootStore.getStore().dispatch(action)
    }
}

private extension RootEnvStore {
    var asObserver: Observer<AppState> {
        Observer { [weak self] state, complete in
            guard let self = self else {
                complete(.dead)
                return
            }

            self.stateSubject.send(state)
            complete(.active)
        }
    }
}

