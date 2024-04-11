//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 22.02.2023.
//

import Foundation

protocol StoreProtocol<State, Action>: AnyObject {
    associatedtype Action
    associatedtype State

    func dispatch(_ action: Action)
    
    var queue: DispatchQueue { get }

    var actionsInterceptor: ActionsInterceptor<Action>? { get }

    func unsubscribe(observer: Observer<State>)

    func subscribe(observer: Observer<State>, receiveCurrentState: Bool)

    func dispatch(scopedAction: ScopedAction<Action>)
    
    func subscribe(observer: Observer<State>)
    
    func unsubscribeSync(observer: Observer<State>)

    func subscribeSync(observer: Observer<State>, receiveCurrentState: Bool)

    func dispatchSync(scopedAction: ScopedAction<Action>)
    
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
    func createChildStore<LocalState, ResultState>(
        initialState: LocalState,
        stateMapping: @escaping (Self.State, LocalState) -> ResultState,
        qos: DispatchQoS,
        reducer: @escaping Reducer<LocalState, Action>) -> any StoreProtocol<ResultState, Action> {
            
            StoreNode<Self, LocalState, ResultState, Action>(
                initialState: initialState,
                stateMapping: stateMapping,
                parentStore: self,
                reducer: reducer
            )
        }
}
