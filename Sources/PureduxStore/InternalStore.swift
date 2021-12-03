//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Dispatch

final class InternalStore<State, Action> {
    public typealias Reducer = (inout State, Action) -> Void

    private var state: State

    private let queue: DispatchQueue
    private let reducer: Reducer
    private var observers: Set<Observer<State>> = []

    init(queue: StoreQueue,
         initial state: State, reducer: @escaping Reducer) {

        self.reducer = reducer
        self.state = state

        switch queue {
        case .main:
            self.queue = DispatchQueue.main
        case let .backgroundQueue(label, qos):
            self.queue = DispatchQueue(label: label, qos: qos)
        }
    }
}

extension InternalStore {
    
    func unsubscribe(observer: Observer<State>) {
        queue.async { [weak self] in
            self?.observers.remove(observer)
        }
    }

    func subscribe(observer: Observer<State>) {
        queue.async { [weak self] in
            guard let self = self else {
                return
            }

            self.observers.insert(observer)
            self.notify(observer, with: self.state)
        }
    }
}

extension InternalStore {
    func dispatch(_ action: Action) {
        queue.async { [weak self] in
            guard let self = self else {
                return
            }

            self.reducer(&self.state, action)
            self.observers.forEach { self.notify($0, with: self.state) }
        }
    }

    func notify(_ observer: Observer<State>, with state: State) {
        observer.send(state) { [weak self] status in
            guard status == .dead else {
                return
            }

            self?.unsubscribe(observer: observer)
        }
    }
}
