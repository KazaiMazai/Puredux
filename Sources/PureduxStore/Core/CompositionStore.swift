//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.11.2022.
//

import Foundation

class CompositionStore<RootStore, LocalState, State, Action>
    where
    RootStore: StoreProtocol,
    RootStore.Action == Action {

    private static var queueLabel: String { "com.puredux.store" }

    private let localStore: CoreStore<LocalState, Action>
    private let rootStore: RootStore

    private let stateMapping: (RootStore.State, LocalState) -> State
    private var observers: Set<Observer<State>> = []

    private let queue: DispatchQueue

    init(initialState: LocalState,
         stateMapping: @escaping (RootStore.State, LocalState) -> State,
         rootStore: RootStore,
         qos: DispatchQoS = .userInteractive,
         reducer: @escaping Reducer<LocalState, Action>) {

        queue = DispatchQueue(label: Self.queueLabel, qos: qos)

        self.stateMapping = stateMapping
        self.rootStore = rootStore

        localStore = CoreStore(initialState: initialState,
                               reducer: reducer)

        if let rootInterceptor = rootStore.actionsInterceptor {
            let interceptor = ActionsInterceptor(
                storeId: localStore.id,
                handler: rootInterceptor.handler,
                dispatcher: { [weak self] action in self?.dispatch(action) }
            )

            localStore.setInterceptor(interceptor)
        }

        localStore.subscribe(observer: localStoreObserver, receiveCurrentState: false)
        self.rootStore.subscribe(observer: rootStoreObserver, receiveCurrentState: false)
    }
}

extension CompositionStore: StoreProtocol {
    var currentState: State {
        queue.sync {
            stateMapping(rootStore.currentState, localStore.currentState)
        }
    }

    var actionsInterceptor: ActionsInterceptor<Action>? {
        rootStore.actionsInterceptor
    }

    func dispatch(scopedAction: ScopedAction<Action>) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }

            self.localStore.dispatch(scopedAction: scopedAction)
            self.rootStore.dispatch(scopedAction: scopedAction)
        }
    }

    func dispatch(_ action: Action) {
        dispatch(scopedAction: localStore.scopeAction(action))
    }

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
            let state = self.stateMapping(self.rootStore.currentState, self.localStore.currentState)

            guard receiveCurrentState else { return }
            self.send(state, to: observer)
        }
    }
}

extension CompositionStore {
    var rootStoreObserver: Observer<RootStore.State> {
        Observer { [weak self] rootState, handler in
            guard let self = self else {
                handler(.dead)
                return
            }

            self.queue.async(flags: .barrier) { [weak self] in
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

            self.queue.async(flags: .barrier) { [weak self] in
                guard let self = self else {
                    handler(.dead)
                    return
                }

                self.observeStateUpdate(root: self.rootStore.currentState, local: localState)
            }
        }
    }
}

extension CompositionStore {
    func observeStateUpdate(root: RootStore.State, local: LocalState) {
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
