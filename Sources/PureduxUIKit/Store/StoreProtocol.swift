//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.06.2021.
//

import Foundation
import PureduxStore
//
//public protocol StoreProtocol {
//    associatedtype State
//    associatedtype Action
//
//    func dispatch(_ action: Action)
//
//    func subscribe(observer: Observer<State>)
//}
//
//extension PureduxStore.Store: PureduxStore.Store {
//
//}
//
//extension PureduxStore.Store {
//    func proxy<LocalState>(_ localState: @escaping (State) -> LocalState) -> AnyStore<LocalState, Action> {
//
//        StoreProxy(store: self,
//                   toLocalState: localState).eraseToAnyStore()
//    }
//
//    func eraseToAnyStore() -> AnyStore<State, Action> {
//        AnyStore(dispatch: { self.dispatch($0) } ,
//                 subscribe: { self.subscribe(observer: $0) })
//    }
//}
//
//extension StoreProtocol {
//    func proxy<LocalState>(_ localState: @escaping (State) -> LocalState) -> AnyStore<LocalState, Action> {
//
//        StoreProxy(store: self,
//                   toLocalState: localState).eraseToAnyStore()
//    }
//}
//
//public struct AnyStore<State, Action>: StoreProtocol {
//    public func dispatch(_ action: Action) {
//        dispatch(action)
//    }
//
//    public func subscribe(observer: Observer<State>) {
//        subscribe(observer)
//    }
//
//    let dispatch: (_ action: Action) -> Void
//    let subscribe: (_ observer: Observer<State>) -> Void
//}

