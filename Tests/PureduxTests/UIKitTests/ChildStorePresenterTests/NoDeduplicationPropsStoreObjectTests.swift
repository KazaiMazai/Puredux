//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 07.03.2023.
//

import XCTest
@testable import Puredux


final class PropsEvaluationWithChildStoreTests: XCTestCase {
    let timeout: TimeInterval = 4

    let state = TestAppStateWithIndex()

    lazy var factory: StoreFactory = {
        StoreFactory<TestAppStateWithIndex, Action>(
            initialState: state,
            reducer: { state, action in
                state.reduce(action)
            })
    }()

    lazy var store: Store<(TestAppStateWithIndex, SubStateWithTitle), Action> = {
        factory.childStore(
            initialState: SubStateWithTitle(title: "title"),
            reducer: { state, action in state.reduce(action) }
        )
    }()

    func setupVCForTests(propsEvaluatedExpectation: XCTestExpectation) -> StubViewController {
        let testVC = StubViewController()

        testVC.with(
            store: store,
            props: { state, _ in
                propsEvaluatedExpectation.fulfill()
                return .init(title: state.1.title)
            }
        )

        return testVC
    }
}

extension PropsEvaluationWithChildStoreTests {

    func test_WhenNoActionAfterSetupAndNotSubscribed_ThenPropsNotEvaluated() {
        let expectation = expectation(description: "propsEvaluated")
        expectation.isInverted = true

        _ = setupVCForTests(propsEvaluatedExpectation: expectation)

        waitForExpectations(timeout: timeout)
    }

    func test_WhenNoActionAfterSetupAndSubscribed_ThenPropsEvaluatedOnce() {
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        let testVC = setupVCForTests(propsEvaluatedExpectation: expectation)
        testVC.viewDidLoad()
        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyNonMutatingActionsAndNeverEqual_ThenPropsEvaluatedForSubscribtionAndEveryActionTwice() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = (2 * actionsCount) + 1

        let testVC = setupVCForTests(propsEvaluatedExpectation: expectation)
        testVC.viewDidLoad()

        (0..<actionsCount).forEach { _ in
            store.dispatch(NonMutatingStateAction())
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyMutatingActionsAndDeduplicateNeverEqual_ThenPropsEvaluatedForSubscribtionAndEveryActionTwice() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = (2 * actionsCount) + 1

        let testVC = setupVCForTests(propsEvaluatedExpectation: expectation)
        testVC.viewDidLoad()

        (0..<actionsCount).forEach {
            store.dispatch(UpdateIndex(index: $0))
        }

        waitForExpectations(timeout: timeout)
    }
}
