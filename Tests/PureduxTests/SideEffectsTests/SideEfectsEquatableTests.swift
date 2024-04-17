//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 16/04/2024.
//

import Foundation

import XCTest
@testable import Puredux

final class SideEfectsForEquatableStateTests: XCTestCase {
    let timeout: TimeInterval = 3.0
    
    func test_WhenStateChanged_EffectExecuted() {
        let store = StateStore<Int, Int>(initialState: 0, reducer: { state, action in state = action })
        
        let asyncExpectation = expectation(description: "Effect executed")
        
        store.sideEffect(on: .main) { _ in
            Effect {
                asyncExpectation.fulfill()
            }
        }
        
        store.dispatch(1)
        store.dispatch(1)
        store.dispatch(1)
        
        waitForExpectations(timeout: timeout) { _ in
            
        }
    }
    
    func test_WhenStateChangedAndEffectSkipped_EffectCreationIsCalledAgain() {
        let store = StateStore<Int, Int>(initialState: 0, reducer: { state, action in state = action })
        
        let asyncExpectation = expectation(description: "Effect executed")
        asyncExpectation.expectedFulfillmentCount = 3
        store.sideEffect(on: .main) { _ in
            asyncExpectation.fulfill()
            return .skip
        }
        
        store.dispatch(1)
        store.dispatch(1)
        store.dispatch(1)
        
        waitForExpectations(timeout: timeout) { _ in
            
        }
    }
    
    func test_WhenStateNotChanged_EffectNotExecuted() {
        let store = StateStore<Int, Int>(initialState: 0, reducer: { state, action in state = action })
        
        let asyncExpectation = expectation(description: "Effect executed")
        asyncExpectation.isInverted = true
        store.sideEffect(on: .main) { _ in
            Effect {
                asyncExpectation.fulfill()
            }
        }
        
        store.dispatch(0)
        store.dispatch(0)
        store.dispatch(0)
        
        waitForExpectations(timeout: timeout) { _ in
            
        }
    }
    
    func test_WhenStateNotChanged_EffectCreationIsNotCalled() {
        let store = StateStore<Int, Int>(initialState: 0, reducer: { state, action in state = action })
        
        let asyncExpectation = expectation(description: "Effect executed")
        asyncExpectation.isInverted = true
        store.sideEffect(on: .main) { _ in
            asyncExpectation.fulfill()
            return .skip
        }
        
        store.dispatch(0)
        store.dispatch(0)
        store.dispatch(0)
        
        waitForExpectations(timeout: timeout) { _ in
            
        }
    }
}
