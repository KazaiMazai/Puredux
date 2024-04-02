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

    var currentState: State { get }

    var actionsInterceptor: ActionsInterceptor<Action>? { get }

    func unsubscribe(observer: Observer<State>)

    func subscribe(observer: Observer<State>, receiveCurrentState: Bool)

    func dispatch(scopedAction: ScopedAction<Action>)
}

extension StoreProtocol {
    func subscribe(observer: Observer<State>) {
        subscribe(observer: observer, receiveCurrentState: true)
    }
}
