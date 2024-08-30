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

    let dispatchQueue: DispatchQueue
    private(set) var actionsInterceptor: ActionsInterceptor<Action>?
    private let reducer: Reducer<State, Action>
    private var observers: Set<Observer<State>> = []

    init(queue: DispatchQueue,
         actionsInterceptor: ActionsInterceptor<Action>?,
         initialState: State,
         reducer: @escaping Reducer<State, Action>) {

        self.dispatchQueue = queue
        self.actionsInterceptor = actionsInterceptor
        self.state = initialState
        self.reducer = reducer
    }
}

extension CoreStore {
    func weakRefStore() -> Store<State, Action> {
        Store(dispatcher: { [weak self] in self?.dispatch($0) },
              subscribe: { [weak self] in self?.subscribe(observer: $0) }, 
              storeObject: { [weak self] in self.map { AnyStoreObject($0) } })
    }
}

// MARK: - StoreProtocol Conformance

extension CoreStore: StoreObjectProtocol {
    // MARK: - DispatchQueue

    var queue: DispatchQueue {
        dispatchQueue
    }

    // MARK: - Interceptor

    func setInterceptor(_ interceptor: ActionsInterceptor<Action>) {
        queue.async { [weak self] in
            self?.setInterceptorSync(interceptor)
        }
    }

    func setInterceptor(with handler: @escaping Interceptor<Action>) {
        let interceptor = ActionsInterceptor(
            storeId: self.id,
            handler: handler,
            dispatcher: { [weak self] in self?.dispatch($0) })

        setInterceptor(interceptor)
    }

    func setInterceptorSync(_ interceptor: ActionsInterceptor<Action>) {
        self.actionsInterceptor = interceptor
    }

    // MARK: - Subscribe

    func unsubscribe(observer: Observer<State>) {
        queue.async { [weak self] in
            self?.syncUnsubscribe(observer: observer)
        }
    }

    func subscribe(observer: Observer<State>) {
        subscribe(observer: observer, receiveCurrentState: true)
    }

    func subscribe(observer: Observer<State>, receiveCurrentState: Bool = true) {
        queue.async { [weak self] in
            self?.syncSubscribe(observer: observer, receiveCurrentState: receiveCurrentState)
        }
    }

    func syncUnsubscribe(observer: Observer<State>) {
        observers.remove(observer)
    }

    func syncSubscribe(observer: Observer<State>, receiveCurrentState: Bool) {
        observers.insert(observer)
        guard receiveCurrentState else { return }
        send(self.state, to: observer)
    }

    // MARK: - Dispatch

    func scopeAction(_ action: Action) -> ScopedAction<Action> {
        ScopedAction(storeId: id, action: action)
    }

    func dispatch(scopedAction: ScopedAction<Action>) {
        queue.async { [weak self] in
            self?.syncDispatch(scopedAction: scopedAction)
        }
    }

    func dispatch(_ action: Action) {
        dispatch(scopedAction: scopeAction(action))
    }

    func syncDispatch(scopedAction: ScopedAction<Action>) {
        actionsInterceptor?.interceptIfNeeded(scopedAction)
        reducer(&self.state, scopedAction.action)
        observers.forEach { send(state, to: $0) }
    }
}

// MARK: - Private

private extension CoreStore {

    func send(_ state: State, to observer: Observer<State>) {
        observer.send(state) { [weak self] status in
            guard status == .dead else {
                return
            }

            self?.syncUnsubscribe(observer: observer)
        }
    }
}
