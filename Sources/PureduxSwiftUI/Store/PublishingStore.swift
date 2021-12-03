//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.05.2021.
//

import Foundation
import Combine

public protocol PublishingStore {
    associatedtype AppState
    associatedtype Action

    var statePublisher: AnyPublisher<AppState, Never> { get }

    func dispatch(_ action: Action)
}

extension PublishingStore {
    func proxy<LocalState>(
        localState: @escaping (AppState) -> LocalState) -> AnyPublishingStore<LocalState, Action>  {

        PublishingStoreProxy(
            store: self,
            toLocalState: localState).eraseToAnyStore()
    }

    func eraseToAnyStore() -> AnyPublishingStore<AppState, Action> {
        AnyPublishingStore(statePublisher: statePublisher,
                           dispatch: self.dispatch)
    }
}

public struct AnyPublishingStore<AppState, Action>: PublishingStore {
    public let statePublisher: AnyPublisher<AppState, Never>
    private let dispatchClosure: (_ action: Action) -> Void

    init(statePublisher: AnyPublisher<AppState, Never>,
         dispatch: @escaping (Action) -> Void) {
        self.statePublisher = statePublisher
        self.dispatchClosure = dispatch
    }

    public func dispatch(_ action: Action) {
        dispatchClosure(action)
    }

}

