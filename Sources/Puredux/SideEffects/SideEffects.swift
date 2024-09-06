//
//  File.swift
//
//
//  Created by Sergey Kazakov on 13/04/2024.
//

import Dispatch
import Foundation

public extension Store {
    typealias CreateEffectForState = (State, Effect.State, @escaping Dispatch<Action>) -> Effect
    typealias CreateEffect = (State, @escaping Dispatch<Action>) -> Effect
}

public extension Store {
    /**
     Adds an effect to the store, which is triggered based on the Effect state.
  
      - Parameters:
         - queue: The `DispatchQueue` on which the effect should be executed. Defaults to the main queue.
         - create: A closure that creates the `Effect` to be executed.
      
      - Returns: The `Store` instance with the added effect.
     
      - Note: This method is used when the `State` of the store is of type `Effect.State`. This method subscribes to changes in the state and runs the provided effect controlled entirely by the effect state.
    */
    @discardableResult
    func effect(on queue: DispatchQueue = .main,
                create: @escaping CreateEffect) -> Self
    where State == Effect.State {
        
        effect(\.self, on: queue, create: create)
    }
    /**
     Adds an effect to the store that is executed based on the `Effect.State` that can be found on the  specified key path.
     
     - Parameters:
        - keyPath: A key path to the `Effect.State` within the store's state.
        - queue: The `DispatchQueue` on which the effect should be executed. Defaults to the main queue.
        - create: A closure that creates the `Effect` to be executed.
     
     - Returns: The `Store` instance with the added effect.
     
     - Note: This method subscribes to changes in the state at the given key path and runs the provided effect controlled entirely by the effect state.
     
     Usage example:
     
     ```swift
     store.effect(\.workExecutionState, on: .global(qos: .background)) { appState, dispatch in
        Effect {
            // Do some heavy lifting here
            // dispatch(...) the result action when finished
        }
    }
    */
    @discardableResult
    func effect(_ keyPath: KeyPath<State, Effect.State>,
                on queue: DispatchQueue = .main,
                create: @escaping CreateEffect) -> Self {
        
        let effectOperator = EffectOperator()
        let weakStore = weakStore()
        
        subscribe(observer: Observer(
            storeObject(),
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState in
                let effect = state[keyPath: keyPath]
                effectOperator.run(effect, on: queue) { _ in
                    create(state, weakStore.dispatch)
                }
                
                return (.active, effectOperator.isSynced ? state : prevState)
            }
        )
        
        return self
    }
    
    
    /**
     Adds an effect to the store that is executed whenever the state changes.
     
     - Parameters:
        - queue: The `DispatchQueue` on which the effect should be executed. Defaults to the main queue.
        - create: A closure that creates the `Effect` to be executed.
     
     - Returns: The `Store` instance with the added effect.
     
     - Note: This method subscribes to changes in the state and runs the provided effect every time the state changes.
     Previously scheduled executions are cancelled in case they haven't started yet.
    */
    @discardableResult
    func effectOnChange(on queue: DispatchQueue = .main,
                        create: @escaping CreateEffect) -> Self
    where State: Equatable {
    
        effect(onChange: \.self, on: queue, create: create)
    }
    
    /**
     Adds an effect to the store that is triggered whenever the value for the specified key path changes.
     
     - Parameters:
        - keyPath: A key path to the `Equatable` type within the store's state.
        - queue: The `DispatchQueue` on which the effect should be executed. Defaults to the main queue.
        - create: A closure that creates the `Effect` to be executed.
     
     - Returns: The `Store` instance with the added effect.
     
     - Note: This method subscribes to changes in the state at the given key path and runs the provided effect every time the state changes.
     Previously scheduled executions are cancelled in case they haven't started yet.
     
     Usage example:
     
     ```swift
     store.effect(onChange: \.currentTrackId) { appState, dispatch in
        Effect {
            guard let currentTrackId else {
                Player.shared.stop()
                return
            }
            Player.shared.play(appState.currentTrackId)
        }
    }
    ```
    */
    @discardableResult
    func effect<T>(onChange keyPath: KeyPath<State, T>,
                   on queue: DispatchQueue = .main,
                   create: @escaping CreateEffect) -> Self
    where T: Equatable {
        
        let effectOperator = EffectOperator()
        let weakStore = weakStore()
        
        subscribe(observer: Observer(
            storeObject(),
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState in
                let effect: Effect.State = prevState == nil ? .idle() : .running()
                effectOperator.run(effect, on: queue) { _ in
                    create(state, weakStore.dispatch)
                }
               
                return (.active, effectOperator.isSynced ? state : prevState)
            }
        )
        
        return self
    }
    
    /**
     Adds an effect to the store that is triggered when the boolean state is`true`
     
     - Parameters:
        - queue: The `DispatchQueue` on which the effect should be executed. Defaults to the main queue.
        - create: A closure that creates the `Effect` to be executed.
     
     - Returns: The `Store` instance with the added effect.
     
     - Note: This method is used when the `State` of the store is of type `Bool`. This method subscribes to changes in the boolean state and runs the provided effect when the state changes from `false` to `true`.
    */
    @discardableResult
    func effectToggle(on queue: DispatchQueue = .main,
                      create: @escaping CreateEffect) -> Self
    where State == Bool {
        
        effect(toggle: \.self, on: queue, create: create)
    }
    
    /**
     Adds an effect to the store that is executed when the boolean value on the specified key path changes to `true`
     
     - Parameters:
        - keyPath: A key path to a `Bool` value within the store's state.
        - queue: The `DispatchQueue` on which the effect should be executed. Defaults to the main queue.
        - create: A closure that creates the `Effect` to be executed.
     
     - Returns: The `Store` instance with the added effect.
     
     - Note: This method subscribes to changes in the boolean state at the given key path and runs the provided effect when the boolean value changes from `false` to `true`.
     
     Usage example:
     
     ```swift
     store.effect(toggle: \.expectsToFireRequest) { appState, dispatch in
        Effect {
            // fire network request
            // dispatch(...) request result action when finished
        }
     }
    ```
    */
    @discardableResult
    func effect(toggle keyPath: KeyPath<State, Bool>,
                on queue: DispatchQueue = .main,
                create: @escaping CreateEffect) -> Self {
        
        let effectOperator = EffectOperator()
        let weakStore = weakStore()
        
        subscribe(observer: Observer(
            storeObject(),
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState in
                let isRunning = state[keyPath: keyPath]
                effectOperator.run(isRunning, on: queue) { _ in
                    create(state, weakStore.dispatch)
                }
               
                return (.active, effectOperator.isSynced ? state : prevState)
            }
        )
        
        return self
    }
}
 
public extension Store {
    /**
     Adds an effect to the store, which is triggered based on the collection of `Effect.State`.
    
     - Parameters:
        - queue: The `DispatchQueue` on which each effect should be executed. Defaults to the main queue.
        - create: A closure that creates the `Effect` for each state element in the collection.
     
     - Returns: The `Store` instance with the added effects.
     
     - Note: This method subscribes to changes in the state and runs the  effect for each effect state in the collection.
    */
    @discardableResult
    func effectCollection(on queue: DispatchQueue = .main,
                          forEach create: @escaping CreateEffectForState) -> Self
    
    where 
    State: Collection & Hashable,
    State.Element == Effect.State {
        
        effect(collection: \.self, on: queue, forEach: create)
    }
 
    /**
     Adds an effect to the store, which is triggered based on the collection of `Effect.State` what can be found at specified key path.
     
     
     - Parameters:
        - keyPath: A key path to the collection within the store's state.
        - queue: The `DispatchQueue` on which each effect should be executed. Defaults to the main queue.
        - create: A closure that creates the `Effect` for each state element in the collection.
     
     - Returns: The `Store` instance with the added effects.
     
     - Note: This method subscribes to changes on keyPath and runs the effect for each effect state in the collection.
     
     Usage example:
     
     ```swift
     store.effect(collection: \.requestsStates) { appState, effectState dispatch in
        Effect {
            let payload = appState.getPayloadFor(effectState)
            // do the work
        }
    }
    ```
     
    */
    @discardableResult
    func effect<Effects>(collection keyPath: KeyPath<State, Effects>,
                         on queue: DispatchQueue = .main,
                         forEach create: @escaping CreateEffectForState) -> Self
    where
    Effects: Collection & Hashable,
    Effects.Element == Effect.State {
        
        let effectOperator = EffectOperator()
        let weakStore = weakStore()
        
        subscribe(observer: Observer(
            storeObject(),
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState in
                let allEffects = state[keyPath: keyPath]
                effectOperator.run(allEffects, on: queue) { effectState in
                    create(state, effectState, weakStore.dispatch)
                }
               
                return (.active, effectOperator.isSynced ? state : prevState)
            }
        )
        
        return self
    }
}


extension Store {
    @discardableResult
    func effect(withDelay timeInterval: TimeInterval,
                removeStateDuplicates: Equating<State>?,
                on queue: DispatchQueue = .main,
                create: @escaping CreateEffect) -> Self {
        
        let effectOperator = EffectOperator()
        let weakStore = weakStore()
        
        subscribe(observer: Observer(
            storeObject(),
            removeStateDuplicates: removeStateDuplicates) { [effectOperator] state, prevState in
                effectOperator.run(.running(delay: timeInterval), on: queue) { _ in
                    create(state, weakStore.dispatch)
                }
               
                return (.active, effectOperator.isSynced ? state : prevState)
            }
        )
        
        return self
    }
}

extension Store {
    
    @discardableResult
    func effect(_ cancellable: AnyCancellableEffect,
                on queue: DispatchQueue = .main,
                create: @escaping CreateEffect) -> Self where State == Effect.State {
        
        effect(cancellable, \.self, on: queue, create: create)
    }
    
    @discardableResult
    func effectCollection(_ cancellable: AnyCancellableEffect,
                          on queue: DispatchQueue = .main,
                          create: @escaping CreateEffectForState) -> Self
    
    where
    State: Collection & Hashable,
    State.Element == Effect.State {
        
        effect(cancellable, collection: \.self, on: queue, create: create)
    }
    
    @discardableResult
    func effectOnChange(_ cancellable: AnyCancellableEffect,
                        on queue: DispatchQueue = .main,
                        create: @escaping CreateEffect) -> Self 
    where State: Equatable {
        
        effect(cancellable, onChange: \.self, on: queue, create: create)
    }
    
    @discardableResult
    func effectToggle(_ cancellable: AnyCancellableEffect,
                      on queue: DispatchQueue = .main,
                      create: @escaping CreateEffect) -> Self where State == Bool {
        
        effect(cancellable, toggle: \.self, on: queue, create: create)
    }
}

extension Store {
    @discardableResult
    func effect<Effects>(_ cancellable: AnyCancellableEffect,
                         collection keyPath: KeyPath<State, Effects>,
                         on queue: DispatchQueue = .main,
                         create: @escaping CreateEffectForState) -> Self
    where
    Effects: Collection & Hashable,
    Effects.Element == Effect.State {
        
        let effectOperator = EffectOperator()
        let weakStore = weakStore()
        
        subscribe(observer: Observer(
            cancellable.observer,
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState in
                
                let allEffects = state[keyPath: keyPath]
                effectOperator.run(allEffects, on: queue) { effectState in
                    create(state, effectState, weakStore.dispatch)
                }
               
                return (.active, effectOperator.isSynced ? state : prevState)
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
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState in
                
                let effect = state[keyPath: keyPath]
                effectOperator.run(effect, on: queue) { _ in
                    create(state, dispatch)
                }
                
                return (.active, effectOperator.isSynced ? state : prevState)
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
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState in
                let effect: Effect.State = prevState == nil ? .idle() : .running()
                effectOperator.run(effect, on: queue) { _ in
                    create(state, dispatch)
                }
                
                return (.active, effectOperator.isSynced ? state : prevState)
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
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState in
                let isRunning = state[keyPath: keyPath]
                effectOperator.run(isRunning, on: queue) { _ in
                    create(state, dispatch)
                }
                
                return (.active, effectOperator.isSynced ? state : prevState)
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
            removeStateDuplicates: removeStateDuplicates) { [effectOperator] state, prevState in
                effectOperator.run(.running(delay: timeInterval), on: queue) { _ in
                    create(state, dispatch)
                }
                
                return (.active, effectOperator.isSynced ? state : prevState)
            }
        )
        
        return self
    }
}
