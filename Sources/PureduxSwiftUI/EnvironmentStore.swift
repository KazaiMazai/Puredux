//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import PureduxStore
import Combine
import SwiftUI

public class EnvironmentStore<State, Action>: ObservableObject {
    private let store: PureduxStore.Store<State, Action>
    var state: State { stateSubject.value }

    private(set) var stateSubject: CurrentValueSubject<State, Never>
    private let queue: DispatchQueue = DispatchQueue(label: "EnvironmentStoreQueue", qos: .userInteractive)

    public init(store: PureduxStore.Store<State, Action>) {
        self.store = store
        self.stateSubject = CurrentValueSubject(store.state)

        store.subscribe(observer: asObserver)
    }

    public func dispatch(_ action: Action) {
        store.dispatch(action: action)
    }

    private var asObserver: PureduxStore.Observer<State> {
        PureduxStore.Observer(queue: queue) { [weak self] in
            guard let self = self else {
                return .dead
            }

            self.stateSubject.send($0)
            return .active
        }
    }
}
