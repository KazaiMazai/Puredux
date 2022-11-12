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

    func interceptIfNeeded(_ action: ScopedAction<Action>, dispatch: @escaping Dispatch<Action>) -> Void {
        guard action.storeId == storeId else { return }
        handler(action.action, dispatch)
    }

    func interceptor(with sourceId: UUID) -> ActionsInterceptor<Action> {
        ActionsInterceptor(storeId: sourceId, handler: handler)
    }
}
