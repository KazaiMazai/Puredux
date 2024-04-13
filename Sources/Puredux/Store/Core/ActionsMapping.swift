//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 12/04/2024.
//

import Foundation

struct ActionsMapping<ParentAction, ChildAction> {
    let toParent: (ChildAction) -> ParentAction
    let toChild: (ParentAction) -> ChildAction
    
    static func passthrough<A>() -> ActionsMapping<A, A> {
        ActionsMapping<A, A>(
            toParent: { $0 },
            toChild: { $0 }
        )
    }
}
