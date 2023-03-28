//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 06.06.2022.
//

import XCTest
@testable import PureduxUIKit
import PureduxStore

final class AlwaysEqualDeduplicationVCTests: XCTestCase {
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

    func setupVCForTests(vcUpdatedExpectation: XCTestExpectation) -> StubViewController {
        let testVC = StubViewController()

        testVC.with(
            store: store,
            props: { state, _ in
                .init(title: state.subStateWithTitle.title)
            },
            removeStateDuplicates: .alwaysEqual
        )

        testVC.didSetProps = {
            vcUpdatedExpectation.fulfill()
        }
        return testVC
    }
}

extension AlwaysEqualDeduplicationVCTests {
    func test_WhenManyNonMutatingActionsAndNotSubscribedAndDeduplicationAlwaysEqual_ThenVCNotUpdated() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.isInverted = true

        _ = setupVCForTests(vcUpdatedExpectation: expectation)

        (0..<actionsCount).forEach { _ in
            store.dispatch(NonMutatingStateAction())
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyNonMutatingActionsDeduplicationAlwaysEqual_ThenVCUpdatedOnce() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        let testVC = setupVCForTests(vcUpdatedExpectation: expectation)
        testVC.viewDidLoad()

        (0..<actionsCount).forEach { _ in
            store.dispatch(NonMutatingStateAction())
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyMutatingActionsAndDeduplicationAlwaysEqual_ThenVCUpdatedOnce() {
        let actionsCount = 1000
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
