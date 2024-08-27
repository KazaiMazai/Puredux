//
//  File.swift
//
//
//  Created by Sergey Kazakov on 21/08/2024.
//

import SwiftUI


extension View {
    func forEachEffect<ViewState, Action, Effects>(
        on store: Store<ViewState, Action>,
        _ keyPath: KeyPath<ViewState, Effects>,
        on queue: DispatchQueue = .main,
        create: @escaping (ViewState, Effect.State) -> Effect) -> some View
    
    where Effects: Collection & Hashable, Effects.Element == Effect.State {
        
        effect(store) { anyObject, store in
            
            store.forEachEffect(
                anyObject,
                keyPath,
                on: queue,
                create: create
            )
        }
    }
    
    func effect<ViewState, Action>(on store: Store<ViewState, Action>,
                                   _ keyPath: KeyPath<ViewState, Effect.State>,
                                   on queue: DispatchQueue = .main,
                                   create: @escaping (ViewState) -> Effect) -> some View {
        
        effect(store) { anyObject, store in
            
            store.effect(
                anyObject,
                keyPath,
                on: queue,
                create: create
            )
        }
    }
    
    func effect<ViewState, Action, T>(on store: Store<ViewState, Action>,
                                      _ keyPath: KeyPath<ViewState, T>,
                                      on queue: DispatchQueue = .main,
                                      create: @escaping (ViewState) -> Effect) -> some View
    where T: Equatable {
        
        effect(store) { anyObject, store in
            
            store.effect(
                anyObject,
                keyPath,
                on: queue,
                create: create
            )
        }
    }
    
    func effect<ViewState, Action>(
        on store: Store<ViewState, Action>,
        _ keyPath: KeyPath<ViewState, Bool>,
        on queue: DispatchQueue = .main,
        create: @escaping (ViewState) -> Effect) -> some View {
            
            effect(store) { anyObject, store in
                
                store.effect(
                    anyObject,
                    keyPath,
                    on: queue,
                    create: create
                )
            }
        }
}


extension View {
    func effect<ViewState, Action>(on store: Store<ViewState, Action>,
                                   withDelay interval: TimeInterval,
                                   removeStateDuplicates: Equating<ViewState>?,
                                   on dispatchQueue: DispatchQueue,
                                   create: @escaping (ViewState) -> Effect) -> some View {
        
        effect(store) { anyObject, store in
            
            store.effect(
                anyObject,
                withDelay: interval,
                removeStateDuplicates: removeStateDuplicates,
                on: dispatchQueue,
                create: create
            )
        }
    }
}


extension View {
    func effect<ViewState, Action>(
        _ store: Store<ViewState, Action>,
        createEffect: @escaping (UIStateObserver, Store<ViewState, Action>) -> Void) -> some View {
            
            modifier(
                EffectModifier(
                    store: store,
                    createEffect: createEffect
                )
            )
        }
    
    func createObserver(_ observer: @escaping (UIStateObserver) -> Void) -> some View {
            modifier(
                UIStateObserverModifier(createEffect: observer )
            )
        }
    
    
}

