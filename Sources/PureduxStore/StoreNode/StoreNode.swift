//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.11.2022.
//

import Foundation


class StoreNode<RootStore, LocalState, State, Action>
    where
    RootStore: StoreProtocol,
    RootStore.Action == Action {

    private static var queueLabel: String { "com.puredux.store" }

    private let localStore: InternalStore<LocalState, Action>
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

        localStore = InternalStore(queue: .global(qos: qos),
                                   initial: initialState,
                                   reducer: reducer)

        if let rootInterceptor = rootStore.actionsInterceptor {
            let interceptor = ActionsInterceptor(
                storeId: localStore.id,
                handler: rootInterceptor.handler,
                dispatcher: { [weak self] action in self?.dispatch(action) }
            )

            localStore.setInterceptor(interceptor)
        }

        localStore.subscribe(observer: localStoreObserver)
        self.rootStore.subscribe(observer: rootStoreObserver)
    }
}

typealias RootStoreNode<State, Action> = StoreNode<VoidStore<Action>, State, State, Action>

extension StoreNode where LocalState == State {
    static func root(initialState: State,
                     interceptor: @escaping (Action, @escaping Dispatch<Action>) -> Void = { _, _ in },
                     qos: DispatchQoS = .userInteractive,
                     reducer: @escaping Reducer<State, Action>) -> RootStoreNode<State, Action> {

        RootStoreNode<State, Action>(
            initialState: initialState,
            stateMapping: { _, state in return state },
            rootStore: VoidStore<Action>(
                actionsInterceptor: ActionsInterceptor(
                    storeId: StoreID(),
                    handler: interceptor,
                    dispatcher: { _ in }
                )
            ),
            reducer: reducer
        )
    }
}

extension StoreNode {
    func store() -> Store<State, Action> {
        Store(dispatch: { [weak self] in self?.dispatch($0) },
              subscribe: { [weak self] in self?.subscribe(observer: $0) })
    }

    func strongRefStore() -> Store<State, Action> {
        Store(dispatch: { self.dispatch($0) },
              subscribe: { self.subscribe(observer: $0) })
    }

    func node<NodeState, ResultState>(initialState: NodeState,
                                      stateMapping: @escaping (State, NodeState) -> ResultState,
                                      qos: DispatchQoS = .userInteractive,
                                      reducer: @escaping Reducer<NodeState, Action>) ->

    StoreNode<StoreNode<RootStore, LocalState, State, Action>, NodeState, ResultState, Action> {

        StoreNode<StoreNode<RootStore, LocalState, State, Action>, NodeState, ResultState, Action>(
            initialState: initialState,
            stateMapping: stateMapping,
            rootStore: self,
            reducer: reducer
        )
    }
}

extension StoreNode: StoreProtocol {
    var currentState: State {
        stateMapping(rootStore.currentState, localStore.currentState)
    }

    var actionsInterceptor: ActionsInterceptor<Action>? {
        rootStore.actionsInterceptor
    }

    func dispatch(_ scopedAction: InterceptableAction<Action>) {
        localStore.dispatch(scopedAction)
        rootStore.dispatch(scopedAction)
    }

    func dispatch(_ action: Action) {
        let scopedAction = localStore.scopeAction(action)
        localStore.dispatch(scopedAction)
        rootStore.dispatch(scopedAction)
    }

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

extension StoreNode {
    var rootStoreObserver: Observer<RootStore.State> {
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

extension StoreNode {
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

struct VoidStore<Action>: StoreProtocol {
    let currentState: Void = Void()
    let actionsInterceptor: ActionsInterceptor<Action>?

    func dispatch(_ action: Action) {

    }

    func unsubscribe(observer: Observer<Void>) {

    }

    func subscribe(observer: Observer<Void>) {

    }

    func dispatch(_ scopedAction: InterceptableAction<Action>) {

    }
}

