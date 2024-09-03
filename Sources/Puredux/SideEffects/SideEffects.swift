//
//  File.swift
//
//
//  Created by Sergey Kazakov on 13/04/2024.
//

import Dispatch
import Foundation

extension StoreProtocol {
    typealias CreateForEachEffect = (State, Effect.State) -> Effect
    typealias CreateEffect = (State, @escaping Dispatch<Action>) -> Effect
}

extension StoreProtocol {

    @discardableResult
    func effect(on queue: DispatchQueue = .main,
                create: @escaping CreateEffect) -> Self
    where
    State == Effect.State {

        effect(\.self, on: queue, create: create)
    }

    @discardableResult
    func forEachEffect(on queue: DispatchQueue = .main,
                       create: @escaping CreateForEachEffect) -> Self

    where
    State: Collection & Hashable,
    State.Element == Effect.State {

        forEachEffect(\.self, on: queue, create: create)
    }

    @discardableResult
    func onChangeEffect(on queue: DispatchQueue = .main,
                        create: @escaping CreateEffect) -> Self
    where
    State: Equatable {

        effect(onChange: \.self, on: queue, create: create)
    }

    @discardableResult
    func toggleEffect(on queue: DispatchQueue = .main,
                      create: @escaping CreateEffect) -> Self
    where
    State == Bool {

        effect(toggle: \.self, on: queue, create: create)
    }
}

extension StoreProtocol {
    @discardableResult
    func forEachEffect<Effects>(_ keyPath: KeyPath<State, Effects>,
                                on queue: DispatchQueue = .main,
                                create: @escaping CreateForEachEffect) -> Self
    where
    Effects: Collection & Hashable,
    Effects.Element == Effect.State {

        let effectOperator = EffectOperator()
        let weakStore = weakStore()

        subscribe(observer: Observer(
            weakStore.getStoreObject(),
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState, complete in

                let allEffects = state[keyPath: keyPath]
                effectOperator.run(allEffects, on: queue) { effectState in
                    create(state, effectState)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )

        return self
    }

    @discardableResult
    func effect(_ keyPath: KeyPath<State, Effect.State>,
                on queue: DispatchQueue = .main,
                create: @escaping CreateEffect) -> Self {

        let effectOperator = EffectOperator()
        let weakStore = weakStore()

        subscribe(observer: Observer(
            weakStore.getStoreObject(),
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState, complete in

                let effect = state[keyPath: keyPath]
                effectOperator.run(effect, on: queue) { _ in
                    create(state, weakStore.dispatch)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )

        return self
    }

    @discardableResult
    func effect<T>(onChange keyPath: KeyPath<State, T>,
                   on queue: DispatchQueue = .main,
                   create: @escaping CreateEffect) -> Self
    where T: Equatable {

        let effectOperator = EffectOperator()
        let weakStore = weakStore()

        subscribe(observer: Observer(
            weakStore.getStoreObject(),
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState, complete in
                let effect: Effect.State = prevState == nil ? .idle() : .running()
                effectOperator.run(effect, on: queue) { _ in
                    create(state, weakStore.dispatch)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )

        return self
    }

    @discardableResult
    func effect(toggle keyPath: KeyPath<State, Bool>,
                on queue: DispatchQueue = .main,
                create: @escaping CreateEffect) -> Self {

        let effectOperator = EffectOperator()
        let weakStore = weakStore()

        subscribe(observer: Observer(
            weakStore.getStoreObject(),
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState, complete in
                let isRunning = state[keyPath: keyPath]
                effectOperator.run(isRunning, on: queue) { _ in
                    create(state, weakStore.dispatch)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )

        return self
    }

    @discardableResult
    func effect(withDelay timeInterval: TimeInterval,
                removeStateDuplicates: Equating<State>?,
                on queue: DispatchQueue = .main,
                create: @escaping CreateEffect) -> Self {

        let effectOperator = EffectOperator()
        let weakStore = weakStore()

        subscribe(observer: Observer(
            weakStore.getStoreObject(),
            removeStateDuplicates: removeStateDuplicates) { [effectOperator] state, prevState, complete in
                effectOperator.run(.running(delay: timeInterval), on: queue) { _ in
                    create(state, weakStore.dispatch)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )

        return self
    }
}

extension StoreProtocol {

    @discardableResult
    func effect(_ cancellable: AnyCancellableEffect,
                on queue: DispatchQueue = .main,
                create: @escaping CreateEffect) -> Self where State == Effect.State {

        effect(cancellable, \.self, on: queue, create: create)
    }

    @discardableResult
    func forEachEffect(_ cancellable: AnyCancellableEffect,
                       on queue: DispatchQueue = .main,
                       create: @escaping CreateForEachEffect) -> Self

    where State: Collection & Hashable, State.Element == Effect.State {

        forEachEffect(cancellable, \.self, on: queue, create: create)
    }

    @discardableResult
    func onChangeEffect(_ cancellable: AnyCancellableEffect,
                on queue: DispatchQueue = .main,
                create: @escaping CreateEffect) -> Self where State: Equatable {

        effect(cancellable, onChange: \.self, on: queue, create: create)
    }

    @discardableResult
    func toggleEffect(_ cancellable: AnyCancellableEffect,
                      on queue: DispatchQueue = .main,
                      create: @escaping CreateEffect) -> Self where State == Bool {

        effect(cancellable, toggle: \.self, on: queue, create: create)
    }
}

extension StoreProtocol {
    @discardableResult
    func forEachEffect<Effects>(_ cancellable: AnyCancellableEffect,
                                _ keyPath: KeyPath<State, Effects>,
                                on queue: DispatchQueue = .main,
                                create: @escaping CreateForEachEffect) -> Self
    where Effects: Collection & Hashable, Effects.Element == Effect.State {

        let effectOperator = EffectOperator()

        subscribe(observer: Observer(
            cancellable.observer,
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState, complete in

                let allEffects = state[keyPath: keyPath]
                effectOperator.run(allEffects, on: queue) { effectState in
                    create(state, effectState)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )

        return self
    }

    @discardableResult
    func effect(_ cancellable: AnyCancellableEffect,
                _ keyPath: KeyPath<State, Effect.State>,
                on queue: DispatchQueue = .main,
                create: @escaping CreateEffect) -> Self {

        let effectOperator = EffectOperator()

        subscribe(observer: Observer(
            cancellable.observer,
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState, complete in

                let effect = state[keyPath: keyPath]
                effectOperator.run(effect, on: queue) { _ in
                    create(state, dispatch)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )

        return self
    }

    @discardableResult
    func effect<T>(_ cancellable: AnyCancellableEffect,
                   onChange keyPath: KeyPath<State, T>,
                   on queue: DispatchQueue = .main,
                   create: @escaping CreateEffect) -> Self where T: Equatable {

        let effectOperator = EffectOperator()

        subscribe(observer: Observer(
            cancellable.observer,
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState, complete in
                let effect: Effect.State = prevState == nil ? .idle() : .running()
                effectOperator.run(effect, on: queue) { _ in
                    create(state, dispatch)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )

        return self
    }

    @discardableResult
    func effect(_ cancellable: AnyCancellableEffect,
                toggle keyPath: KeyPath<State, Bool>,
                on queue: DispatchQueue = .main,
                create: @escaping CreateEffect) -> Self {

        let effectOperator = EffectOperator()

        subscribe(observer: Observer(
            cancellable.observer,
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState, complete in
                let isRunning = state[keyPath: keyPath]
                effectOperator.run(isRunning, on: queue) { _ in
                    create(state, dispatch)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )

        return self
    }

    @discardableResult
    func effect(_ cancellable: AnyCancellableEffect,
                withDelay timeInterval: TimeInterval,
                removeStateDuplicates: Equating<State>?,
                on queue: DispatchQueue = .main,
                create: @escaping CreateEffect) -> Self {

        let effectOperator = EffectOperator()

        subscribe(observer: Observer(
            cancellable.observer,
            removeStateDuplicates: removeStateDuplicates) { [effectOperator] state, prevState, complete in
                effectOperator.run(.running(delay: timeInterval), on: queue) { _ in
                    create(state, dispatch)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )

        return self
    }
}
