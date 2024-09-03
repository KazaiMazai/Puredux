//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 06.06.2022.
//

import XCTest
@testable import Puredux


final class NoDeduplicationVCTests: XCTestCase {
    let timeout: TimeInterval = 4

    let state = TestAppState(
        subStateWithTitle: SubStateWithTitle(title: ""),
        subStateWithIndex: SubStateWithIndex(index: 0)
    )

    lazy var store: StateStore = {
        StateStore<TestAppState, Action>(
             state,
            reducer: { state, action in
                state.reduce(action)
            })
    }()
 
    func setupVCForTests(vcUpdatedExpectation: XCTestExpectation) -> StubViewController {
        let testVC = StubViewController()

        testVC.with(store: store,
                props: { state, _ in
                    .init(title: state.subStateWithTitle.title)
                })

        testVC.didSetProps = {
            vcUpdatedExpectation.fulfill()
        }

        return testVC
    }
}

extension NoDeduplicationVCTests {

    func test_WhenNoActionAfterSetupAndNotSubscribed_ThenVCNotUpdated() {
        let expectation = expectation(description: "propsEvaluated")
        expectation.isInverted = true

        _ = setupVCForTests(vcUpdatedExpectation: expectation)

        waitForExpectations(timeout: timeout)
    }

    func test_WhenNoActionAfterSetupAndSubscribed_ThenVCUpdatedOnce() {
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        let testVC = setupVCForTests(vcUpdatedExpectation: expectation)
        testVC.viewDidLoad()
        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyNonMutatingActionsAndDeduplicateNeverEqual_ThenVCUpdatesDebpuncedToOne() {
        let actionsCount = 10
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        let testVC = setupVCForTests(vcUpdatedExpectation: expectation)
        testVC.viewDidLoad()

        (0..<actionsCount).forEach { _ in
            store.dispatch(NonMutatingStateAction())
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyMutatingActionsAndDeduplicateNeverEqual_ThenVCUpdatesDebpuncedToOne() {
        let actionsCount = 10
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        let testVC = setupVCForTests(vcUpdatedExpectation: expectation)
        testVC.viewDidLoad()

        (0..<actionsCount).forEach {
            store.dispatch(UpdateIndex(index: $0))
        }

        waitForExpectations(timeout: timeout)
    }
}
