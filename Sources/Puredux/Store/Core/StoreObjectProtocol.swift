//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 22.02.2023.
//

import Foundation

protocol StoreObjectProtocol<State, Action>: AnyObject, SyncStore where Action: Sendable,
                                                                        State: Sendable {
    associatedtype Action
    associatedtype State

    func dispatch(_ action: Action)

    var queue: DispatchQueue { get }

    func unsubscribe(observer: Observer<State>)

    func subscribe(observer: Observer<State>, receiveCurrentState: Bool)

    func subscribe(observer: Observer<State>)
}

protocol SyncStore<State, Action> {
    associatedtype Action
    associatedtype State

    func syncUnsubscribe(observer: Observer<State>)

    func syncSubscribe(observer: Observer<State>, receiveCurrentState: Bool)

    func syncDispatch(_  action: Action)
}

extension StoreObjectProtocol {
    func createChildStore<LocalState, ResultState, LocalAction>(
        initialState: LocalState,
        stateMapping: @Sendable @escaping (Self.State, LocalState) -> ResultState,
        actionMapping: @Sendable @escaping (LocalAction) -> Action,
        reducer: @escaping Reducer<LocalState, LocalAction>) -> any StoreObjectProtocol<ResultState, LocalAction>
    
    where
    LocalState: Sendable,
    ResultState: Sendable,
    LocalAction: Sendable {

            StoreNode<Self, LocalState, ResultState, LocalAction>(
                initialState: initialState,
                stateMapping: stateMapping, 
                actionMapping: actionMapping,
                parentStore: self,
                reducer: reducer
            )
        }

    func createChildStore<T, LocalState>(
        initialState: LocalState,
        transform: @Sendable @escaping (State) -> T,
        reducer: @escaping Reducer<LocalState, Action>) -> any StoreObjectProtocol<(T, LocalState), Action>
        
    where
    LocalState: Sendable,
    T: Sendable {

            StoreNode(
                initialState: initialState,
                stateMapping: { (transform($0), $1) },
                actionMapping: { $0 },
                parentStore: self,
                reducer: reducer
            )
        }

    func map<T: Sendable>(transformState: @Sendable @escaping (State) -> T) -> any StoreObjectProtocol<T, Action> {
            StoreNode(
                initialState: Void(),
                stateMapping: { state, _ in transformState(state) },
                actionMapping: { $0 },
                parentStore: self,
                reducer: { _, _ in }
            )
        }
    
    func map<A: Sendable>(transformActions: @Sendable @escaping (A) -> Action) -> any StoreObjectProtocol<State, A> {
            StoreNode<Self, Void, State, A>(
                initialState: Void(),
                stateMapping: { state, _ in state },
                actionMapping: transformActions,
                parentStore: self,
                reducer: { _, _ in }
            )
        }
}
