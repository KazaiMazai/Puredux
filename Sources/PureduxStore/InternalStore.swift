//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Dispatch

final class InternalStore<State, Action> {
    private static var queueLabel: String { "com.puredux.store" }

    private var state: State

    private let queue: DispatchQueue
    private var willReduce: Interceptor<Action>?
    private let reducer: Reducer<State, Action>
    private var observers: Set<Observer<State>> = []

    init(queue: StoreQueue,
         initial state: State, reducer: @escaping Reducer<State, Action>) {

        self.reducer = reducer
        self.state = state

        switch queue {
        case .main:
            self.queue = DispatchQueue.main
        case let .global(qos):
            self.queue = DispatchQueue(label: Self.queueLabel, qos: qos)
        }
    }
}

extension InternalStore {
    func interceptActions(with interceptor: @escaping Interceptor<Action>) {
        queue.async { [weak self] in
            self?.willReduce = interceptor
        }
    }

    private func unsubscribe(observer: Observer<State>) {
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
            self.send(self.state, to: observer)
        }
    }
}

extension InternalStore {
    func dispatch(_ action: Action) {
        queue.async { [weak self] in
            guard let self = self else {
                return
            }

            self.willReduce?(action)
            self.reducer(&self.state, action)
            self.observers.forEach { self.send(self.state, to: $0) }
        }
    }

    private func send(_ state: State, to observer: Observer<State>) {
        observer.send(state) { [weak self] status in
            guard status == .dead else {
                return
            }

            self?.unsubscribe(observer: observer)
        }
    }
}
