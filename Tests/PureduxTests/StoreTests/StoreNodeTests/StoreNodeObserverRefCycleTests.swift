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
        weak var weakChildStore: ChildStore?

        autoreleasepool {
            let strongChildStore = rootStore.createChildStore(
                initialState: ChildTestState(currentIndex: 0),
                stateMapping: { state, childState in
                    StateComposition(state: state, childState: childState)
                },
                reducer: { state, action  in  state.reduce(action: action) }
            )
            weakChildStore = strongChildStore

            let referencedStore = strongChildStore.referencedStore()

            let observer = Observer<StateComposition> { _, complete in
                referencedStore.dispatch(UpdateIndex(index: 1))
                complete(.active)
            }

            referencedStore.subscribe(observer: observer)
        }

        XCTAssertNotNil(weakChildStore)
    }

    func test_WhenStrongRefToStoreObjectAndObserverDead_ThenStoreIsReleased() {
        weak var weakChildStore: ChildStore?

        let asyncExpectation = expectation(description: "Observer state handler")

        autoreleasepool {
            let strongChildStore = rootStore.createChildStore(
                initialState: ChildTestState(currentIndex: 0),
                stateMapping: { state, childState in
                    StateComposition(state: state, childState: childState)
                },
                reducer: { state, action  in  state.reduce(action: action) }
            )
            weakChildStore = strongChildStore

            let referencedStore = strongChildStore.referencedStore()

            let observer = Observer<StateComposition> { _, complete in
                referencedStore.dispatch(UpdateIndex(index: 1))
                complete(.dead)
                asyncExpectation.fulfill()
            }

            referencedStore.subscribe(observer: observer)
        }

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertNil(weakChildStore)
        }
    }

    func test_WhenWeakStoreAndObserverLive_ThenStoreIsReleased() {
        weak var weakChildStore: ChildStore?
        
        autoreleasepool {
            let strongChildStore = rootStore.createChildStore(
                initialState: ChildTestState(currentIndex: 0),
                stateMapping: { state, childState in
                    StateComposition(state: state, childState: childState)
                },
                reducer: { state, action  in  state.reduce(action: action) }
            )
            weakChildStore = strongChildStore

            let store = strongChildStore.store()

            let observer = Observer<StateComposition> { _, complete in
                store.dispatch(UpdateIndex(index: 1))
                complete(.active)
                
            }

            store.subscribe(observer: observer)
        }

        XCTAssertNil(weakChildStore)
    }
}
