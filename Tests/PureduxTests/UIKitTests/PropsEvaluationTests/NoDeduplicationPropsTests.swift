//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 05.06.2022.
//

import XCTest
@testable import Puredux


final class NoDeduplicationPropsUIKitTests: XCTestCase {
    let timeout: TimeInterval = 4

    let state = TestAppState(
        subStateWithTitle: SubStateWithTitle(title: ""),
        subStateWithIndex: SubStateWithIndex(index: 0)
    )

    lazy var factory: StoreFactory = {
        StoreFactory<TestAppState, Action>(
            initialState: state,
            reducer: { state, action in
                state.reduce(action)
            })
    }()

    lazy var store: Store = {
        factory.rootStore()
    }()

    func setupVCForTests(propsEvaluatedExpectation: XCTestExpectation) -> StubViewController {
        let testVC = StubViewController()

        testVC.with(store: store,
                props: { state, _ in
                    propsEvaluatedExpectation.fulfill()
            return .init(title: state.subStateWithTitle.title)
                })

        return testVC
    }
}

extension NoDeduplicationPropsUIKitTests {

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

    func test_WhenManyNonMutatingActionsAndDeduplicateNeverEqual_ThenPropsEvaluatedForSubscribtionAndEveryAction() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount + 1

        let testVC = setupVCForTests(propsEvaluatedExpectation: expectation)
        testVC.viewDidLoad()

        (0..<actionsCount).forEach { _ in
            store.dispatch(NonMutatingStateAction())
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyMutatingActionsAndDeduplicateNeverEqual_ThenPropsEvaluatedForSubscribtionAndEveryAction() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount + 1

        let testVC = setupVCForTests(propsEvaluatedExpectation: expectation)
        testVC.viewDidLoad()

        (0..<actionsCount).forEach {
            store.dispatch(UpdateIndex(index: $0))
        }

        waitForExpectations(timeout: timeout)
    }
}
