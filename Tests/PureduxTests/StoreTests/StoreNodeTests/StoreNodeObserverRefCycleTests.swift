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
    typealias ChildStore = StoreNode<ParentStore, ChildTestState, StateComposition, Action>

    let timeout: TimeInterval = 3
    let rootStore = RootStoreNode<TestState, Action>.initRootStore(
        initialState: TestState(currentIndex: 0),
        reducer: { state, action  in state.reduce(action: action) }
    )

    func test_WhenStrongRefToStoreObjectAndObserverLive_ThenReferencCycleIsCreated() {
        weak var weakRefObject: ReferenceTypeState?
        
        autoreleasepool {
            let strongRefObject = ReferenceTypeState()
            let strongChildStore = rootStore.createChildStore(
                initialState: strongRefObject,
                stateMapping: { state, childState in childState },
                reducer: { state, action  in  state.reduce(action) }
            )
            weakRefObject = strongRefObject

            let referencedStore = strongChildStore.strongRefStore()

            let observer = Observer<ReferenceTypeState> { _, complete in
                referencedStore.dispatch(UpdateIndex(index: 1))
                complete(.active)
            }

            referencedStore.subscribe(observer: observer)
        }

        XCTAssertNotNil(weakRefObject)
    }

    func test_WhenStrongRefToStoreObjectAndObserverDead_ThenStoreIsReleased() {
        weak var weakRefObject: ReferenceTypeState?
        let asyncExpectation = expectation(description: "Observer state handler")

        autoreleasepool {
            let strongRefObject = ReferenceTypeState()
            let strongChildStore = rootStore.createChildStore(
                initialState: strongRefObject,
                stateMapping: { state, childState in childState },
                reducer: { state, action in state.reduce(action) }
            )
            weakRefObject = strongRefObject

            let referencedStore = strongChildStore.strongRefStore()

            let observer = Observer<ReferenceTypeState> { _, complete in
                referencedStore.dispatch(UpdateIndex(index: 1))
                complete(.dead)
                asyncExpectation.fulfill()
            }

            referencedStore.subscribe(observer: observer)
        }

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertNil(weakRefObject)
        }
    }

    func test_WhenWeakStoreAndObserverLive_ThenStoreIsReleased() {
        weak var weakRefObject: ReferenceTypeState?
        
        autoreleasepool {
            let strongRefObject = ReferenceTypeState()
            let strongChildStore = rootStore.createChildStore(
                initialState: strongRefObject,
                stateMapping: { state, childState in childState },
                reducer: { state, action  in  state.reduce(action) }
            )
            
            weakRefObject = strongRefObject

            let store = strongChildStore.weakRefStore()

            let observer = Observer<ReferenceTypeState> { _, complete in
                store.dispatch(UpdateIndex(index: 1))
                complete(.active)
            }

            store.subscribe(observer: observer)
        }

        XCTAssertNil(weakRefObject)
    }
}
