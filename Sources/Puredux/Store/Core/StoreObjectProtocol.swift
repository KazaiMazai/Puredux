//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 22.02.2023.
//

import Foundation

protocol StoreObjectProtocol<State, Action>: AnyObject & SyncStoreProtocol {
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

extension StoreObjectProtocol {
    func weakRefStore() -> Store<State, Action> {
        Store(dispatcher: { [weak self] in self?.dispatch($0) },
              subscribe: { [weak self] in self?.subscribe(observer: $0) },
              storeObject: { [weak self] in self.map { AnyStoreObject($0) } }
        )
    }

    func stateStore() -> StateStore<State, Action> {
        StateStore<State, Action>(storeObject: self)
    }
}

extension StoreObjectProtocol {
    @available(*, deprecated, renamed: "createChildStore(stateStore:stateMapping:reducer:)", message: "qos parameter will have no effect. Root store's QoS is used.")
    func createChildStore<LocalState, ResultState>(
        initialState: LocalState,
        stateMapping: @escaping (Self.State, LocalState) -> ResultState,
        qos: DispatchQoS,
        reducer: @escaping Reducer<LocalState, Action>) -> any StoreObjectProtocol<ResultState, Action> {

            StoreNode<Self, LocalState, ResultState, Action>(
                initialState: initialState,
                stateMapping: stateMapping,
                parentStore: self,
                reducer: reducer
            )
        }
}

extension StoreObjectProtocol {
    func createChildStore<LocalState, ResultState>(
        initialState: LocalState,
        stateMapping: @escaping (Self.State, LocalState) -> ResultState,
        reducer: @escaping Reducer<LocalState, Action>) -> any StoreObjectProtocol<ResultState, Action> {

            StoreNode<Self, LocalState, ResultState, Action>(
                initialState: initialState,
                stateMapping: stateMapping,
                parentStore: self,
                reducer: reducer
            )
        }
    
    func createChildStore<T, LocalState>(
        initialState: LocalState,
        transform: @escaping (State) -> T,
        reducer: @escaping Reducer<LocalState, Action>) -> any StoreObjectProtocol<(T, LocalState), Action> {

            StoreNode(
                initialState: initialState,
                stateMapping: { (transform($0), $1) },
                parentStore: self,
                reducer: reducer
            )
        }
    
    func map<T>(transform: @escaping (State) -> T) -> any StoreObjectProtocol<T, Action> {
            StoreNode(
                initialState: Void(),
                stateMapping: { state, _ in transform(state) },
                parentStore: self,
                reducer: {_,_ in }
            )
        }
     
}
