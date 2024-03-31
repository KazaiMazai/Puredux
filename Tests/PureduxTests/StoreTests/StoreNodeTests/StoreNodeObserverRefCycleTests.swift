//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 24.02.2023.
//

import XCTest
@testable import Puredux

final class StoreNodeChildStoreObserverRefCycleTests: XCTestCase {
    typealias ParentStore = StoreNode<VoidStore<Action>, TestState, TestState, Action>
    typealias ChildStore = StoreNode<ParentStore, ReferenceTypeState, ReferenceTypeState, Action>

    let timeout: TimeInterval = 3
    let rootStore = RootStoreNode<TestState, Action>.initRootStore(
        initialState: TestState(currentIndex: 0),
        reducer: { state, action  in state.reduce(action: action) }
    )

    func test_WhenStrongRefToStoreObjectAndObserverLive_ThenReferencCycleIsCreated() {
        weak var weakRefObject: ReferenceTypeState?
        weak var weakChildStore: ChildStore?
        
        autoreleasepool {
            let object = ReferenceTypeState()
            let store = rootStore.createChildStore(
                initialState: object,
                stateMapping: { state, childState in childState },
                reducer: { state, action  in  state.reduce(action) }
            )
            
            weakRefObject = object
            weakChildStore = store

            let referencedStore = store.strongRefStore()

            let observer = Observer<ReferenceTypeState> { _, complete in
                referencedStore.dispatch(UpdateIndex(index: 1))
                complete(.active)
            }

            referencedStore.subscribe(observer: observer)
        }

        XCTAssertNotNil(weakRefObject)
        XCTAssertNotNil(weakChildStore)
    }

    func test_WhenStrongRefToStoreObjectAndObserverDead_ThenStoreIsReleased() {
        weak var weakRefObject: ReferenceTypeState?
        weak var weakChildStore: ChildStore?
        
        let asyncExpectation = expectation(description: "Observer state handler")

        autoreleasepool {
            let object = ReferenceTypeState()
            let store = rootStore.createChildStore(
                initialState: object,
                stateMapping: { state, childState in childState },
                reducer: { state, action in state.reduce(action) }
            )
            
            weakRefObject = object
            weakChildStore = store

            let referencedStore = store.strongRefStore()

            let observer = Observer<ReferenceTypeState> { _, complete in
                referencedStore.dispatch(UpdateIndex(index: 1))
                complete(.dead)
                asyncExpectation.fulfill()
            }

            referencedStore.subscribe(observer: observer)
        }

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertNil(weakRefObject)
            XCTAssertNil(weakChildStore)
        }
    }

    func test_WhenWeakStoreAndObserverLive_ThenStoreIsReleased() {
        weak var weakRefObject: ReferenceTypeState?
        weak var weakChildStore: ChildStore?
        
        autoreleasepool {
            let object = ReferenceTypeState()
            let store = rootStore.createChildStore(
                initialState: object,
                stateMapping: { state, childState in childState },
                reducer: { state, action  in  state.reduce(action) }
            )
            
            weakRefObject = object
            weakChildStore = store
            
            let weakRefStore = store.weakRefStore()

            let observer = Observer<ReferenceTypeState> { _, complete in
                weakRefStore.dispatch(UpdateIndex(index: 1))
                complete(.active)
            }

            store.subscribe(observer: observer)
        }

        XCTAssertNil(weakChildStore)
        XCTAssertNil(weakRefObject)
    }
}
