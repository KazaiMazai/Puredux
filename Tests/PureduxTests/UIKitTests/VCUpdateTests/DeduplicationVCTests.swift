//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 06.06.2022.
//

import XCTest
@testable import Puredux


final class DeduplicationVCTests: XCTestCase {
    let timeout: TimeInterval = 10

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
            removeStateDuplicates: .equal { $0.subStateWithIndex.index }
        )

        testVC.didSetProps = {
            vcUpdatedExpectation.fulfill()
        }

        return testVC
    }
}

extension DeduplicationVCTests {
    func test_WhenManyNonMutatingActionsAndNotSubscribed_ThenVCNotUpdated() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.isInverted = true

        _ = setupVCForTests(vcUpdatedExpectation: expectation)

        (0..<actionsCount).forEach { _ in
            store.dispatch(NonMutatingStateAction())
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyNonMutatingActions_ThenVCUpdatedOnce() {
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

    func test_WhenManyMutatingActions_ThenVCUpdatedForSubscribtionAndEveryDeduplicatedMutation() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount

        let testVC = setupVCForTests(vcUpdatedExpectation: expectation)
        testVC.viewDidLoad()

        (0..<actionsCount).forEach {
            store.dispatch(UpdateIndex(index: $0))
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenMutatingAndNonMutatingActions_ThenVCUpdatedForSubscribtionAndEveryDeduplicatedMutation() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount

        let testVC = setupVCForTests(vcUpdatedExpectation: expectation)
        testVC.viewDidLoad()

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

        let testVC = setupVCForTests(vcUpdatedExpectation: expectation)
        testVC.viewDidLoad()

        (0..<actionsCount).forEach {
            store.dispatch(UpdateIndex(index: $0))
        }

        (0..<actionsCount).forEach {
            store.dispatch(UpdateTitle(title: "\($0)"))
        }

        waitForExpectations(timeout: timeout)
    }
}
