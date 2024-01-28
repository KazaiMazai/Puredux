//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 24.02.2023.
//

import XCTest
@testable import PureduxStore

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

            let storeObject = strongChildStore.storeObject()

            let observer = Observer<StateComposition> { _, complete in
                storeObject.dispatch(UpdateIndex(index: 1))
                complete(.active)
            }

            storeObject.subscribe(observer: observer)
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

            let storeObject = strongChildStore.storeObject()

            let observer = Observer<StateComposition> { _, complete in
                storeObject.dispatch(UpdateIndex(index: 1))
                complete(.dead)
                asyncExpectation.fulfill()
            }

            storeObject.subscribe(observer: observer)
        }

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertNil(weakChildStore)
        }
    }

    func test_WhenStoreAndObserverLive_ThenStoreIsReleased() {
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
