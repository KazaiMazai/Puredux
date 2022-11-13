//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 12.11.2022.
//

import Foundation

struct InterceptableAction<Action> {
    let storeId: StoreID
    let action: Action
}

struct ActionsInterceptor<Action> {
    let storeId: StoreID
    let handler: (Action, @escaping Dispatch<Action>) -> Void
    let dispatcher: Dispatch<Action>

    func interceptIfNeeded(_ action: InterceptableAction<Action>) -> Void {
        interceptIfNeeded(action, dispatch: dispatcher)
    }

    func interceptor(with sourceId: UUID, dispatcher: @escaping Dispatch<Action>) -> ActionsInterceptor<Action> {
        ActionsInterceptor(storeId: sourceId, handler: handler, dispatcher: dispatcher)
    }
}

extension ActionsInterceptor {
    private func interceptIfNeeded(_ action: InterceptableAction<Action>,
                                   dispatch: @escaping Dispatch<Action>) -> Void {
        guard action.storeId == storeId else { return }
        handler(action.action, dispatch)
    }

}
