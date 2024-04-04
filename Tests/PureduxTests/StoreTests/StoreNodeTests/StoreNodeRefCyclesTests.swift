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
        weak var weakRootStore: RootStoreNode<TestState, AppAction>?
        var store: Store<TestState, AppAction>?
        
        autoreleasepool {
            let rootStore = RootStoreNode<TestState, AppAction>.initRootStore(
                initialState: TestState(currentIndex: 1)) { state, action  in
                    
                    state.reduce(action: action)
                }
            
            weakRootStore = rootStore
            store = rootStore.weakRefStore()
        }
        
        XCTAssertNil(weakRootStore)
    }
    
    func test_WhenStoreExists_ThenStrongRefToRootCreated() {
        weak var weakRootStore: RootStoreNode<TestState, AppAction>?
        var store: StateStore<TestState, AppAction>?
        
        autoreleasepool {
            let rootStore = RootStoreNode<TestState, AppAction>.initRootStore(
                initialState: TestState(currentIndex: 1)) { state, action  in
                    
                    state.reduce(action: action)
                }
            
            weakRootStore = rootStore
            store = rootStore.stateStore()
        }
        
        XCTAssertNotNil(weakRootStore)
    }
    
    func test_WhenStoreRemoved_ThenRootStoreIsReleased() {
        weak var weakRootStore: RootStoreNode<TestState, AppAction>?
        var store: StateStore<TestState, AppAction>?
        
        autoreleasepool {
            let rootStore = RootStoreNode<TestState, AppAction>.initRootStore(
                initialState: TestState(currentIndex: 1)) { state, action  in
                    
                    state.reduce(action: action)
                }
            
            weakRootStore = rootStore
            store = rootStore.stateStore()
        }
        
        XCTAssertNotNil(weakRootStore)
        store = nil
        XCTAssertNil(weakRootStore)
    }
}
