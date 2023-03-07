//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.02.2023.
//

import PureduxStore
import SwiftUI
import Combine

public struct PublishingStoreObject<AppState, Action> {
    private let storeObject: StoreObject<AppState, Action>
    private let stateSubject: PassthroughSubject<AppState, Never>

    /**
    Initializes a new RootEnvStore with provided RootStore.
    RootEnvStore is an `ObservableObject` wrap around Puredux's RootStore to be used in SwiftUI.

    - Parameter rootStore: Puredux's root store

    - Returns: `RootEnvStore<AppState, Action>`

     `RootEnvStore` acts like a factory for light-weight  `PublishingStores`.

     `RootEnvStore` and `PublishingStore` are SwiftUI-friendly counterparts for Puredux's RootStore and Store.
     RootEnvStore is what we have on top. PublishingStore are lightweight proxies that we are to connect our views to.

     */

    public init(storeObject: StoreObject<AppState, Action>) {
        self.storeObject = storeObject
        self.stateSubject = PassthroughSubject<AppState, Never>()
        storeObject.store().subscribe(observer: asObserver)
    }
}

public extension PublishingStoreObject {

    /**
     Initializes a new light-weight proxy PublishingStore as a proxy for the RootEnvStore's internal root store

     - Returns: Light-weight `PublishingStore`

     `PublishingStore` is a light-weight proxy for the RootEnvStore's private root store.
     All dispatched Actions are forwarded to the private root store.
     `PublishingStore` is thread safe, the same as its proxies. Actions can be safely dispatched from any thread.

     **Important to note:** Proxy store only keeps weak reference to the internal root store,
     ensuring that reference cycles will not be created.

     */

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


public class PublishStoreObject<AppState, Action>: ObservableObject {
    private let storeObject: StoreObject<AppState, Action>
    private let stateSubject: PassthroughSubject<AppState, Never>

    /**
    Initializes a new RootEnvStore with provided RootStore.
    RootEnvStore is an `ObservableObject` wrap around Puredux's RootStore to be used in SwiftUI.

    - Parameter rootStore: Puredux's root store

    - Returns: `RootEnvStore<AppState, Action>`

     `RootEnvStore` acts like a factory for light-weight  `PublishingStores`.

     `RootEnvStore` and `PublishingStore` are SwiftUI-friendly counterparts for Puredux's RootStore and Store.
     RootEnvStore is what we have on top. PublishingStore are lightweight proxies that we are to connect our views to.

     */

    public init(storeObject: StoreObject<AppState, Action>) {
        self.storeObject = storeObject
        self.stateSubject = PassthroughSubject<AppState, Never>()
        storeObject.store().subscribe(observer: asObserver)
    }
}

public extension PublishStoreObject {

    /**
     Initializes a new light-weight proxy PublishingStore as a proxy for the RootEnvStore's internal root store

     - Returns: Light-weight `PublishingStore`

     `PublishingStore` is a light-weight proxy for the RootEnvStore's private root store.
     All dispatched Actions are forwarded to the private root store.
     `PublishingStore` is thread safe, the same as its proxies. Actions can be safely dispatched from any thread.

     **Important to note:** Proxy store only keeps weak reference to the internal root store,
     ensuring that reference cycles will not be created.

     */

    func store() -> PublishingStore<AppState, Action> {

        PublishingStore(
            statePublisher: statePublisher(),
            dispatch: { [weak storeObject] in storeObject?.dispatch($0) }
        )
    }
}

private extension PublishStoreObject {
    func statePublisher() -> AnyPublisher<AppState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    func dispatch(_ action: Action) {
        storeObject.dispatch(action)
    }
}

private extension PublishStoreObject {
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
