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

     For all other cases, RootEnvStore's store() method should be used to create viable light-weight PublishingStore.
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

extension PublishingStore {
    /**
     Initializes a new light-weight proxy PublishingStore with state mapping to local substate.

     - Returns: Light-weight PublishingStore with local substate

     PublishingStore is a light-weight proxy for the RootEnvStore's private root store.
     All dispatched Actions are forwarded to the private internal store.
     Internal store is thread safe, the same as its proxies. Actions can be safely dispatched from any thread.

     **Important to note** that proxy store only keeps weak reference to the RootStore's
     internal store, ensuring that reference cycles will not be created.

     */
    func proxy<LocalState>(
        toLocalState: @escaping (AppState) -> LocalState) -> PublishingStore<LocalState, Action>  {

        PublishingStore<LocalState, Action>(
            statePublisher: statePublisher
                .map { toLocalState($0) }
                .eraseToAnyPublisher(),
            dispatch: dispatch)
    }
}
