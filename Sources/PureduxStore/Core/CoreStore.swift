//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Dispatch
import Foundation

public typealias Dispatch<Action> = (_ action: Action) -> Void
public typealias Interceptor<Action> = (Action, @escaping Dispatch<Action>) -> Void

typealias StoreID = UUID

final class CoreStore<State, Action> {

    let id: StoreID = StoreID()

    private static var queueLabel: String { "com.puredux.store" }

    private var state: State

    private let queue: DispatchQueue
    private var interceptor: ActionsInterceptor<Action>?
    private let reducer: Reducer<State, Action>
    private var observers: Set<Observer<State>> = []

    init(queue: StoreQueue = .global(),
         initialState: State, reducer: @escaping Reducer<State, Action>) {

        self.reducer = reducer
        self.state = initialState

        switch queue {
        case .main:
            self.queue = DispatchQueue.main
        case let .global(qos):
            self.queue = DispatchQueue(label: Self.queueLabel, qos: qos, attributes: .concurrent)
        }
    }
}

extension CoreStore {
    func weakRefStore() -> Store<State, Action> {
        Store(dispatch: { [weak self] in self?.dispatch($0) },
              subscribe: { [weak self] in self?.subscribe(observer: $0) })
    }
}

extension CoreStore {
    func setInterceptor(_ interceptor: ActionsInterceptor<Action>) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else {
                return
            }

            self.interceptor = interceptor
        }
    }

    func setInterceptor(with handler: @escaping Interceptor<Action>) {
        let interceptor = ActionsInterceptor(
            storeId: self.id,
            handler: handler,
            dispatcher: { [weak self] in self?.dispatch($0) })

        setInterceptor(interceptor)
    }

    func dispatch(_ action: Action) {
        scopeAndDispatch(action)
    }

    var currentState: State {
        queue.sync {
            state
        }
    }

    var actionsInterceptor: ActionsInterceptor<Action>? {
        queue.sync {
            interceptor
        }
    }
}

extension CoreStore {

    func unsubscribe(observer: Observer<State>) {
        queue.async(flags: .barrier) { [weak self] in
            self?.observers.remove(observer)
        }
    }

    func subscribe(observer: Observer<State>, receiveCurrentState: Bool = true) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else {
                return
            }

            self.observers.insert(observer)

            guard receiveCurrentState else { return }
            self.send(self.state, to: observer)
        }
    }
}

extension CoreStore {
    func scopeAction(_ action: Action) -> ScopedAction<Action> {
        ScopedAction(storeId: id, action: action)
    }

    private func scopeAndDispatch(_ action: Action) {
        dispatch(scopedAction: scopeAction(action))
    }

    func dispatch(scopedAction: ScopedAction<Action>) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else {
                return
            }

            self.interceptor?.interceptIfNeeded(scopedAction)

            self.reducer(&self.state, scopedAction.action)
            self.observers.forEach { self.send(self.state, to: $0) }
        }
    }
}

extension CoreStore {

    private func send(_ state: State, to observer: Observer<State>) {
        observer.send(state) { [weak self] status in
            guard status == .dead else {
                return
            }

            self?.unsubscribe(observer: observer)
        }
    }
}
