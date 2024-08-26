//
//  File.swift
//
//
//  Created by Sergey Kazakov on 16.02.2023.
//

import XCTest
@testable import Puredux

final class StoreNodeRootStoreRefCyclesTests: XCTestCase {
    
    func test_WhenWeakRefStore_ThenWeakRefToRootCreated() {
        weak var weakRootStore: RootStoreNode<TestState, Action>?
        var store: Store<TestState, Action>?
        
        autoreleasepool {
            let rootStore = RootStoreNode<TestState, Action>.initRootStore(
                initialState: TestState(currentIndex: 1)) { state, action  in
                    
                    state.reduce(action: action)
                }
            
            weakRootStore = rootStore
            store = rootStore.weakRefStore()
        }
        
        XCTAssertNil(weakRootStore)
    }
    
    func test_WhenStoreExists_ThenStrongRefToRootCreated() {
        weak var weakRootStore: RootStoreNode<TestState, Action>?
        var store: StateStore<TestState, Action>?
        
        autoreleasepool {
            let rootStore = RootStoreNode<TestState, Action>.initRootStore(
                initialState: TestState(currentIndex: 1)) { state, action  in
                    
                    state.reduce(action: action)
                }
            
            weakRootStore = rootStore
            store = rootStore.stateStore()
        }
        
        XCTAssertNotNil(weakRootStore)
    }
    
    func test_WhenStoreRemoved_ThenRootStoreIsReleased() {
        weak var weakRootStore: RootStoreNode<TestState, Action>?
        var store: StateStore<TestState, Action>?
        
        autoreleasepool {
            let rootStore = RootStoreNode<TestState, Action>.initRootStore(
                initialState: TestState(currentIndex: 1)) { state, action  in
                    
                    state.reduce(action: action)
                }
            
            weakRootStore = rootStore
            store = rootStore.stateStore()
        }
        
        XCTAssertNotNil(weakRootStore)
        store = nil
        wait(for: weakRootStore == nil, timeout: 3.0, description: "The object should be deallocated since no strong reference points to it.")
    }
}
