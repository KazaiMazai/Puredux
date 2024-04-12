//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 12/04/2024.
//

import Foundation

struct ActionsMapping<ParentAction, ChildAction> {
    let parent: (ChildAction) -> ParentAction
    let local: (ParentAction) -> ChildAction
    
    static func equivalent<A>() -> ActionsMapping<A, A> {
        ActionsMapping<A, A>(
            parent: { $0 },
            local: { $0 }
        )
    }
}
