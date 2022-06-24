//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.06.2022.
//

import Foundation

class DetachedStore<RootState, LocalState, State, Action> {
    private static var queueLabel: String { "com.puredux.store" }

    private let stateMapping: (RootState, LocalState) -> State
    private var lastState: LocalState

    private let localRootStore: RootStore<LocalState, Action>

    private let localStore: Store<LocalState, Action>
    private let rootStore: Store<RootState, Action>

    private var observers: Set<Observer<State>> = []

    private let queue: DispatchQueue

    init(initialState: LocalState,
         stateMapping: @escaping (RootState, LocalState) -> State,
         rootStore: Store<RootState, Action>,
         queue: StoreQueue = .global(qos: .userInteractive),
         reducer: @escaping Reducer<LocalState, Action>) {

        self.stateMapping = stateMapping
        self.lastState = initialState
        self.localRootStore = RootStore(queue: queue,
                                        initialState: initialState,
                                        reducer: reducer)
        self.rootStore = rootStore
        self.localStore = localRootStore.store()

        switch queue {
        case .main:
            self.queue = DispatchQueue.main
        case let .global(qos):
            self.queue = DispatchQueue(label: Self.queueLabel, qos: qos)
        }
    }
}

private extension DetachedStore {
    var rootStoreObserver: Observer<RootState> {
        Observer { [weak self] state, handler in
            guard let self = self else {
                handler(.dead)
                return
            }

            self.observe(state: state, complete: handler)
        }
    }

    func observe(state: RootState, complete: @escaping (ObserverStatus) -> Void) {
        let newState = stateMapping(state, lastState)
        observers.forEach { send(newState, to: $0) }
    }
}

private extension DetachedStore {
    var localStoreObserver: Observer<LocalState> {
        Observer { [weak self] state, handler in
            guard let self = self else {
                handler(.dead)
                return
            }

            self.observe(state: state, complete: handler)
        }
    }

    func observe(state: LocalState, complete: @escaping (ObserverStatus) -> Void) {
        lastState = state
    }
}

private extension DetachedStore {
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
//            self.send(self.state, to: observer)
        }
    }
}


extension DetachedStore {
    func dispatch(_ action: Action) {
        localStore.dispatch(action)
        rootStore.dispatch(action)
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
