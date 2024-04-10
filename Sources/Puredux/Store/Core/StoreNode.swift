//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.11.2022.
//

import Foundation

typealias RootStoreNode<State, Action> = StoreNode<CoreStore<Void, Action>, State, State, Action>

final class StoreNode<ParentStore, LocalState, State, Action>
    where
    ParentStore: StoreProtocol,
    ParentStore.Action == Action {

    private static var queueLabel: String { "com.puredux.store" }

    private let localStore: CoreStore<LocalState, Action>
    private let parentStore: ParentStore
         
    private let stateMapping: (ParentStore.State, LocalState) -> State
    private var observers: Set<Observer<State>> = []
        
    lazy var parentStoreObserver: Observer<ParentStore.State> = {
        Observer(removeStateDuplicates: .neverEqual) { [weak self] parentState, handler in
            guard let self = self else {
                handler(.dead)
                return
            }

            guard let localState = self.localStoreObserver.state else {
                return
            }
            
            self.observeStateUpdate(root: parentState, local: localState)
        }
    }()

    lazy var localStoreObserver: Observer<LocalState> = {
        Observer(removeStateDuplicates: .neverEqual) { [weak self] localState, handler in
            guard let self = self else {
                handler(.dead)
                return
            }

//            guard let parentState = self.parentStoreObserver.state else {
//                return
//            }
//            
//            self.observeStateUpdate(root: parentState, local: localState)
        }
    }()
 
    init(initialState: LocalState,
         stateMapping: @escaping (ParentStore.State, LocalState) -> State,
         parentStore: ParentStore,
         qos: DispatchQoS = .userInteractive,
         reducer: @escaping Reducer<LocalState, Action>) {
 
        self.stateMapping = stateMapping
        self.parentStore = parentStore

        localStore = CoreStore(
            queue: parentStore.queue, 
            actionsInterceptor: nil,
            initialState: initialState,
            reducer: reducer
        )
       
        if let parentInterceptor = parentStore.actionsInterceptor {
            let interceptor = ActionsInterceptor(
                storeId: localStore.id,
                handler: parentInterceptor.handler,
                dispatcher: { [weak self] action in self?.dispatch(action) }
            )

            localStore.setInterceptor(interceptor)
        }
        
        localStore.subscribeSync(observer: localStoreObserver, receiveCurrentState: true)
        parentStore.subscribe(observer: parentStoreObserver, receiveCurrentState: true)
    }
}

extension StoreNode where LocalState == State {
    static func initRootStore(initialState: State,
                              interceptor: @escaping (Action, @escaping Dispatch<Action>) -> Void = { _, _ in },
                              qos: DispatchQoS = .userInteractive,
                              reducer: @escaping Reducer<State, Action>) -> RootStoreNode<State, Action> {

        RootStoreNode<State, Action>(
            initialState: initialState,
            stateMapping: { _, state in return state },
            parentStore: CoreStore<Void, Action>(
                queue: DispatchQueue(label: "com.puredux.store", qos: qos),
                actionsInterceptor: ActionsInterceptor(
                    storeId: StoreID(),
                    handler: interceptor,
                    dispatcher: { _ in }
                ),
                initialState: Void(),
                reducer: { _,_ in }
            ),
            reducer: reducer
        )
    }
}

extension StoreNode: StoreProtocol {
    
    var queue: DispatchQueue {
        parentStore.queue
    }
    
    var actionsInterceptor: ActionsInterceptor<Action>? {
        parentStore.actionsInterceptor
    }

    func dispatch(scopedAction: ScopedAction<Action>) {
        queue.async { [weak self] in
            self?.dispatchSync(scopedAction: scopedAction)
        }
    }
    
    func dispatchSync(scopedAction: ScopedAction<Action>) {
        localStore.dispatchSync(scopedAction: scopedAction)
        parentStore.dispatchSync(scopedAction: scopedAction)
    }

    func dispatch(_ action: Action) {
        dispatch(scopedAction: localStore.scopeAction(action))
    }

    func unsubscribe(observer: Observer<State>) {
        queue.async { [weak self] in
            self?.unsubscribeSync(observer: observer)
        }
    }
    
    func unsubscribeSync(observer: Observer<State>) {
        observers.remove(observer)
    }
    
    func subscribe(observer: Observer<State>) {
        subscribe(observer: observer, receiveCurrentState: true)
    }
    
    func subscribe(observer: Observer<State>, receiveCurrentState: Bool) {
        queue.async { [weak self] in
            self?.subscribeSync(observer: observer, receiveCurrentState: receiveCurrentState)
        }
    }
    
    func subscribeSync(observer: Observer<State>, receiveCurrentState: Bool) {
        observers.insert(observer)
        
        guard receiveCurrentState else {
            return
        }
        
        guard let parentState = parentStoreObserver.state,
            let localState = localStoreObserver.state
        else {
            return
        }
        
        let state = stateMapping(parentState, localState)
        send(state, to: observer)
    }
}

private extension StoreNode {
   
}

private extension StoreNode {
    func observeStateUpdate(root: ParentStore.State, local: LocalState) {
        let state = stateMapping(root, local)
        observers.forEach { send(state, to: $0) }
    }

    func send(_ state: State, to observer: Observer<State>) {
        observer.send(state) { [weak self] status in
            guard status == .dead else {
                return
            }

            self?.unsubscribeSync(observer: observer)
        }
    }
}
