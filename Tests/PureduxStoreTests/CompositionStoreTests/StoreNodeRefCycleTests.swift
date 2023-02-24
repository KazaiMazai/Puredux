//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 16.02.2023.
//

import XCTest
@testable import PureduxStore

final class CompositionStoreRefCyclesTests: XCTestCase {
    let timeout: TimeInterval = 3

    func test_WhenWeakRefStore_ThenWeakRefToRootCreated() {
        weak var rootStore: RootStoreNode<TestState, Action>? = nil
        var store: Store<TestState, Action>? = nil

        autoreleasepool {
            let strongRootStore = RootStoreNode<TestState, Action>.initRootStore(
                initialState: TestState(currentIndex: 1)) { state, action  in

                    state.reduce(action: action)
                }

            store = strongRootStore.weakRefStore()
            rootStore = strongRootStore
        }

        XCTAssertNil(rootStore)
    }

    func test_WhenStrongRefStore_ThenStrongRefToRootCreated() {
        weak var rootStore: RootStoreNode<TestState, Action>? = nil
        var store: Store<TestState, Action>? = nil

        autoreleasepool {
            let strongRootStore = RootStoreNode<TestState, Action>.initRootStore(
                initialState: TestState(currentIndex: 1)) { state, action  in

                    state.reduce(action: action)
                }

            store = strongRootStore.strongRefStore()
            rootStore = strongRootStore
        }

        XCTAssertNotNil(rootStore)
        store = nil
        XCTAssertNil(rootStore)
    }

    func test_WhenDetachedNodeStore_ThenStrongRefToRootCreated() {
        let rootStore = RootStoreNode<TestState, Action>.initRootStore(
            initialState: TestState(currentIndex: 1)) { state, action  in

                state.reduce(action: action)
            }
        weak var detachedNodeStore: CompositionStore<CompositionStore<VoidStore<Action>, TestState, TestState, Action>, DetachedTestState, StateComposition, Action>? = nil

        var store: Store<StateComposition, Action>? = nil

        autoreleasepool {
            let strongDetachedStore = rootStore.createDetachedStore(
                initialState: DetachedTestState(currentIndex: 0),
                stateMapping: { state, detachedState in
                    StateComposition(state: state, detachedState: detachedState)
                },
                reducer: { state, action  in  state.reduce(action: action) }
            )

            store = strongDetachedStore.strongRefStore()
            detachedNodeStore = strongDetachedStore
        }

        XCTAssertNotNil(detachedNodeStore)
        store = nil
        XCTAssertNil(detachedNodeStore)
    }
}

extension CompositionStoreRefCyclesTests {
    static var allTests = [
        ("test_WhenWeakRefStore_ThenWeakRefToRootCreated",
         test_WhenWeakRefStore_ThenWeakRefToRootCreated),

        ("test_WhenStrongRefStore_ThenStrongRefToRootCreated",
         test_WhenStrongRefStore_ThenStrongRefToRootCreated),

        ("test_WhenDetachedNodeStore_ThenStrongRefToRootCreated",
         test_WhenDetachedNodeStore_ThenStrongRefToRootCreated),
    ]
}

final class CompositionStoreObserverRefCycleTests: XCTestCase {
    typealias DetachedStore = CompositionStore<CompositionStore<VoidStore<Action>, TestState, TestState, Action>, DetachedTestState, StateComposition, Action>
    let timeout: TimeInterval = 3
    let rootStore = RootStoreNode<TestState, Action>.initRootStore(
        initialState: TestState(currentIndex: 0),
        reducer: { state, action  in state.reduce(action: action) }
    )

    func test_WhenStrongStoreRefAndObserverLive_ThenStoreNotReleased() {
        weak var weakDetachedStore: DetachedStore? = nil
        var store: Store<StateComposition, Action>? = nil

        autoreleasepool {
            let strongDetachedStore = rootStore.createDetachedStore(
                initialState: DetachedTestState(currentIndex: 0),
                stateMapping: { state, detachedState in
                    StateComposition(state: state, detachedState: detachedState)
                },
                reducer: { state, action  in  state.reduce(action: action) }
            )

            let strongStore = strongDetachedStore.strongRefStore()

            let observer = Observer<StateComposition> { state, complete in
                strongStore.dispatch(UpdateIndex(index: 1))
                complete(.active)
            }

            strongStore.subscribe(observer: observer)
            weakDetachedStore = strongDetachedStore
            store = strongStore
        }

        XCTAssertNotNil(weakDetachedStore)
        store = nil
        XCTAssertNotNil(weakDetachedStore)
    }

    func test_WhenStrongWeakRefAndObserverLive_ThenStoreIsReleased() {
        weak var weakDetachedStore: DetachedStore? = nil
        var store: Store<StateComposition, Action>? = nil

        autoreleasepool {
            let strongDetachedStore = rootStore.createDetachedStore(
                initialState: DetachedTestState(currentIndex: 0),
                stateMapping: { state, detachedState in
                    StateComposition(state: state, detachedState: detachedState)
                },
                reducer: { state, action  in  state.reduce(action: action) }
            )

            let weakStore = strongDetachedStore.weakRefStore()

            let observer = Observer<StateComposition> { state, complete in
                weakStore.dispatch(UpdateIndex(index: 1))
                complete(.active)
            }

            weakStore.subscribe(observer: observer)
            weakDetachedStore = strongDetachedStore
            store = weakStore
        }

        XCTAssertNil(weakDetachedStore)
        store = nil
        XCTAssertNil(weakDetachedStore)
    }

    func test_WhenStrongStoreRefAndObserverDead_ThenStoreIsReleased() {
        weak var weakDetachedStore: DetachedStore? = nil
        var store: Store<StateComposition, Action>? = nil

        let asyncExpectation = expectation(description: "Observer state handler")

        autoreleasepool {
            let strongDetachedStore = rootStore.createDetachedStore(
                initialState: DetachedTestState(currentIndex: 0),
                stateMapping: { state, detachedState in
                    StateComposition(state: state, detachedState: detachedState)
                },
                reducer: { state, action  in  state.reduce(action: action) }
            )

            let strongStore = strongDetachedStore.strongRefStore()

            let observer = Observer<StateComposition> { state, complete in
                strongStore.dispatch(UpdateIndex(index: 1))
                complete(.dead)
                asyncExpectation.fulfill()
            }

            strongStore.subscribe(observer: observer)

            weakDetachedStore = strongDetachedStore
            store = strongStore
        }

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertNotNil(weakDetachedStore)
            store = nil
            XCTAssertNil(weakDetachedStore)
        }
    }
}
