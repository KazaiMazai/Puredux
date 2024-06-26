//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.11.2022.
//

import Foundation

typealias VoidStore<Action> = CoreStore<Void, Action>

typealias RootStoreNode<State, Action> = StoreNode<VoidStore<Action>, State, State, Action>

final class StoreNode<ParentStore, LocalState, State, Action> where ParentStore: StoreProtocol {

    private let localStore: CoreStore<LocalState, Action>
    private let parentStore: ParentStore

    private let stateMapping: (ParentStore.State, LocalState) -> State
    private let actionsMapping: ActionsMapping<ParentStore.Action, Action>
    private var observers: Set<Observer<State>> = []

    init(initialState: LocalState,
         stateMapping: @escaping (ParentStore.State, LocalState) -> State,
         actionsMapping: ActionsMapping<ParentStore.Action, Action>,
         parentStore: ParentStore,
         reducer: @escaping Reducer<LocalState, Action>) {

        self.stateMapping = stateMapping
        self.actionsMapping = actionsMapping
        self.parentStore = parentStore

        localStore = CoreStore(
            queue: parentStore.queue,
            actionsInterceptor: nil,
            initialState: initialState,
            reducer: reducer
        )

        if let parentInterceptor = parentStore.actionsInterceptor {
            let interceptor = parentInterceptor.localInterceptor(
                localStore.id,
                actionsMapping: actionsMapping,
                dispatcher: { [weak self] action in
                    self?.dispatch(action)
                })
            
            localStore.setInterceptorSync(interceptor)
        }
        
        localStore.syncSubscribe(observer: localObserver, receiveCurrentState: true)
        parentStore.subscribe(observer: parentObserver, receiveCurrentState: true)
    }

    private lazy var parentObserver: Observer<ParentStore.State> = {
        Observer(self, removeStateDuplicates: .neverEqual) { [weak self] parentState, complete in
            guard let self else {
                complete(.dead)
                return
            }
            self.observe(parentState)
            complete(.active)
        }
    }()

    private lazy var localObserver: Observer<LocalState> = {
        Observer(self, removeStateDuplicates: .neverEqual) { [weak self] _, complete in
            guard let self else {
                complete(.dead)
                return
            }

            complete(.active)
        }
    }()
}

// MARK: - Root Store Init

extension StoreNode where LocalState == State {
    static func initRootStore(initialState: State,
                              interceptor: @escaping (Action, @escaping Dispatch<Action>) -> Void = { _, _ in },
                              qos: DispatchQoS = .userInteractive,
                              reducer: @escaping Reducer<State, Action>) -> RootStoreNode<State, Action> {

        RootStoreNode<State, Action>(
            initialState: initialState,
            stateMapping: { _, state in return state }, 
            actionsMapping: .passthrough(),
            parentStore: VoidStore<Action>(
                queue: DispatchQueue(label: "com.puredux.store", qos: qos),
                actionsInterceptor: ActionsInterceptor(
                    storeId: StoreID(),
                    handler: interceptor,
                    dispatcher: { _ in }
                ),
                initialState: Void(),
                reducer: { _, _ in }
            ),
            reducer: reducer
        )
    }
}

// MARK: - StoreProtocol Conformance

extension StoreNode: StoreProtocol {
    var queue: DispatchQueue {
        parentStore.queue
    }

    var actionsInterceptor: ActionsInterceptor<Action>? {
        localStore.actionsInterceptor
    }

    func syncDispatch(scopedAction: ScopedAction<Action>) {
        localStore.syncDispatch(scopedAction: scopedAction)
        parentStore.syncDispatch(scopedAction: ScopedAction(
            storeId: scopedAction.storeId,
            action: actionsMapping.toGlobal(scopedAction.action)
        ))
    }

    func dispatch(_ action: Action) {
        dispatch(scopedAction: localStore.scopeAction(action))
    }

    func dispatch(scopedAction: ScopedAction<Action>) {
        queue.async { [weak self] in
            self?.syncDispatch(scopedAction: scopedAction)
        }
    }

    func unsubscribe(observer: Observer<State>) {
        queue.async { [weak self] in
            self?.syncUnsubscribe(observer: observer)
        }
    }

    func syncUnsubscribe(observer: Observer<State>) {
        observers.remove(observer)
    }

    func subscribe(observer: Observer<State>) {
        subscribe(observer: observer, receiveCurrentState: true)
    }

    func subscribe(observer: Observer<State>, receiveCurrentState: Bool) {
        queue.async { [weak self] in
            self?.syncSubscribe(observer: observer, receiveCurrentState: receiveCurrentState)
        }
    }

    func syncSubscribe(observer: Observer<State>, receiveCurrentState: Bool) {
        observers.insert(observer)

        guard receiveCurrentState,
              let parentState = parentObserver.state,
              let localState = localObserver.state
        else {
            return
        }

        let state = stateMapping(parentState, localState)
        send(state, to: observer)
    }
}

// MARK: - Private

private extension StoreNode {
    func observe(_ parentState: ParentStore.State) {
        guard let localState = localObserver.state else {
            return
        }

        let state = stateMapping(parentState, localState)
        observers.forEach { send(state, to: $0) }
    }

    func send(_ state: State, to observer: Observer<State>) {
        observer.send(state) { [weak self] status in
            guard status == .dead else {
                return
            }

            self?.syncUnsubscribe(observer: observer)
        }
    }
}

