//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 06.06.2022.
//

import XCTest
@testable import PureduxUIKit
import PureduxStore

final class VCWithStoreWithoutDeduplicationVCTests: XCTestCase {
    let timeout: TimeInterval = 4

    let state = TestAppState(
        subStateWithTitle: SubStateWithTitle(title: ""),
        subStateWithIndex: SubStateWithIndex(index: 0)
    )

    lazy var rootStore: RootStore = {
        RootStore<TestAppState, Action>(initialState: state) { state, action in
            state.reduce(action)
        }
    }()

    lazy var store: Store = {
        rootStore.store()
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

extension VCWithStoreWithoutDeduplicationVCTests {

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

    func test_WhenManyNonMutatingActionsAndDeduplicateNeverEqual_ThenVCUpdatedForSubscribtionAndEveryAction() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount + 1

        let testVC = setupVCForTests(vcUpdatedExpectation: expectation)
        testVC.viewDidLoad()

        (0..<actionsCount).forEach { _ in
            store.dispatch(NonMutatingStateAction())
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyMutatingActionsAndDeduplicateNeverEqual_ThenVCUpdatedForSubscribtionAndEveryAction() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount + 1

        let testVC = setupVCForTests(vcUpdatedExpectation: expectation)
        testVC.viewDidLoad()

        (0..<actionsCount).forEach {
            store.dispatch(UpdateIndex(index: $0))
        }

        waitForExpectations(timeout: timeout)
    }
}

extension VCWithStoreWithoutDeduplicationVCTests {

    static var allTests = [
        ("test_WhenNoActionAfterSetupAndNotSubscribed_ThenVCNotUpdated",
         test_WhenNoActionAfterSetupAndNotSubscribed_ThenVCNotUpdated),

        ("test_WhenNoActionAfterSetupAndSubscribed_ThenVCUpdatedOnce",
         test_WhenNoActionAfterSetupAndSubscribed_ThenVCUpdatedOnce),

        ("test_WhenManyNonMutatingActionsAndDeduplicateNeverEqual_ThenVCUpdatedForSubscribtionAndEveryAction",
         test_WhenManyNonMutatingActionsAndDeduplicateNeverEqual_ThenVCUpdatedForSubscribtionAndEveryAction),

        ("test_WhenManyMutatingActionsAndDeduplicateNeverEqual_ThenVCUpdatedForSubscribtionAndEveryAction",
         test_WhenManyMutatingActionsAndDeduplicateNeverEqual_ThenVCUpdatedForSubscribtionAndEveryAction)

    ]
}
