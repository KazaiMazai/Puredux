//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 06.06.2022.
//

import XCTest
@testable import PureduxUIKit
import PureduxStore

final class VCWithStoreWithAlwaysEqualDeduplicationPropsTests: XCTestCase {
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

    func setupVCForTests(propsEvaluatedExpectation: XCTestExpectation) -> StubViewController {
        let testVC= StubViewController()

        vc.with(
            store: store,
            props: { state, _ in
                propsEvaluatedExpectation.fulfill()
                return .init(title: state.subStateWithTitle.title)
            },
            removeStateDuplicates: .alwaysEqual
        )

        return vc
    }
}

extension VCWithStoreWithAlwaysEqualDeduplicationPropsTests {
    func test_WhenManyNonMutatingActionsAndNotSubscribedAndDeduplicationAlwaysEqual_ThenPropsNotEvaluated() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.isInverted = true

        _ = setupVCForTests(propsEvaluatedExpectation: expectation)

        (0..<actionsCount).forEach { _ in
            store.dispatch(NonMutatingStateAction())
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyNonMutatingActionsDeduplicationAlwaysEqual_ThenPropsEvaluatedOnce() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        let testVC= setupVCForTests(propsEvaluatedExpectation: expectation)
        vc.viewDidLoad()

        (0..<actionsCount).forEach { _ in
            store.dispatch(NonMutatingStateAction())
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyMutatingActionsAndDeduplicationAlwaysEqual_ThenPropsEvaluatedOnce() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        let testVC= setupVCForTests(propsEvaluatedExpectation: expectation)
        vc.viewDidLoad()

        (0..<actionsCount).forEach {
            store.dispatch(UpdateIndex(index: $0))
        }

        waitForExpectations(timeout: timeout)
    }
}

extension VCWithStoreWithAlwaysEqualDeduplicationPropsTests {

    static var allTests = [
        ("test_WhenManyNonMutatingActionsAndNotSubscribedAndDeduplicationAlwaysEqual_ThenPropsNotEvaluated",
         test_WhenManyNonMutatingActionsAndNotSubscribedAndDeduplicationAlwaysEqual_ThenPropsNotEvaluated),

        ("test_WhenManyNonMutatingActionsDeduplicationAlwaysEqual_ThenPropsEvaluatedOnce",
         test_WhenManyNonMutatingActionsDeduplicationAlwaysEqual_ThenPropsEvaluatedOnce),

        ("test_WhenManyMutatingActionsAndDeduplicationAlwaysEqual_ThenPropsEvaluatedOnce",
         test_WhenManyMutatingActionsAndDeduplicationAlwaysEqual_ThenPropsEvaluatedOnce)
    ]
}
