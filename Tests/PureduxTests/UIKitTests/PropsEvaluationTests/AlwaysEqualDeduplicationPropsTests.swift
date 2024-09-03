//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 06.06.2022.
//

import XCTest
@testable import Puredux

final class AlwaysEqualDeduplicationPropsUIKitTests: XCTestCase {
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

    func setupVCForTests(propsEvaluatedExpectation: XCTestExpectation) -> StubViewController {
        let testVC = StubViewController()

        testVC.setPresenter(
            store: store,
            props: { state, _ in
                propsEvaluatedExpectation.fulfill()
                return .init(title: state.subStateWithTitle.title)
            },
            removeStateDuplicates: .alwaysEqual
        )

        return testVC
    }
}

extension AlwaysEqualDeduplicationPropsUIKitTests {
    func test_WhenManyNonMutatingActionsAndNotSubscribedAndDeduplicationAlwaysEqual_ThenPropsNotEvaluated() {
        let actionsCount = 10
        let expectation = expectation(description: "propsEvaluated")
        expectation.isInverted = true

        _ = setupVCForTests(propsEvaluatedExpectation: expectation)

        (0..<actionsCount).forEach { _ in
            store.dispatch(NonMutatingStateAction())
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyNonMutatingActionsDeduplicationAlwaysEqual_ThenPropsEvaluatedOnce() {
        let actionsCount = 10
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        let testVC = setupVCForTests(propsEvaluatedExpectation: expectation)
        testVC.viewDidLoad()

        (0..<actionsCount).forEach { _ in
            store.dispatch(NonMutatingStateAction())
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyMutatingActionsAndDeduplicationAlwaysEqual_ThenPropsEvaluatedOnce() {
        let actionsCount = 10
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        let testVC = setupVCForTests(propsEvaluatedExpectation: expectation)
        testVC.viewDidLoad()

        (0..<actionsCount).forEach {
            store.dispatch(UpdateIndex(index: $0))
        }

        waitForExpectations(timeout: timeout)
    }
}
