//
//  File.swift
//
//
//  Created by Sergey Kazakov on 01.12.2020.
//


import Combine
import SwiftUI

@available(iOS 13.0, *)
public final class RootEnvStore<AppState, Action>: ObservableObject {
    private let rootStore: RootStore<AppState, Action>
    private let stateSubject: PassthroughSubject<AppState, Never>


    ///    Initializes a new RootEnvStore with provided RootStore.
    ///    RootEnvStore is an `ObservableObject` wrap around Puredux's RootStore to be used in SwiftUI.
    ///
    ///    - Parameter rootStore: Puredux's root store
    ///
    ///    - Returns: `RootEnvStore<AppState, Action>`
    ///
    ///     `RootEnvStore` acts like a factory for light-weight  `PublishingStores`.
    ///
    ///     `RootEnvStore` and `PublishingStore` are SwiftUI-friendly counterparts for Puredux's RootStore and Store.
    ///     RootEnvStore is what we have on top. PublishingStore are lightweight proxies that we are to connect our views to.
    ///
    @available(*, deprecated, message: "Will be removed in the next major release. Use StoreFactory with EnvStoreFactory instead")
    public init(rootStore: RootStore<AppState, Action>) {
        self.rootStore = rootStore
        self.stateSubject = PassthroughSubject<AppState, Never>()
        rootStore.store().subscribe(observer: asObserver)
    }
}

@available(iOS 13.0, *)
public extension RootEnvStore {

    ///     Initializes a new light-weight proxy PublishingStore as a proxy for the RootEnvStore's internal root store
    ///
    ///     - Returns: Light-weight `PublishingStore`
    ///
    ///     `PublishingStore` is a light-weight proxy for the RootEnvStore's private root store.
    ///     All dispatched Actions are forwarded to the private root store.
    ///     `PublishingStore` is thread safe, the same as its proxies. Actions can be safely dispatched from any thread.
    ///
    ///     **Important to note:** Proxy store only keeps weak reference to the internal root store,
    ///     ensuring that reference cycles will not be created.
    ///
    @available(*, deprecated, message: "Will be removed in the next major release. Use EnvStoreFactory's rootStore instead")
    func store() -> PublishingStore<AppState, Action> {

        PublishingStore(
            statePublisher: statePublisher(),
            dispatch: { [weak self] in self?.dispatch($0) }
        )
    }
}

@available(iOS 13.0, *)
private extension RootEnvStore {
    func statePublisher() -> AnyPublisher<AppState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    func dispatch(_ action: Action) {
        rootStore.store().dispatch(action)
    }
}

@available(iOS 13.0, *)
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
