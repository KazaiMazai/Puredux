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

    private let reducer: Reducer<State, Action>
    private var observers: Set<Observer<State>> = []

    init(queue: DispatchQueue,
         initialState: State,
         reducer: @escaping Reducer<State, Action>) {

        self.dispatchQueue = queue
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

    func dispatch(_ action: Action) {
        queue.async { [weak self] in
            self?.syncDispatch(action)
        }
    }

    func syncDispatch(_ action: Action) {
        reducer(&self.state, action)
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
