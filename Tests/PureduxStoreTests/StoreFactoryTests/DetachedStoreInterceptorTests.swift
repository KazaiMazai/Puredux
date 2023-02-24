//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 16.02.2023.
//

import XCTest
@testable import PureduxStore

final class DispatchActionsOnDetachedStoreInterceptionTests: XCTestCase {
    let timeout: TimeInterval = 10

    func test_WhenActionDispatchAndIntercepted_ThenResultReducedOnMainStore() {
        let actionsCount = 100
        let expectations = (0..<actionsCount).map {
            XCTestExpectation(description: "index \($0)")
        }

        let factory = StoreFactory<TestState, Action>(
            initialState: TestState(currentIndex: 0),
            interceptor:  { asyncAction, dispatch  in
                guard let asyncAction = (asyncAction as? AsyncAction) else {
                    return
                }
                dispatch(ResultAction(index: asyncAction.index))
            },
            reducer: { state, action  in
                state.reduce(action: action)
                guard let resultAction = (action as? ResultAction) else {
                    return
                }

                expectations[resultAction.index].fulfill()
            }
        )

        let detachedStore = factory.detachedStore(
            initialState: DetachedTestState(currentIndex: 0),
            stateMapping: { rootState, detachedState in
                StateComposition(state: rootState, detachedState: detachedState)
            },
            reducer: { state, action  in
                state.reduce(action: action)
            }
        )

        let actions = (0..<actionsCount).map { AsyncAction(index: $0) }
        actions.forEach { detachedStore.dispatch($0) }

        wait(for: expectations, timeout: timeout, enforceOrder: true)
    }

    func test_WhenActionDispatchAndIntercepted_ThenResultReducedOnDetachedStore() {
        let actionsCount = 100
        let expectations = (0..<actionsCount).map {
            XCTestExpectation(description: "index \($0)")
        }

        let factory = StoreFactory<TestState, Action>(
            initialState: TestState(currentIndex: 0),
            interceptor: { asyncAction, dispatch  in
                guard let asyncAction = (asyncAction as? AsyncAction) else {
                    return
                }
                dispatch(ResultAction(index: asyncAction.index))
            },
            reducer: { state, action  in
                state.reduce(action: action)
            }
        )

        let detachedStore = factory.detachedStore(
            initialState: DetachedTestState(currentIndex: 0),
            stateMapping: { rootState, detachedState in
                StateComposition(state: rootState, detachedState: detachedState)
            },
            reducer: { state, action  in

                state.reduce(action: action)
                guard let resultAction = (action as? ResultAction) else {
                    return
                }

                expectations[resultAction.index].fulfill()
            }
        )

        let actions = (0..<actionsCount).map { AsyncAction(index: $0) }
        actions.forEach { detachedStore.dispatch($0) }

        wait(for: expectations, timeout: timeout, enforceOrder: true)
    }
}


final class DispatchActionsOnMainStoreInterceptionTests: XCTestCase {
    let timeout: TimeInterval = 10

    func test_WhenActionDispatchAndIntercepted_ThenResultReducedOnMainStore() {
        let actionsCount = 100
        let expectations = (0..<actionsCount).map {
            XCTestExpectation(description: "index \($0)")
        }

        let factory = StoreFactory<TestState, Action>(
            initialState: TestState(currentIndex: 0),
            interceptor: { asyncAction, dispatch  in
                guard let asyncAction = (asyncAction as? AsyncAction) else {
                    return
                }
                dispatch(ResultAction(index: asyncAction.index))
            },
            reducer: { state, action  in
                state.reduce(action: action)
                guard let resultAction = (action as? ResultAction) else {
                    return
                }

                expectations[resultAction.index].fulfill()
            }
        )

        let detachedStore = factory.detachedStore(
            initialState: DetachedTestState(currentIndex: 0),
            stateMapping: { rootState, detachedState in
                StateComposition(state: rootState, detachedState: detachedState)
            },
            reducer: { state, action  in
                state.reduce(action: action)
            }
        )

        let actions = (0..<actionsCount).map { AsyncAction(index: $0) }
        let store = factory.store()
        actions.forEach { store.dispatch($0) }

        wait(for: expectations, timeout: timeout, enforceOrder: true)
    }

    func test_WhenActionDispatchAndIntercepted_ThenResultNotReducedOnDetachedStore() {
        let actionsCount = 100
        let unexpected = (0..<actionsCount).map {
            let exp = XCTestExpectation(description: "index \($0)")
            exp.isInverted = true
            return exp
        }

        let factory = StoreFactory<TestState, Action>(
            initialState: TestState(currentIndex: 0),
            interceptor: { asyncAction, dispatch  in
                guard let asyncAction = (asyncAction as? AsyncAction) else {
                    return
                }
                dispatch(ResultAction(index: asyncAction.index))
            },
            reducer: { state, action  in
                state.reduce(action: action)
            }
        )


        let detachedStore = factory.detachedStore(
            initialState: DetachedTestState(currentIndex: 0),
            stateMapping: { rootState, detachedState in
                StateComposition(state: rootState, detachedState: detachedState)
            },
            reducer: { state, action  in

                state.reduce(action: action)
                guard let resultAction = (action as? ResultAction) else {
                    return
                }

                unexpected[resultAction.index].fulfill()
            }
        )

        let actions = (0..<actionsCount).map { AsyncAction(index: $0) }
        let store = factory.store()
        actions.forEach { store.dispatch($0) }

        wait(for: unexpected, timeout: timeout, enforceOrder: true)
    }
}

final class DetachedStoreInterceptOnceTests: XCTestCase {
    let timeout: TimeInterval = 10

    func test_WhenDispatchedToDetachedStore_ThenEachActionInterceptedOnce() {
        let actionsCount = 100
        let expectations = (0..<actionsCount).map {
            XCTestExpectation(description: "index \($0)")
        }

        let factory = StoreFactory<TestState, Action>(
            initialState: TestState(currentIndex: 0),
            interceptor: { asyncAction, dispatch  in
                guard let asyncAction = (asyncAction as? AsyncAction) else {
                    return
                }

                expectations[asyncAction.index].fulfill()
                dispatch(ResultAction(index: asyncAction.index))
            },
            reducer: { state, action  in
                state.reduce(action: action)
            }
        )

        let detachedStore = factory.detachedStore(
            initialState: DetachedTestState(currentIndex: 0),
            stateMapping: { rootState, detachedState in
                StateComposition(state: rootState, detachedState: detachedState)
            },
            reducer: { state, action  in
                state.reduce(action: action)
            }
        )

        let actions = (0..<actionsCount).map { AsyncAction(index: $0) }
        actions.forEach { detachedStore.dispatch($0) }

        wait(for: expectations, timeout: timeout, enforceOrder: true)
    }

    func test_WhenDispatchedToMainStore_ThenEachActionInterceptedOnce() {
        let actionsCount = 100
        let expectations = (0..<actionsCount).map {
            XCTestExpectation(description: "index \($0)")
        }

        let factory = StoreFactory<TestState, Action>(
            initialState: TestState(currentIndex: 0),
            interceptor: { asyncAction, dispatch  in
                guard let asyncAction = (asyncAction as? AsyncAction) else {
                    return
                }

                expectations[asyncAction.index].fulfill()
                dispatch(ResultAction(index: asyncAction.index))
            },
            reducer: { state, action  in
                state.reduce(action: action)
            }
        )


        let detachedStore = factory.detachedStore(
            initialState: DetachedTestState(currentIndex: 0),
            stateMapping: { rootState, detachedState in
                StateComposition(state: rootState, detachedState: detachedState)
            },
            reducer: { state, action  in
                state.reduce(action: action)
            }
        )

        let actions = (0..<actionsCount).map { AsyncAction(index: $0) }
        let store = factory.store()
        actions.forEach { store.dispatch($0) }

        wait(for: expectations, timeout: timeout, enforceOrder: true)
    }
}
