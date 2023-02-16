//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 16.02.2023.
//

import Foundation

protocol StoreProtocol {
    associatedtype Action
    associatedtype State

    func dispatch(_ action: Action)

    var currentState: State { get }

    var actionsInterceptor: ActionsInterceptor<Action>? { get }

    func unsubscribe(observer: Observer<State>)

    func subscribe(observer: Observer<State>)

    func dispatch(_ scopedAction: InterceptableAction<Action>)
}
