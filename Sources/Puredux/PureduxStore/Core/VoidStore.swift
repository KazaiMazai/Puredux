//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 22.02.2023.
//

import Foundation

struct VoidStore<Action>: StoreProtocol {
    let currentState: Void = Void()
    let actionsInterceptor: ActionsInterceptor<Action>?

    func dispatch(_ action: Action) { }

    func unsubscribe(observer: Observer<Void>) { }

    func subscribe(observer: Observer<()>, receiveCurrentState: Bool) { }

    func dispatch(scopedAction: ScopedAction<Action>) { }
}
