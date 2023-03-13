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

    /**
     Initializes a new light-weight PublishingStore

     - Parameter dispatch: Closure that handles Store's dispatching Actions
     - Parameter statePublisher: State publisher allowing to listen to store's state changes

     - Returns: Light-weight PublishingStore

     Generally, PublishingStore has no reason to be Initialized directly with this initializer
     unless you want to mock the PublishingStore completely or provide your own implementation.

     For all other cases, StoreFactory's store() methods should be used to create viable PublishingStore.
     */

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
    /**
     Initializes a new light-weight proxy PublishingStore with state mapping to local substate.

     - Returns: Light-weight PublishingStore with local substate

     PublishingStore is a light-weight proxy for the RootEnvStore's private root store.
     All dispatched Actions are forwarded to the private internal store.
     Internal store is thread safe, the same as its proxies. Actions can be safely dispatched from any thread.
     */
    func proxy<LocalState>(
        toLocalState: @escaping (AppState) -> LocalState) -> PublishingStore<LocalState, Action> {

        PublishingStore<LocalState, Action>(
            statePublisher: statePublisher
                .map { toLocalState($0) }
                .eraseToAnyPublisher(),
            dispatch: dispatch
        )
    }

    func scope<LocalState>(to localState: @escaping (AppState) -> LocalState) -> PublishingStore<LocalState, Action> {

        PublishingStore<LocalState, Action>(
            statePublisher: statePublisher
                .map { localState($0) }
                .eraseToAnyPublisher(),
            dispatch: dispatch
        )
    }
}
