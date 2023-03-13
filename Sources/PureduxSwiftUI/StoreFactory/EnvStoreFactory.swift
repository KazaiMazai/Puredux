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
    Initializes a new EnvStoreFactory with provided StoreFactory.
     EnvStoreFactory is an `ObservableObject` wrap around Puredux's StoreFactory to be used in SwiftUI.

    - Parameter storeFactory: Puredux's StoreFactory

    - Returns: `EnvStoreFactory<AppState, Action>`

     `EnvStoreFactory` is a factory for stores of different configuration: `PublishingStore` and `PublishingStoreObject`
     `EnvStoreFactory`, `PublishingStore` and `PublishingStoreObject` are SwiftUI-friendly counterparts for Puredux's `StoreFactory`, `Store` and `StoreObject`

     */

    public init(storeFactory: StoreFactory<AppState, Action>) {
        self.storeFactory = storeFactory
        self.stateSubject = PassthroughSubject<AppState, Never>()
        storeFactory.rootStore().subscribe(observer: asObserver)
    }
}

extension EnvStoreFactory {

    /**
     Initializes a new light-weight proxy PublishingStore as a proxy for the EnvStoreFactory's root store

     - Returns: Light-weight `PublishingStore`

     `PublishingStore` is a light-weight proxy for the EnvStoreFactory's root store.
     All dispatched Actions are forwarded to the root store.
     `PublishingStore` is thread safe, the same as its proxies. Actions can be safely dispatched from any thread.

     */

    func rootStore() -> PublishingStore<AppState, Action> {
        PublishingStore(
            statePublisher: statePublisher(),
            dispatch: { [weak self] in self?.dispatch($0) }
        )
    }

    /**
     Initializes a new Store with state mapping to local substate.

     - Returns: Store with local substate

     Store is a proxy for the root store object.
     All dispatched Actions and subscribtions are forwarded to the root store object.
     */

    func scopeStore<LocalState>(to localState: @escaping (AppState) -> LocalState) -> PublishingStore<LocalState, Action> {
        rootStore()
            .scope(to: localState)
    }


    /**
     Initializes a new child store with initial state

     - Returns: Child PublishingStoreObject

     ChildStore is a composition of root store and newly created local store.
     Child state is a mapping of the local state and root store's state.

     ChildStore's lifecycle along with its LocalState is determined by PublishingStoreObject's lifecycle.
     ChildStore initialization is comparably expensive because it involves heap object allocation.

     RootStore vs ChildStore Action Dispatch

     When action is dispatched to RootStore:
     - action is delivered to root store's reducer
     - action is not delivered to child store's reducer
     - root state update triggers root store's subscribers
     - root state update triggers child stores' subscribers
     - Interceptor dispatches additional actions to RootStore

     When action is dispatched to ChildStore:
     - action is delivered to root store's reducer
     - action is delivered to child store's reducer
     - root state update triggers root store's subscribers.
     - root state update triggers child store's subscribers.
     - local state update triggers child stores' subscribers.
     - Interceptor dispatches additional actions to ChildStore

     */
    func childStore<ChildState, LocalState>(
        initialState: ChildState,
        stateMapping: @escaping (AppState, ChildState) -> LocalState,
        qos: DispatchQoS,
        reducer: @escaping Reducer<ChildState, Action>) ->

    PublishingStoreObject<LocalState, Action> {

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
