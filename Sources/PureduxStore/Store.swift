//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Dispatch

public class Store<State, Action> {
    public typealias Reducer = (inout State, Action) -> Void
    public private(set) var state: State

    private let queue = DispatchQueue(label: "Store serial queue", qos: .userInitiated)
    private let reducer: Reducer
    private var observers: Set<Observer<State>> = []

    public init(initial state: State, reducer: @escaping Reducer) {
        self.reducer = reducer
        self.state = state
    }

    public func dispatch(action: Action) {
        queue.async { [weak self] in
            guard let self = self else {
                return
            }

            self.reducer(&self.state, action)
            self.observers.forEach { self.notify($0) }
        }
    }

    public func subscribe(observer: Observer<State>) {
        queue.async {
            self.observers.insert(observer)
            self.notify(observer)
        }
    }
}

extension Store {
    private func notify(_ observer: Observer<State>) {
        let status = observer.observe(state)
        if status == .dead {
            observers.remove(observer)
        }
    }
}
