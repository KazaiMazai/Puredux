//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import PureduxStore
import Combine
import SwiftUI

public class EnvironmentStore<AppState, Action>: ObservableObject {
    public var state: AppState { stateSubject.value }

    private let store: PureduxStore.Store<AppState, Action>
    public private(set) var stateSubject: CurrentValueSubject<AppState, Never>
    private let queue: DispatchQueue

    public init(store: PureduxStore.Store<AppState, Action>,
                queue: DispatchQueue = DispatchQueue(label: "EnvironmentStoreQueue", qos: .userInteractive)) {
        self.store = store
        self.stateSubject = CurrentValueSubject(store.state)
        self.queue = queue

        store.subscribe(observer: asObserver)
    }

    public func dispatch(_ action: Action) {
        store.dispatch(action: action)
    }

    private var asObserver: PureduxStore.Observer<AppState> {
        PureduxStore.Observer(queue: queue) { [weak self] in
            guard let self = self else {
                return .dead
            }

            self.stateSubject.send($0)
            return .active
        }
    }
}

