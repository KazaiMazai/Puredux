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
    func proxy<LocalState>(
        toLocalState: @escaping (AppState) -> LocalState) -> PublishingStore<LocalState, Action> {

        PublishingStore<LocalState, Action>(
            statePublisher: statePublisher
                .map { toLocalState($0) }
                .eraseToAnyPublisher(),
            dispatch: dispatch)
    }
}
