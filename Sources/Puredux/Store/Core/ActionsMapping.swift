//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 12/04/2024.
//

import Foundation

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
