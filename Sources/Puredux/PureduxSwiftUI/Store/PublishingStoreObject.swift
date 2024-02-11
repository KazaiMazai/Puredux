//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.02.2023.
//


import SwiftUI
import Combine

/// PublishingStoreObject is a publishing wrap around Puredux's StoreObject to be used in SwiftUI view hierarchy.
/// PublishingStoreObject owns a `StoreObject` inside allowing to control the `StoreObject`'s lifecycle.
///
public struct PublishingStoreObject<AppState, Action> {
    private let storeObject: StoreObject<AppState, Action>
    private let stateSubject: PassthroughSubject<AppState, Never>

    /// Initializes a new PublishingStoreObject
    ///
    /// - Parameter storeObject: actual StoreObject that is wrapped into PubslishingStoreObject
    ///
    /// - Returns: PublishingStoreObject
    ///
    /// Generally, PublishingStoreObject has no reason to be Initialized directly with this initializer
    /// unless you want to mock the PublishingStoreObject completely or provide your own implementation.
    ///
    /// For all other cases, EnvStoreFactory's methods should be used to create viable PublishingStoreObject.
    ///
    public init(storeObject: StoreObject<AppState, Action>) {
        self.storeObject = storeObject
        self.stateSubject = PassthroughSubject<AppState, Never>()
        storeObject.subscribe(observer: asObserver)
    }
}

public extension PublishingStoreObject {
    /// Initializes a new proxy PublishingStore.
    ///
    /// - Returns: `PublishingStore<AppState, Action>`
    ///
    /// PublishingStore is a proxy for the root store
    /// All dispatched Actions are forwarded to the root store.
    /// PublishingStore is thread safe. Actions can be safely dispatched from any thread.
    ///
    func store() -> PublishingStore<AppState, Action> {
        PublishingStore(
            statePublisher: statePublisher(),
            dispatch: { [weak storeObject] in storeObject?.dispatch($0) }
        )
    }
}

private extension PublishingStoreObject {
    func statePublisher() -> AnyPublisher<AppState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    func dispatch(_ action: Action) {
        storeObject.dispatch(action)
    }
}

private extension PublishingStoreObject {
    var asObserver: Observer<AppState> {
        Observer { [weak stateSubject] state, complete in
            guard let stateSubject else {
                complete(.dead)
                return
            }

            stateSubject.send(state)
            complete(.active)
        }
    }
}
