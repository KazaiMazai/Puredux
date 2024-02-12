//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 12.11.2022.
//

import Foundation

struct ScopedAction<Action> {
    let storeId: StoreID
    let action: Action
}

struct ActionsInterceptor<Action> {
    let storeId: StoreID
    let handler: (Action, @escaping Dispatch<Action>) -> Void
    let dispatcher: Dispatch<Action>

    func interceptIfNeeded(_ action: ScopedAction<Action>) {
        guard action.storeId == storeId else { return }
        handler(action.action, dispatcher)
    }
}
