//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.05.2021.
//

import Foundation
import Combine

public protocol ObservableStoreProtocol {
    associatedtype AppState
    associatedtype Action

    var statePublisher: AnyPublisher<AppState, Never> { get }

    func dispatch(_ action: Action)
}

extension ObservableStoreProtocol {
    func proxy<LocalState>(
        localState: @escaping (AppState) -> LocalState) -> some ObservableStoreProtocol {

        ObservableStoreProxy(
            store: self,
            toLocalState: localState)
    }
}



