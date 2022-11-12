//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 12.11.2022.
//

import Foundation

struct ActionsInterceptor<Action> {
    let sourceId: UUID
    let handler: (Action, @escaping Dispatch<Action>) -> Void

    func intercept(_ action: SourcedAction<Action>, dispatch: @escaping Dispatch<Action>) -> Void {
        guard action.sourceId == sourceId else { return }
        handler(action.action, dispatch)
    }

    func interceptor(with sourceId: UUID) -> ActionsInterceptor<Action> {
        ActionsInterceptor(sourceId: sourceId, handler: handler)
    }
}
