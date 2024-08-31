//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.05.2021.
//

import Foundation
import Combine


public struct PublishingStore<AppState, Action> {
    public let statePublisher: AnyPublisher<AppState, Never>
    private let dispatchClosure: (_ action: Action) -> Void

    /// Initializes a new PublishingStore
    ///
    /// - Parameter dispatch: Closure that handles Store's dispatching Actions
    /// - Parameter statePublisher: State publisher allowing to listen to store's state changes
    ///
    /// - Returns: Light-weight PublishingStore
    ///
    /// Generally, PublishingStore has no reason to be Initialized directly with this initializer
    /// unless you want to mock the PublishingStore completely or provide your own implementation.
    ///
    /// For all other cases, EnvStoreFactory's methods should be used to create viable PublishingStore.
    ///
    public init(statePublisher: AnyPublisher<AppState, Never>,
                dispatch: @escaping (Action) -> Void) {
        self.statePublisher = statePublisher
        self.dispatchClosure = dispatch
    }

    public func dispatch(_ action: Action) {
        dispatchClosure(action)
    }
}


public extension PublishingStore {
    /// Initializes a new proxy PublishingStore with state mapping to local substate.
    ///
    /// - Returns: `PublishingStore<LocalState, Action>` with local substate
    ///
    /// PublishingStore is a proxy for the root store
    /// All dispatched Actions are forwarded to the root store.
    /// PublishingStore is thread safe. Actions can be safely dispatched from any thread.
    ///
    @available(*, deprecated, message: "Will be removed in 2.0. Use scope(...) method instead")
    func proxy<LocalState>(
        toLocalState: @escaping (AppState) -> LocalState) -> PublishingStore<LocalState, Action> {

        PublishingStore<LocalState, Action>(
            statePublisher: statePublisher
                .map { toLocalState($0) }
                .eraseToAnyPublisher(),
            dispatch: dispatch
        )
    }

    /// Initializes a new proxy PublishingStore with state mapping to local substate.
    ///
    /// - Returns: `PublishingStore<LocalState, Action>` with local substate
    ///
    /// PublishingStore is a proxy for the root store
    /// All dispatched Actions are forwarded to the root store.
    /// PublishingStore is thread safe. Actions can be safely dispatched from any thread.
    ///
    func scope<LocalState>(to localState: @escaping (AppState) -> LocalState) -> PublishingStore<LocalState, Action> {

        PublishingStore<LocalState, Action>(
            statePublisher: statePublisher
                .map { localState($0) }
                .eraseToAnyPublisher(),
            dispatch: dispatch
        )
    }
}
