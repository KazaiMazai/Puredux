//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13/04/2024.
//

import Dispatch

final class SideEffects {
    private(set) var executing: [Effect.State: Weak<DispatchWorkItem>] = [:]
    private(set) var isSynced = true
    
    func run<State, Effects>(_ effects: Effects,
                             on queue: DispatchQueue,
                             state: State,
                             create: @escaping (State, Effect.State) -> Effect?)
    where
    Effects: Collection & Hashable,
    Effects.Element == Effect.State {
        
        let expectedToRun = Set(effects).filter { $0.isInProgress }
        let toBeCancelled = Set(executing.keys).subtracting(expectedToRun)
        
        toBeCancelled.forEach {
            executing[$0]?.object?.cancel()
            executing[$0] = nil
        }
        
        let toBeStarted = expectedToRun.subtracting(executing.keys)
        let createdEffects = toBeStarted.compactMap { effectState in
            create(state, effectState).map { (effectState, $0) }
        }
        
        createdEffects.forEach { effectState, effect in
            let workItem = DispatchWorkItem(block: effect.operation)
            let weakWorkItem = Weak<DispatchWorkItem>(workItem)
            executing[effectState] = weakWorkItem
            
            if let delay = effectState.currentAttemptDelay, delay > .zero {
                queue.asyncAfter(deadline: .now() + delay, execute: workItem)
            } else {
                queue.async(execute: workItem)
            }
        }
        
        isSynced = expectedToRun.count == executing.count
    }
}

final class Weak<T: AnyObject> {
    weak var object: T?
    
    init(_ object: T?) {
        self.object = object
    }
}
  
