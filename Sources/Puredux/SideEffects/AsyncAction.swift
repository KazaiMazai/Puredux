//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 25/08/2024.
//

import Foundation
import Dispatch

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
