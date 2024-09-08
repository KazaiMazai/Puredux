//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 22.02.2023.
//

import Foundation

protocol StoreObjectProtocol<State, Action>: AnyObject, SyncStore, Sendable where Action: Sendable,
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
    func createChildStore<LocalState, ResultState>(
        initialState: LocalState,
        stateMapping: @Sendable @escaping (Self.State, LocalState) -> ResultState,
        reducer: @escaping Reducer<LocalState, Action>) -> any StoreObjectProtocol<ResultState, Action>
    
    where
    LocalState: Sendable,
    ResultState: Sendable {

            StoreNode<Self, LocalState, ResultState, Action>(
                initialState: initialState,
                stateMapping: stateMapping,
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
                parentStore: self,
                reducer: reducer
            )
        }

    func map<T: Sendable>(transform: @Sendable @escaping (State) -> T) -> any StoreObjectProtocol<T, Action> {
            StoreNode(
                initialState: Void(),
                stateMapping: { state, _ in transform(state) },
                parentStore: self,
                reducer: {_, _ in }
            )
        }
}
