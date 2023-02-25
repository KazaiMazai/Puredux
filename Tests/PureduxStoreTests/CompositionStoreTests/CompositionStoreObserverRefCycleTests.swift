//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 24.02.2023.
//

import XCTest
@testable import PureduxStore

final class CompositionStoreDetachedStoreObserverRefCycleTests: XCTestCase {
    typealias DetachedStore = CompositionStore<CompositionStore<VoidStore<Action>, TestState, TestState, Action>, DetachedTestState, StateComposition, Action>
    let timeout: TimeInterval = 3
    let rootStore = RootStoreNode<TestState, Action>.initRootStore(
        initialState: TestState(currentIndex: 0),
        reducer: { state, action  in state.reduce(action: action) }
    )

    func test_WhenStrongRefToStoreObjectAndObserverLive_ThenReferencCycleIsCreated() {
        weak var weakDetachedStore: DetachedStore? = nil

        autoreleasepool {
            let strongDetachedStore = rootStore.createDetachedStore(
                initialState: DetachedTestState(currentIndex: 0),
                stateMapping: { state, detachedState in
                    StateComposition(state: state, detachedState: detachedState)
                },
                reducer: { state, action  in  state.reduce(action: action) }
            )
            weakDetachedStore = strongDetachedStore

            let storeObject = strongDetachedStore.storeObject()

            let observer = Observer<StateComposition> { state, complete in
                storeObject.dispatch(UpdateIndex(index: 1))
                complete(.active)
            }

            storeObject.subscribe(observer: observer)
        }

        XCTAssertNotNil(weakDetachedStore)
    }

    func test_WhenStrongRefToStoreObjectAndObserverDead_ThenStoreIsReleased() {
        weak var weakDetachedStore: DetachedStore? = nil

        let asyncExpectation = expectation(description: "Observer state handler")

        autoreleasepool {
            let strongDetachedStore = rootStore.createDetachedStore(
                initialState: DetachedTestState(currentIndex: 0),
                stateMapping: { state, detachedState in
                    StateComposition(state: state, detachedState: detachedState)
                },
                reducer: { state, action  in  state.reduce(action: action) }
            )
            weakDetachedStore = strongDetachedStore

            let storeObject = strongDetachedStore.storeObject()

            let observer = Observer<StateComposition> { state, complete in
                storeObject.dispatch(UpdateIndex(index: 1))
                complete(.dead)
                asyncExpectation.fulfill()
            }

            storeObject.subscribe(observer: observer)
        }

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertNil(weakDetachedStore)
        }
    }

    func test_WhenStoreAndObserverLive_ThenStoreIsReleased() {
        weak var weakDetachedStore: DetachedStore? = nil

        autoreleasepool {
            let strongDetachedStore = rootStore.createDetachedStore(
                initialState: DetachedTestState(currentIndex: 0),
                stateMapping: { state, detachedState in
                    StateComposition(state: state, detachedState: detachedState)
                },
                reducer: { state, action  in  state.reduce(action: action) }
            )
            weakDetachedStore = strongDetachedStore

            let store = strongDetachedStore.store()

            let observer = Observer<StateComposition> { state, complete in
                store.dispatch(UpdateIndex(index: 1))
                complete(.active)
            }

            store.subscribe(observer: observer)
        }

        XCTAssertNil(weakDetachedStore)
    }
}
