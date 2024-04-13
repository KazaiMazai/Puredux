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

struct ActionsMapping<GlobalAction, LocalAction> {
    let toGlobal: (LocalAction) -> GlobalAction
    let toLocal: (GlobalAction) -> LocalAction
    
    static func passthrough<A>() -> ActionsMapping<A, A> {
        ActionsMapping<A, A>(
            toGlobal: { $0 },
            toLocal: { $0 }
        )
    }
}

struct ActionsInterceptor<Action> {
    let storeId: StoreID
    let handler: (Action, @escaping Dispatch<Action>) -> Void
    let dispatcher: Dispatch<Action>

    func interceptIfNeeded(_ action: ScopedAction<Action>) {
        guard action.storeId == storeId else { return }
        handler(action.action, dispatcher)
    }
    
    func localInterceptor<LocalAction>(_ localStoreId: StoreID,
                                       actionsMapping: ActionsMapping<Action, LocalAction>,
                                       dispatcher: @escaping Dispatch<LocalAction>
    ) -> ActionsInterceptor<LocalAction> {
        
        ActionsInterceptor<LocalAction>(
            storeId: localStoreId,
            handler: { action, dispatcher in
                handler(
                    actionsMapping.toGlobal(action),
                    { dispatcher(actionsMapping.toLocal($0)) }
                )
            },
            dispatcher: { action in
                dispatcher(action)
            }
        )
    }
}
