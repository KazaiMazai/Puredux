//
//  File.swift
//
//
//  Created by Sergey Kazakov on 21/08/2024.
//

import SwiftUI

extension View {
    typealias CreateForEachEffect<T> = @Sendable (T, Effect.State) -> Effect
    typealias CreateEffect<T> = @Sendable (T) -> Effect

    func effect<ViewState, Action, Effects>(
        _ store: AnyStore<ViewState, Action>,
        collection keyPath: KeyPath<ViewState, Effects>,
        on queue: DispatchQueue = .main,
        create: @escaping CreateForEachEffect<ViewState>) -> some View

    where 
    Effects: Collection & Hashable,
    Effects.Element == Effect.State {

        withObserver { observer in
            store.effect(
                observer.cancellable,
                collection: keyPath,
                on: queue,
                create: { state, effectState, _ in create(state, effectState) }
            )
        }
    }

    func effect<ViewState, Action>(_ store: AnyStore<ViewState, Action>,
                                   _ keyPath: KeyPath<ViewState, Effect.State>,
                                   on queue: DispatchQueue = .main,
                                   create: @escaping CreateEffect<ViewState>) -> some View {

        withObserver { observer in
            store.effect(
                observer.cancellable,
                keyPath,
                on: queue,
                create: { state, _ in create(state) }
            )
        }
    }

    func effect<ViewState, Action, T>(_ store: AnyStore<ViewState, Action>,
                                      onChange keyPath: KeyPath<ViewState, T>,
                                      on queue: DispatchQueue = .main,
                                      create: @escaping CreateEffect<ViewState>) -> some View
    where T: Equatable {

        withObserver { observer in
            store.effect(
                observer.cancellable,
                onChange: keyPath,
                on: queue,
                create: { state, _ in create(state) }
            )
        }
    }

    func effect<ViewState, Action>(
        _ store: AnyStore<ViewState, Action>,
        toggle keyPath: KeyPath<ViewState, Bool>,
        on queue: DispatchQueue = .main,
        create: @escaping CreateEffect<ViewState>) -> some View {

            withObserver { observer in
                store.effect(
                    observer.cancellable,
                    toggle: keyPath,
                    on: queue,
                    create: { state, _ in create(state) }
                )
            }
        }
}

extension View {
    func effect<ViewState, Action>(_ store: AnyStore<ViewState, Action>,
                                   withDelay interval: TimeInterval,
                                   removeStateDuplicates equating: Equating<ViewState>?,
                                   on dispatchQueue: DispatchQueue,
                                   create: @escaping CreateEffect<ViewState>) -> some View {

        withObserver { observer in
            store.effect(
                observer.cancellable,
                withDelay: interval,
                removeStateDuplicates: equating,
                on: dispatchQueue,
                create: { state, _ in create(state) }
            )
        }
    }
}
