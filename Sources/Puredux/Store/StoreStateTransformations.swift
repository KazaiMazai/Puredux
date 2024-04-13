//
//  File.swift
//
//
//  Created by Sergey Kazakov on 04/04/2024.
//

import Foundation

extension Store {
    func map<T>(_ transform: @escaping (State) -> T) -> Store<T, Action> {
        Store<T, Action>(
            dispatcher: dispatch,
            subscribe: { localStateObserver in
                subscribe(observer: Observer<State>(id: localStateObserver.id) { state, complete in
                    let localState = transform(state)
                    localStateObserver.send(localState, complete: complete)
                })
            }
        )
    }

    func compactMap<T>(_ transform: @escaping (State) -> T?) -> Store<T, Action> {
        Store<T, Action>(
            dispatcher: dispatch,
            subscribe: { localStateObserver in
                subscribe(observer: Observer<State>(id: localStateObserver.id) { state, complete in
                    guard let localState = transform(state) else {
                        complete(.active)
                        return
                    }

                    localStateObserver.send(localState, complete: complete)
                })
            }
        )
    }

    func flatMap<T>(_ transform: @escaping (State) -> T?) -> Store<T?, Action> {
        Store<T?, Action>(
            dispatcher: dispatch,
            subscribe: { localStateObserver in
                subscribe(observer: Observer<State>(id: localStateObserver.id) { state, complete in
                    let localState = transform(state)
                    localStateObserver.send(localState, complete: complete)
                })
            }
        )
    }
}

extension Store {
    func map<T>(_ keyPath: KeyPath<State, T>) -> Store<T, Action> {
        map { $0[keyPath: keyPath] }
    }

    func compactMap<T>(_ keyPath: KeyPath<State, T?>) -> Store<T, Action> {
        compactMap { $0[keyPath: keyPath] }
    }

    func flatMap<T>(_ keyPath: KeyPath<State, T?>) -> Store<T?, Action> {
        flatMap { $0[keyPath: keyPath] }
    }
}

extension StateStore {
    func map<T>(_ keyPath: KeyPath<State, T>) -> Store<T, Action> {
        strongStore().map(keyPath)
    }
    
    func compactMap<T>(_ keyPath: KeyPath<State, T?>) -> Store<T, Action> {
        strongStore().compactMap(keyPath)
    }
 
    func flatMap<T>(_ keyPath: KeyPath<State, T?>) -> Store<T?, Action> {
        strongStore().flatMap(keyPath)
    }
}

extension StateStore {
    func map<T>(_ transform: @escaping (State) -> T) -> Store<T, Action> {
        strongStore().map(transform)
    }

     
    func compactMap<T>(_ transform: @escaping (State) -> T?) -> Store<T, Action> {
        strongStore().compactMap(transform)
    }
 
    func flatMap<T>(_ transform: @escaping (State) -> T?) -> Store<T?, Action> {
        strongStore().flatMap(transform)
    }
}
