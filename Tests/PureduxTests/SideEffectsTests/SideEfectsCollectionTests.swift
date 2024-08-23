//
//  File.swift
//
//
//  Created by Sergey Kazakov on 17/04/2024.
//

import Foundation

import Foundation
import XCTest
@testable import Puredux

final class SideEffectsCollectionTests: XCTestCase {
    let timeout: TimeInterval = 3.0
    
    func test_WhenStateIsRun_EffectExecuted() {
        let store = StateStore<[Effect.State], Bool>(
            [Effect.State(), Effect.State()],
            reducer: { state, action in
                state = state.map {
                    var effect = $0
                    action ? effect.run() : effect.cancel()
                    return effect
                }
            }
        )
        
        let asyncExpectation = expectation(description: "Effect executed")
        asyncExpectation.expectedFulfillmentCount = 2
        store.forEachEffect(on: .main) { _,_ in
            Effect {
                asyncExpectation.fulfill()
            }
        }
        
        store.dispatch(false)
        store.dispatch(true)
        store.dispatch(false, after: 0.05)
        
        waitForExpectations(timeout: timeout) { _ in
            
        }
    }
    
    func test_WhenStateIsRunMultipleTimes_EachEffectExecutedOnce() {
        let store = StateStore<[Effect.State], Bool>(
            [Effect.State(), Effect.State()],
            reducer: { state, action in
                state = state.map {
                    var effect = $0
                    action ? effect.run() : effect.cancel()
                    return effect
                }
            }
        )
        
        let asyncExpectation = expectation(description: "Effect executed")
        asyncExpectation.expectedFulfillmentCount = 2
        store.forEachEffect(on: .main) { _,_ in
            Effect {
                asyncExpectation.fulfill()
            }
        }
        
        store.dispatch(true)
        store.dispatch(true)
        store.dispatch(true)
        
        waitForExpectations(timeout: timeout) { _ in
            
        }
    }
    
    func test_WhenRestartedMultiple_ThenEachEffectExecutedForEveryRestart() {
        let store = StateStore<[Effect.State], Bool>(
            [Effect.State(), Effect.State()],
            reducer: { state, action in
                state = state.map {
                    var effect = $0
                    action ? effect.restart() : effect.cancel()
                    return effect
                }
            }
        )
        
        let asyncExpectation = expectation(description: "Effect executed")
        asyncExpectation.expectedFulfillmentCount = 6
        store.forEachEffect(on: .main) { _,_ in
            Effect {
                asyncExpectation.fulfill()
            }
        }
        
        store.dispatch(true)
        store.dispatch(false, after: 0.1)
        store.dispatch(true, after: 0.15)
        store.dispatch(false, after: 0.2)
        store.dispatch(true, after: 0.25)
        
        waitForExpectations(timeout: timeout) { _ in
            
        }
    }
    
    func test_WhenEffectIsSkipped_ThenEachEffectCreationIsCalledAgain() {
        let store = StateStore<[Effect.State], Bool>(
            [Effect.State(), Effect.State()],
            reducer: { state, action in
                state = state.map {
                    var effect = $0
                    action ? effect.restart() : effect.cancel()
                    return effect
                }
            }
        )
        
        let asyncExpectation = expectation(description: "Effect creation executed")
        asyncExpectation.expectedFulfillmentCount = 6
        store.forEachEffect(on: .main) { _,_ in
            asyncExpectation.fulfill()
            return .skip
        }
        
        store.dispatch(true)
        store.dispatch(true)
        store.dispatch(true)
        
        waitForExpectations(timeout: timeout) { _ in
            
        }
    }
    
    func test_WhenStateIsInitial_ThenNoEffectIsCreated() {
        let store = StateStore<[Effect.State], Bool>(
            [Effect.State(), Effect.State()],
            reducer: { state, action in
                state = state.map {
                    var effect = $0
                    action ? effect.restart() : effect.reset()
                    return effect
                }
            }
        )
        
        
        let asyncExpectation = expectation(description: "Effect creation executed")
        asyncExpectation.isInverted = true
        
        store.forEachEffect(on: .main) { _,_ in
            asyncExpectation.fulfill()
            return .skip
        }
        
        store.dispatch(false)
        store.dispatch(false)
        store.dispatch(false)
        
        waitForExpectations(timeout: timeout) { _ in
            
        }
    }
    
    func test_WhenStateIsSuccess_ThenNoEffectIsCreated() {
        
        let store = StateStore<[Effect.State], Bool>(
            [Effect.State(), Effect.State()],
            reducer: { state, action in
                state = state.map {
                    var effect = $0
                    action ? effect.restart() : effect.succeed()
                    return effect
                }
            }
        )
        
        let asyncExpectation = expectation(description: "Effect creation executed")
        asyncExpectation.isInverted = true
        
        store.forEachEffect(on: .main) { _,_ in
            asyncExpectation.fulfill()
            return .skip
        }
        
        store.dispatch(false)
        store.dispatch(false)
        store.dispatch(false)
        
        waitForExpectations(timeout: timeout) { _ in
            
        }
    }
    
    func test_WhenStateIsFailed_ThenNoEffectIsCreated() {
        let store = StateStore<[Effect.State], Bool>(
            [Effect.State(), Effect.State()],
            reducer: { state, action in
                state = state.map {
                    var effect = $0
                    action ? effect.restart() : effect.fail(nil)
                    return effect
                }
            }
        )
        
        
        let asyncExpectation = expectation(description: "Effect creation executed")
        asyncExpectation.isInverted = true
        
        store.forEachEffect(on: .main) { _,_ in
            asyncExpectation.fulfill()
            return .skip
        }
        
        store.dispatch(false)
        store.dispatch(false)
        store.dispatch(false)
        
        waitForExpectations(timeout: timeout) { _ in
            
        }
    }
    
    func test_WhenStateRetryOrFailAndHasAttempts_ThenEachEffectIsReExecuted() {
        let store = StateStore<[Effect.State], Bool>(
            [Effect.State(), Effect.State()],
            reducer: { state, action in
                state = state.map {
                    var effect = $0
                    action ? effect.run(maxAttempts: 2) : effect.retryOrFailWith(nil)
                    return effect
                }
            }
        )
        
        let asyncExpectation = expectation(description: "Effect executed")
        asyncExpectation.expectedFulfillmentCount = 4
        
        store.forEachEffect(on: .main) { _,_ in
            Effect {
                asyncExpectation.fulfill()
            }
        }
        
        store.dispatch(true)
        store.dispatch(false, after: 0.2)
        
        waitForExpectations(timeout: timeout) { _ in
            
        }
    }
    
    func test_WhenStateRetryOrFailAndHasNoAttempts_ThenEachEffectIsExecutedOnce() {
        let store = StateStore<[Effect.State], Bool>(
            [Effect.State(), Effect.State()],
            reducer: { state, action in
                state = state.map {
                    var effect = $0
                    action ? effect.run(maxAttempts: 1) : effect.retryOrFailWith(nil)
                    return effect
                }
            }
        )
        
        let asyncExpectation = expectation(description: "Effect executed")
        asyncExpectation.expectedFulfillmentCount = 2
        
        store.forEachEffect(on: .main) { _,_ in
            Effect {
                asyncExpectation.fulfill()
            }
        }
        
        store.dispatch(true)
        store.dispatch(false, after: 0.05)
        store.dispatch(false, after: 0.1)
        store.dispatch(false, after: 0.15)
        
        waitForExpectations(timeout: timeout) { _ in
            
        }
    }
    
    func test_WhenStateIsNotRunning_ThenNoEffectIsExecuted() {
        let store = StateStore<[Effect.State], Bool>(
            [Effect.State(), Effect.State()],
            reducer: { state, action in
                state = state.map {
                    var effect = $0
                    action ? effect.run() : effect.cancel()
                    return effect
                }
            }
        )
        
        let asyncExpectation = expectation(description: "Effect executed")
        asyncExpectation.isInverted = true
        
        store.forEachEffect(on: .main) { _,_ in
            Effect {
                asyncExpectation.fulfill()
            }
        }
        
        store.dispatch(false)
        store.dispatch(false)
        store.dispatch(false)
        
        waitForExpectations(timeout: timeout) { _ in
            
        }
    }
}
