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
@available(iOS 13.0, *)
public struct PublishingStoreObject<AppState, Action> {
    private let stateStore: StateStore<AppState, Action>
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
    ///
    @available(*, deprecated, renamed: "init(stateStore:)", message: "Will be removed in the next major release.")
    public init(storeObject: StoreObject<AppState, Action>) {
        self.stateStore = storeObject
        self.stateSubject = PassthroughSubject<AppState, Never>()
        storeObject.subscribe(observer: asObserver)
    }

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
    public init(stateStore: StateStore<AppState, Action>) {
        self.stateStore = stateStore
        self.stateSubject = PassthroughSubject<AppState, Never>()
        stateStore.subscribe(observer: asObserver)
    }
}

@available(iOS 13.0, *)
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
        let store = stateStore.weakStore()
        return PublishingStore(
            statePublisher: statePublisher(),
            dispatch: { store.dispatch($0) }
        )
    }
}

@available(iOS 13.0, *)
private extension PublishingStoreObject {
    func statePublisher() -> AnyPublisher<AppState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    func dispatch(_ action: Action) {
        stateStore.dispatch(action)
    }
}

@available(iOS 13.0, *)
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
