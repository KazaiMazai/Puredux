//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.02.2023.
//

import PureduxStore
import Combine
import SwiftUI

public final class EnvStoreFactory<AppState, Action>: ObservableObject {
    private let storeFactory: StoreFactory<AppState, Action>
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

    public init(storeFactory: StoreFactory<AppState, Action>) {
        self.storeFactory = storeFactory
        self.stateSubject = PassthroughSubject<AppState, Never>()
        storeFactory.rootStore().subscribe(observer: asObserver)
    }
}

public extension EnvStoreFactory {

    /**
     Initializes a new light-weight proxy PublishingStore as a proxy for the RootEnvStore's internal root store

     - Returns: Light-weight `PublishingStore`

     `PublishingStore` is a light-weight proxy for the RootEnvStore's private root store.
     All dispatched Actions are forwarded to the private root store.
     `PublishingStore` is thread safe, the same as its proxies. Actions can be safely dispatched from any thread.

     **Important to note:** Proxy store only keeps weak reference to the internal root store,
     ensuring that reference cycles will not be created.

     */

    func rootStore() -> PublishingStore<AppState, Action> {

        PublishingStore(
            statePublisher: statePublisher(),
            dispatch: { [weak self] in self?.dispatch($0) }
        )
    }

    func scopeStore<LocalState>(toLocalState: @escaping (AppState) -> LocalState?) -> PublishingStore<LocalState, Action> {

        rootStore().scope(toLocalState: toLocalState)
    }

    func childStore<LocalState, ChildState>(
        initialState: LocalState,
        stateMapping: @escaping (AppState, LocalState) -> ChildState,
        qos: DispatchQoS = .userInteractive,
        reducer: @escaping Reducer<LocalState, Action>) ->

    PublishingStoreObject<ChildState, Action> {

        PublishingStoreObject(
            storeObject: storeFactory.childStore(
                initialState: initialState,
                stateMapping: stateMapping,
                qos: qos,
                reducer: reducer
            )
        )
    }
}

private extension EnvStoreFactory {
    func statePublisher() -> AnyPublisher<AppState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    func dispatch(_ action: Action) {
        storeFactory.rootStore().dispatch(action)
    }
}

private extension EnvStoreFactory {
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
