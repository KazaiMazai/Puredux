//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2021.
//

import Foundation

public struct Store<State, Action> {
    private let dispatch: (_ action: Action) -> Void
    private let subscribe: (_ observer: Observer<State>) -> Void

    public func dispatch(_ action: Action) {
        dispatch(action)
    }

    public func subscribe(observer: Observer<State>) {
        subscribe(observer)
    }

    public init(dispatch: @escaping (Action) -> Void,
                subscribe: @escaping (Observer<State>) -> Void) {
        self.dispatch = dispatch
        self.subscribe = subscribe
    }
}

public extension Store {
    func proxy<LocalState>(_ toLocalState: @escaping (State) -> LocalState) -> Store<LocalState, Action> {
        Store<LocalState, Action>(
            dispatch: dispatch,
            subscribe: { localStateObserver in
                subscribe(observer: Observer<State>(
                    id: localStateObserver.id) { state, complete in
                    
                    localStateObserver.send(toLocalState(state), complete: complete)
                })
            })
    }
}


