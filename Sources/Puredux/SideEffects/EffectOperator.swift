//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13/04/2024.
//

import Dispatch
import Foundation

final class EffectOperator {
    private(set) var executing: [Effect.State: DispatchWorkItem] = [:]
    private(set) var isSynced = true
    
    func run(_ inProgress: Bool,
             on queue: DispatchQueue,
             create: (Effect.State) -> Effect) {
       
        let effect: Effect.State = inProgress ? .running() : .idle()
        run(effect, on: queue, create: create)
    }
    
    func run(_ effect: Effect.State,
             on queue: DispatchQueue,
             create: (Effect.State) -> Effect) {
        
        run([effect], on: queue, create: create)
    }
    
    func run<Effects>(_ effects: Effects,
                      on queue: DispatchQueue,
                      create: (Effect.State) -> Effect)
    
    where Effects: Collection & Hashable, Effects.Element == Effect.State {
        
        let effectsInProgress = effects.filter { $0.isInProgress }
        let expectedToBeExecuting = Set(effectsInProgress)
        
        executing.keys
            .filter { !expectedToBeExecuting.contains($0) }
            .forEach {
                executing[$0]?.cancel()
                executing[$0] = nil
            }
        
        effectsInProgress
            .filter { !executing.keys.contains($0) }
            .map { state in (state, create(state)) }
            .filter { _, effect in effect.canBeExecuted }
            .forEach { state, effect in
                let workItem = DispatchWorkItem(block: effect.operation)
                executing[state] = workItem
                queue.asyncAfter(delay: state.delay, execute: workItem)
            }
        
        isSynced = expectedToBeExecuting.count == executing.count
    }
}
