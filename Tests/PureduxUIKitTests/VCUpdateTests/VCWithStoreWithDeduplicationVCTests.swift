//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 06.06.2022.
//

import XCTest
@testable import PureduxUIKit
import PureduxStore

final class VCWithStoreWithDeduplicationVCTests: XCTestCase {
    let timeout: TimeInterval = 10

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
        let vc = StubViewController()

        vc.with(
            store: store,
            props: { state, store in
                .init(title: state.subStateWithTitle.title)
            },
            removeStateDuplicates: .equal { $0.subStateWithIndex.index }
        )

        vc.didSetProps = {
            vcUpdatedExpectation.fulfill()
        }

        return vc
    }
}


extension VCWithStoreWithDeduplicationVCTests {
    func test_WhenManyNonMutatingActionsAndNotSubscribed_ThenVCNotUpdated() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.isInverted = true

        let _ = setupVCForTests(vcUpdatedExpectation: expectation)

        (0..<actionsCount).forEach { _ in
            store.dispatch(NonMutatingStateAction())
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyNonMutatingActions_ThenVCUpdatedOnce() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        let vc = setupVCForTests(vcUpdatedExpectation: expectation)
        vc.viewDidLoad()

        (0..<actionsCount).forEach { _ in
            store.dispatch(NonMutatingStateAction())
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyMutatingActions_ThenVCUpdatedForSubscribtionAndEveryDeduplicatedMutation() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount

        let vc = setupVCForTests(vcUpdatedExpectation: expectation)
        vc.viewDidLoad()

        (0..<actionsCount).forEach {
            store.dispatch(UpdateIndex(index: $0))
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenMutatingAndNonMutatingActions_ThenVCUpdatedForSubscribtionAndEveryDeduplicatedMutation() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount

        let vc = setupVCForTests(vcUpdatedExpectation: expectation)
        vc.viewDidLoad()

        (0..<actionsCount).forEach {
            store.dispatch(UpdateIndex(index: $0))
        }

        (0..<actionsCount).forEach { _ in
            store.dispatch(NonMutatingStateAction())
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenSpecificSubStateMutatingActions_ThenVCUpdatedForSubscribtionAndEveryDeduplicatedMutation() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount

        let vc = setupVCForTests(vcUpdatedExpectation: expectation)
        vc.viewDidLoad()

        (0..<actionsCount).forEach {
            store.dispatch(UpdateIndex(index: $0))
        }

        (0..<actionsCount).forEach {
            store.dispatch(UpdateTitle(title: "\($0)"))
        }

        waitForExpectations(timeout: timeout)
    }
}


extension VCWithStoreWithDeduplicationVCTests {

    static var allTests = [
        ("test_WhenManyNonMutatingActionsAndNotSubscribed_ThenVCNotUpdated",
         test_WhenManyNonMutatingActionsAndNotSubscribed_ThenVCNotUpdated),

        ("test_WhenManyNonMutatingActions_ThenVCUpdatedOnce",
         test_WhenManyNonMutatingActions_ThenVCUpdatedOnce),

        ("test_WhenManyMutatingActions_ThenVCUpdatedForSubscribtionAndEveryDeduplicatedMutation",
         test_WhenManyMutatingActions_ThenVCUpdatedForSubscribtionAndEveryDeduplicatedMutation),

        ("test_WhenMutatingAndNonMutatingActions_ThenVCUpdatedForSubscribtionAndEveryDeduplicatedMutation",
         test_WhenMutatingAndNonMutatingActions_ThenVCUpdatedForSubscribtionAndEveryDeduplicatedMutation),

        ("test_WhenSpecificSubStateMutatingActions_ThenVCUpdatedForSubscribtionAndEveryDeduplicatedMutation",
         test_WhenSpecificSubStateMutatingActions_ThenVCUpdatedForSubscribtionAndEveryDeduplicatedMutation)
    ]
}
