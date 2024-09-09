//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 09/09/2024.
//

import Foundation
import XCTest
@testable import Puredux

final class ActionsMappingTest: XCTestCase {
    let timeout: TimeInterval = 10
    
    func test_WhenDispatchedToMappedActionsStore_ThenReducedOnParent() {
        typealias ParentAction = Int
        typealias ChildAction = String
        let expectation = XCTestExpectation(description: "action expected")
        
        let store = StateStore<Int, ParentAction>(1) { state, action  in
            state += action
            expectation.fulfill()
        }
        
        let mappedStore: StateStore<Int, ChildAction> = store.map(actions: { Int($0) ?? 0 })
        
        mappedStore.dispatch("1")
        
        wait(for: [expectation], timeout: timeout)
    }
    
    func test_WhenDispatchedToMappedActionsAnyStore_ThenReducedOnParent() {
        typealias ParentAction = Int
        typealias ChildAction = String
        let expectation = XCTestExpectation(description: "action expected")
        
        let store = StateStore<Int, ParentAction>(1) { state, action  in
            state += action
            expectation.fulfill()
        }
        
        let mappedStore: AnyStore<Int, ChildAction> = store
            .eraseToAnyStore()
            .map(actions: { Int($0) ?? 0 })
        
        mappedStore.dispatch("1")
        
        wait(for: [expectation], timeout: timeout)
    }
}
