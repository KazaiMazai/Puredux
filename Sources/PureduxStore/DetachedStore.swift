//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.06.2022.
//

import Foundation

public class DetachedStore<RootState, LocalState, State, Action> {
    private static var queueLabel: String { "com.puredux.store" }

    private let localStore: InternalStore<LocalState, Action>
    private let rootStore: InternalStore<RootState, Action>

    private let stateMapping: (RootState, LocalState) -> State
    private var observers: Set<Observer<State>> = []

    private let queue: DispatchQueue

    init(initialState: LocalState,
         stateMapping: @escaping (RootState, LocalState) -> State,
         rootStore: InternalStore<RootState, Action>,
         qos: DispatchQoS = .userInteractive,
         reducer: @escaping Reducer<LocalState, Action>) {

        self.stateMapping = stateMapping
        localStore = InternalStore(queue: .global(qos: qos),
                                   initial: initialState,
                                   reducer: reducer)
        self.rootStore = rootStore
        if let interceptor = rootStore.interceptor {
            localStore.setInterceptor(with: interceptor.handler)
        }

        queue = DispatchQueue(label: Self.queueLabel, qos: qos)

        localStore.subscribe(observer: localStoreObserver)
        self.rootStore.subscribe(observer: rootStoreObserver)
    }
}

public extension DetachedStore {
    func dispatch(_ action: Action) {
        let scopedAction = localStore.scopeAction(action)
        localStore.dispatch(scopedAction)
        rootStore.dispatch(scopedAction)
    }

    func store() -> Store<State, Action> {
        Store(dispatch: { [weak self] in self?.dispatch($0) },
              subscribe: { [weak self] in self?.subscribe(observer: $0) })
    }
}

extension DetachedStore {
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
            let state = self.stateMapping(self.rootStore.currentState, self.localStore.currentState)
            self.send(state, to: observer)
        }
    }
}

private extension DetachedStore {
    var rootStoreObserver: Observer<RootState> {
        Observer { [weak self] rootState, handler in
            guard let self = self else {
                handler(.dead)
                return
            }

            self.queue.async { [weak self] in
                guard let self = self else {
                    handler(.dead)
                    return
                }

                self.observeStateUpdate(root: rootState, local: self.localStore.currentState)
            }
        }
    }

    var localStoreObserver: Observer<LocalState> {
        Observer { [weak self] localState, handler in
            guard let self = self else {
                handler(.dead)
                return
            }

            self.queue.async { [weak self] in
                guard let self = self else {
                    handler(.dead)
                    return
                }

                self.observeStateUpdate(root: self.rootStore.currentState, local: localState)
            }
        }
    }
}

private extension DetachedStore {
    func observeStateUpdate(root: RootState, local: LocalState) {
        let state = stateMapping(root, local)
        observers.forEach { send(state, to: $0) }
    }

     func send(_ state: State, to observer: Observer<State>) {
        observer.send(state) { [weak self] status in
            guard status == .dead else {
                return
            }

            self?.unsubscribe(observer: observer)
        }
    }
}
