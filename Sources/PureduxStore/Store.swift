//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Dispatch

public final class Store<State, Action> {
    public typealias Reducer = (inout State, Action) -> Void

    private var state: State

    private let queue = DispatchQueue(label: "com.puredux.store", qos: .userInitiated)
    private let reducer: Reducer
    private var observers: Set<Observer<State>> = []

    public init(initial state: State, reducer: @escaping Reducer) {
        self.reducer = reducer
        self.state = state
    }

    public func dispatch(_ action: Action) {
        queue.async { [weak self] in
            guard let self = self else {
                return
            }

            self.reducer(&self.state, action)
            self.observers.forEach { self.notify($0, with: self.state) }
        }
    }

    public func subscribe(observer: Observer<State>) {
        queue.async { [weak self] in
            guard let self = self else {
                return
            }

            self.observers.insert(observer)
            self.notify(observer, with: self.state)
        }
    }
}

extension Store {
    private func unsubscribe(observer: Observer<State>) {
        queue.async { [weak self] in
            self?.observers.remove(observer)
        }
    }

    private func notify(_ observer: Observer<State>, with state: State) {
        observer.observe(state) { [weak self] status in
            guard status == .dead else {
                return
            }

            self?.unsubscribe(observer: observer)
        }

    }
}
