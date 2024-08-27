//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 27/08/2024.
//

import SwiftUI

public extension View {
    func subscribe<State, Action, Props>(store: Store<State, Action>,
                                         props: @escaping (State, Store<State, Action>) -> Props,
                                         presentationQueue: DispatchQueue = .sharedPresentationQueue,
                                         removeStateDuplicates equating: Equating<State>? = nil,
                                         observe: @escaping (Props) -> Void) -> some View {
        createObserver{ stateObserver in
            stateObserver.subscribe(
                store: store,
                props: props,
                presentationQueue: presentationQueue,
                removeStateDuplicates: equating,
                observe: observe
            )
        }
    }
    
    func subscribe<State, Action, Props>(_ store: Store<State, Action>,
                                         props: @escaping (State, @escaping Dispatch<Action>) -> Props,
                                         presentationQueue: DispatchQueue = .sharedPresentationQueue,
                                         removeStateDuplicates equating: Equating<State>? = nil,
                                         observe: @escaping (Props) -> Void) -> some View {
        createObserver { stateObserver in
            stateObserver.subscribe(
                store,
                props: props,
                presentationQueue: presentationQueue,
                removeStateDuplicates: equating,
                observe: observe
            )
        }
    }
    
    func subscribe<State, Action>(_ store: Store<State, Action>,
                                  removeStateDuplicates equating: Equating<State>? = nil,
                                  observe: @escaping (State) -> Void) -> some View {
        createObserver { stateObserver in
            stateObserver.subscribe(
                store,
                removeStateDuplicates: equating,
                observe: observe
            )
        }
    }
    
    func subscribe<State, Action>(_ store: Store<State, Action>,
                                  removeStateDuplicates equating: Equating<State>? = nil,
                                  observe: @escaping (State, Dispatch<Action>) -> Void) -> some View {
        
        createObserver { stateObserver in
            stateObserver.subscribe(
                store,
                removeStateDuplicates: equating,
                observe: observe
            )
        }
    }
    
    func subscribe<State, Action>(store: Store<State, Action>,
                                  removeStateDuplicates equating: Equating<State>? = nil,
                                  observe: @escaping (State, Store<State, Action>) -> Void) -> some View {
        
        createObserver { stateObserver in
            stateObserver.subscribe(
                store: store,
                removeStateDuplicates: equating,
                observe: observe
            )
        }
    }
}

public extension View {
    func subscribe<State, Action, Props>(store: StateStore<State, Action>,
                                         props: @escaping (State, Store<State, Action>) -> Props,
                                         presentationQueue: DispatchQueue = .sharedPresentationQueue,
                                         removeStateDuplicates equating: Equating<State>? = nil,
                                         observe: @escaping (Props) -> Void) -> some View {
        subscribe(
            store: store.strongStore(),
            props: props,
            presentationQueue: presentationQueue,
            removeStateDuplicates: equating,
            observe: observe
        )
    }
    
    func subscribe<State, Action, Props>(_ store: StateStore<State, Action>,
                                         props: @escaping (State, @escaping Dispatch<Action>) -> Props,
                                         presentationQueue: DispatchQueue = .sharedPresentationQueue,
                                         removeStateDuplicates equating: Equating<State>? = nil,
                                         observe: @escaping (Props) -> Void) -> some View {
        subscribe(
            store.strongStore(),
            props: props,
            presentationQueue: presentationQueue,
            removeStateDuplicates: equating,
            observe: observe
        )
    }
    
    func subscribe<State, Action>(_ store: StateStore<State, Action>,
                                  removeStateDuplicates equating: Equating<State>? = nil,
                                  observe: @escaping (State) -> Void) -> some View {
        subscribe(
            store.strongStore(),
            removeStateDuplicates: equating,
            observe: observe
        )
    }
    
    func subscribe<State, Action>(_ store: StateStore<State, Action>,
                                  removeStateDuplicates equating: Equating<State>? = nil,
                                  observe: @escaping (State, Dispatch<Action>) -> Void) -> some View {
        
        subscribe(
            store.strongStore(),
            removeStateDuplicates: equating,
            observe: observe
        )
    }
    
    func subscribe<State, Action>(store: StateStore<State, Action>,
                                  removeStateDuplicates equating: Equating<State>? = nil,
                                  observe: @escaping (State, Store<State, Action>) -> Void) -> some View {
        
        subscribe(
            store: store.strongStore(),
            removeStateDuplicates: equating,
            observe: observe
        )
    }
}
