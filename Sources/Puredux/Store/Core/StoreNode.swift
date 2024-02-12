//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.11.2022.
//

import Foundation

class StoreNode<ParentStore, LocalState, State, Action>
    where
    ParentStore: StoreProtocol,
    ParentStore.Action == Action {

    private static var queueLabel: String { "com.puredux.store" }

    private let localStore: CoreStore<LocalState, Action>
    private let parentStore: ParentStore

    private let stateMapping: (ParentStore.State, LocalState) -> State
    private var observers: Set<Observer<State>> = []

    private let queue: DispatchQueue

    init(initialState: LocalState,
         stateMapping: @escaping (ParentStore.State, LocalState) -> State,
         parentStore: ParentStore,
         qos: DispatchQoS = .userInteractive,
         reducer: @escaping Reducer<LocalState, Action>) {

        queue = DispatchQueue(label: Self.queueLabel, qos: qos)

        self.stateMapping = stateMapping
        self.parentStore = parentStore

        localStore = CoreStore(initialState: initialState,
                               reducer: reducer)

        if let parentInterceptor = parentStore.actionsInterceptor {
            let interceptor = ActionsInterceptor(
                storeId: localStore.id,
                handler: parentInterceptor.handler,
                dispatcher: { [weak self] action in self?.dispatch(action) }
            )

            localStore.setInterceptor(interceptor)
        }

        localStore.subscribe(observer: localStoreObserver, receiveCurrentState: false)
        self.parentStore.subscribe(observer: parentStoreObserver, receiveCurrentState: false)
    }
}

extension StoreNode: StoreProtocol {
    var currentState: State {
        queue.sync {
            stateMapping(parentStore.currentState, localStore.currentState)
        }
    }

    var actionsInterceptor: ActionsInterceptor<Action>? {
        parentStore.actionsInterceptor
    }

    func dispatch(scopedAction: ScopedAction<Action>) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }

            self.localStore.dispatch(scopedAction: scopedAction)
            self.parentStore.dispatch(scopedAction: scopedAction)
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
            let state = self.stateMapping(self.parentStore.currentState, self.localStore.currentState)

            guard receiveCurrentState else { return }
            self.send(state, to: observer)
        }
    }
}

extension StoreNode {
    var parentStoreObserver: Observer<ParentStore.State> {
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

                self.observeStateUpdate(root: self.parentStore.currentState, local: localState)
            }
        }
    }
}

extension StoreNode {
    func observeStateUpdate(root: ParentStore.State, local: LocalState) {
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
