//
//  File.swift
//
//
//  Created by Sergey Kazakov on 16/04/2024.
//

import Foundation

import XCTest
@testable import Puredux

final class SideEfectsBoolTests: XCTestCase {
    let timeout: TimeInterval = 3.0
    
    func test_WhenStateIsToggledToTrue_EffectExecuted() {
        let store = StateStore<Bool, Bool>(initialState: false, reducer: { state, action in state = action })
        
        let asyncExpectation = expectation(description: "Effect executed")
        
        store.effect(on: .main) { _ in
            Effect {
                asyncExpectation.fulfill()
            }
        }
        
        store.dispatch(false)
        store.dispatch(true)
        store.dispatch(false)
        
        waitForExpectations(timeout: timeout) { _ in
            
        }
    }
    
    func test_WhenBoolIsSetToTrueMultipleTime_EffectExecutedOnce() {
        let store = StateStore<Bool, Bool>(initialState: false, reducer: { state, action in state = action })
        
        let asyncExpectation = expectation(description: "Effect executed")
        
        store.effect(on: .main) { _ in
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
    
    func test_WhenBoolIsToggledTrueMultiple_EffectExecutedOnEveryToggle() {
        let store = StateStore<Bool, Bool>(initialState: false, reducer: { state, action in state = action })
        
        let asyncExpectation = expectation(description: "Effect executed")
        asyncExpectation.expectedFulfillmentCount = 3
        store.effect(on: .main) { _ in
            Effect {
                asyncExpectation.fulfill()
            }
        }
        
        store.dispatch(true)
        store.dispatch(false)
        store.dispatch(true)
        store.dispatch(false)
        store.dispatch(true)
        
        waitForExpectations(timeout: timeout) { _ in
            
        }
    }
    
    func test_WhenEffectIsSkipped_ThenEffectCreationIsCalledAgain() {
        let store = StateStore<Bool, Bool>(initialState: false, reducer: { state, action in state = action })
        
        let asyncExpectation = expectation(description: "Effect creation executed")
        asyncExpectation.expectedFulfillmentCount = 3
        store.effect(on: .main) { _ in
            asyncExpectation.fulfill()
            return .skip
        }
        
        store.dispatch(true)
        store.dispatch(true)
        store.dispatch(true)
        
        waitForExpectations(timeout: timeout) { _ in
            
        }
    }
    
    func test_WhenStateIsNotChangedAndFalse_ThenEffectIsNotCreated() {
        let store = StateStore<Bool, Bool>(initialState: false, reducer: { state, action in state = action })
        
        let asyncExpectation = expectation(description: "Effect creation executed")
        asyncExpectation.isInverted = true
        
        store.effect(on: .main) { _ in
            asyncExpectation.fulfill()
            return .skip
        }
        
        store.dispatch(false)
        store.dispatch(false)
        store.dispatch(false)
        
        waitForExpectations(timeout: timeout) { _ in
            
        }
    }
    
    func test_WhenStateIsNotChangedAndFalse_ThenEffectIsNotExecuted() {
        let store = StateStore<Bool, Bool>(initialState: false, reducer: { state, action in state = action })
        
        let asyncExpectation = expectation(description: "Effect executed")
        asyncExpectation.isInverted = true
        
        store.effect(on: .main) { _ in
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
