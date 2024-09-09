//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 25/08/2024.
//

import Foundation
import Dispatch

/**
 A protocol that defines an asynchronous action that can be dispatched and executed on a specific `DispatchQueue`.

 Types conforming to `AsyncAction` represent actions that perform asynchronous tasks, such as network requests or long-running computations, and return a result upon completion.
 */
public protocol AsyncAction: Sendable {
    associatedtype ResultAction
    var dispatchQueue: DispatchQueue { get }
    func execute(completeHandler: @escaping (ResultAction) -> Void)
}

public extension AsyncAction {
    var dispatchQueue: DispatchQueue { .main }
}

extension AsyncAction {
    func execute<Action>(_ dispatch: @escaping Dispatch<Action>) {
        dispatchQueue.async {
            execute { result in
                guard let resultAction = result as? Action else {
                    return
                }
                dispatch(resultAction)
            }
        }
    }
}


protocol AsyncActionsExecutor {
    associatedtype Action
    
    func executeAsyncAction(_ action: Action) 
}
