//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.02.2023.
//

import Combine
import SwiftUI

/// EnvStoreFactory is an `ObservableObject` wrap around Puredux's StoreFactory to be used in SwiftUI view hierarchy via environmentObject injection
///
/// `EnvStoreFactory` is a factory for stores of different configuration:
/// - Root Store
/// - Scope Store
/// - Child Store
///
/// That are connected afterwards to the SwiftUI via `ViewWithStore`
///
/// These guys:
/// - `EnvStoreFactory`
/// - `PublishingStore`
/// - `PublishingStoreObject`
///
/// are SwiftUI-friendly counterparts for Puredux's
/// - `StoreFactory`
/// - `Store`
/// - `StoreObject`
///
/// **Usage:**
///
/// ```swift
/// let factory = StoreFactory(
///     initialState: AppState(),
///     reducer: { state, action in state.reduce(action) }
/// )
///
/// let envFactory = EnvStoreFactory(factory)
/// ```
///
@available(iOS 13.0, *)
public final class EnvStoreFactory<AppState, Action>: ObservableObject {
    private let storeFactory: StoreFactory<AppState, Action>
    private let stateSubject: PassthroughSubject<AppState, Never>

    /// Initializes a new EnvStoreFactory with provided StoreFactory.
    /// EnvStoreFactory is an `ObservableObject` wrap around Puredux's StoreFactory to be used in SwiftUI view hierarchy via  environmentObject injection
    ///
    /// - Parameter storeFactory: Puredux's StoreFactory
    ///
    /// - Returns: `EnvStoreFactory<AppState, Action>`
    public init(storeFactory: StoreFactory<AppState, Action>) {
        self.storeFactory = storeFactory
        self.stateSubject = PassthroughSubject<AppState, Never>()
        storeFactory.rootStore().subscribe(observer: asObserver)
    }
}

@available(iOS 13.0, *)
extension EnvStoreFactory {

    /// Initializes a PublishingStore as a proxy for the EnvStoreFactory's root store
    ///
    /// - Returns: `PublishingStore<AppState, Action>`
    ///
    /// `PublishingStore` is a  proxy for the EnvStoreFactory's root store.
    ///
    /// All dispatched Actions are forwarded to the root store. PublishingStore's statePublisher is the root store's state publisher.
    ///
    /// `PublishingStore` is thread safe. Actions can be safely dispatched from any thread.
    ///
    func rootStore() -> PublishingStore<AppState, Action> {
        PublishingStore(
            statePublisher: statePublisher(),
            dispatch: { [weak self] in self?.dispatch($0) }
        )
    }

    /// Initializes a new PublishingStore as a proxy for the EnvStoreFactory's root store with a mapping of root store state to local state.
    ///
    /// - Returns: `PublishingStore<LocalState, Action>`
    ///
    /// `PublishingStore` is a  proxy for the EnvStoreFactory's root store.
    ///
    /// All dispatched Actions are forwarded to the root store. PublishingStore's state publisher is mapping of the root store state publisher.
    ///
    /// `PublishingStore` is thread safe. Actions can be safely dispatched from any thread.
    ///
    func scopeStore<LocalState>(to localState: @escaping (AppState) -> LocalState) -> PublishingStore<LocalState, Action> {
        rootStore()
            .scope(to: localState)
    }

    /// Initializes a new child store with initial child state
    ///
    /// - Returns: Child `PublishingStoreObject<LocalState, Action>`
    ///
    /// ChildStore is a composition of root store and newly created local store.
    /// Child state is a mapping of the local state and root store's state.
    ///
    /// ChildStore's lifecycle along with its LocalState is determined by PublishingStoreObject's lifecycle.
    /// ChildStore initialization is comparably expensive because it involves heap object allocation.
    ///
    /// **RootStore vs ChildStore Action Dispatch.**
    ///
    /// When action is dispatched to RootStore:
    /// - action is delivered to root store's reducer
    /// - action is not delivered to child store's reducer
    /// - root state update triggers root store's subscribers
    /// - root state update triggers child stores' subscribers
    /// - Interceptor dispatches additional actions to RootStore
    ///
    /// When action is dispatched to ChildStore:
    /// - action is delivered to root store's reducer
    /// - action is delivered to child store's reducer
    /// - root state update triggers root store's subscribers.
    /// - root state update triggers child store's subscribers.
    /// - local state update triggers child stores' subscribers.
    /// - Interceptor dispatches additional actions to ChildStore
    ///
    func childStore<ChildState, LocalState>(
        initialState: ChildState,
        stateMapping: @escaping (AppState, ChildState) -> LocalState,
        qos: DispatchQoS = .userInteractive,
        reducer: @escaping Reducer<ChildState, Action>) ->

    PublishingStoreObject<LocalState, Action> {

        PublishingStoreObject(
            stateStore: storeFactory.childStore(
                initialState: initialState,
                stateMapping: stateMapping,
                qos: qos,
                reducer: reducer
            )
        )
    }

    ///  Initializes a new child store with initial child state.
    ///
    /// - Returns: Child `PublishingStoreObject<(AppState, ChildState), Action>`
    ///
    /// ChildStore is a composition of root store and newly created local store.
    /// Child state is a mapping of the local state and root store's state.
    ///
    /// ChildStore's lifecycle along with its LocalState is determined by PublishingStoreObject's lifecycle.
    /// ChildStore initialization is comparably expensive because it involves heap object allocation.
    ///
    /// **RootStore vs ChildStore Action Dispatch.**
    ///
    /// When action is dispatched to RootStore:
    /// - action is delivered to root store's reducer
    /// - action is not delivered to child store's reducer
    /// - root state update triggers root store's subscribers
    /// - root state update triggers child stores' subscribers
    /// - Interceptor dispatches additional actions to RootStore
    ///
    /// When action is dispatched to ChildStore:
    /// - action is delivered to root store's reducer
    /// - action is delivered to child store's reducer
    /// - root state update triggers root store's subscribers.
    /// - root state update triggers child store's subscribers.
    /// - local state update triggers child stores' subscribers.
    /// - Interceptor dispatches additional actions to ChildStore
    ///
    func childStore<ChildState>(
        initialState: ChildState,
        qos: DispatchQoS = .userInteractive,
        reducer: @escaping Reducer<ChildState, Action>) ->

    PublishingStoreObject<(AppState, ChildState), Action> {

        PublishingStoreObject(
            stateStore: storeFactory.childStore(
                initialState: initialState,
                qos: qos,
                reducer: reducer
            )
        )
    }
}

@available(iOS 13.0, *)
private extension EnvStoreFactory {
    func statePublisher() -> AnyPublisher<AppState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    func dispatch(_ action: Action) {
        storeFactory.rootStore().dispatch(action)
    }
}

@available(iOS 13.0, *)
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
