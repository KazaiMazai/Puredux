//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 22.02.2023.
//

import Foundation

protocol StoreProtocol<State, Action>: AnyObject & SyncStoreProtocol {
    associatedtype Action
    associatedtype State

    func dispatch(_ action: Action)

    var queue: DispatchQueue { get }

    var actionsInterceptor: ActionsInterceptor<Action>? { get }

    func unsubscribe(observer: Observer<State>)

    func subscribe(observer: Observer<State>, receiveCurrentState: Bool)

    func dispatch(scopedAction: ScopedAction<Action>)

    func subscribe(observer: Observer<State>)
}

protocol SyncStoreProtocol<State, Action> {
    associatedtype Action
    associatedtype State

    func syncUnsubscribe(observer: Observer<State>)

    func syncSubscribe(observer: Observer<State>, receiveCurrentState: Bool)

    func syncDispatch(scopedAction: ScopedAction<Action>)
}

extension StoreProtocol {
    func weakRefStore() -> Store<State, Action> {
        Store(dispatcher: { [weak self] in self?.dispatch($0) },
              subscribe: { [weak self] in self?.subscribe(observer: $0) }
        )
    }

    func stateStore() -> StateStore<State, Action> {
        StateStore<State, Action>(storeObject: self)
    }
}

extension StoreProtocol {
    @available(*, deprecated, renamed: "createChildStore(stateStore:stateMapping:reducer:)", message: "qos parameter will have no effect. Root store's QoS is used.")
    func createChildStore<LocalState, ResultState>(
        initialState: LocalState,
        stateMapping: @escaping (Self.State, LocalState) -> ResultState,
        qos: DispatchQoS,
        reducer: @escaping Reducer<LocalState, Action>) -> any StoreProtocol<ResultState, Action> {

            StoreNode<Self, LocalState, ResultState, Action>(
                initialState: initialState,
                stateMapping: stateMapping, 
                actionsMapping: .passthrough(),
                parentStore: self,
                reducer: reducer
            )
        }
}

extension StoreProtocol {
    func createChildStore<LocalState, ResultState>(
        initialState: LocalState,
        stateMapping: @escaping (Self.State, LocalState) -> ResultState,
        reducer: @escaping Reducer<LocalState, Action>) -> any StoreProtocol<ResultState, Action> {

            StoreNode<Self, LocalState, ResultState, Action>(
                initialState: initialState,
                stateMapping: stateMapping, 
                actionsMapping: .passthrough(),
                parentStore: self,
                reducer: reducer
            )
        }
    
    func createChildStore<LocalState, ResultState, LocalAction>(
        initialState: LocalState,
        stateMapping: @escaping (Self.State, LocalState) -> ResultState,
        actionsMapping: ActionsMapping<Action, LocalAction>,
        reducer: @escaping Reducer<LocalState, LocalAction>) -> any StoreProtocol<ResultState, LocalAction> {

            StoreNode<Self, LocalState, ResultState, LocalAction>(
                initialState: initialState,
                stateMapping: stateMapping,
                actionsMapping: actionsMapping,
                parentStore: self,
                reducer: reducer
            )
        }
}
