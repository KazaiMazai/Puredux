//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 06.06.2022.
//

import XCTest
@testable import PureduxUIKit
import PureduxStore

final class VCWithStoreWithDeduplicationPropsTests: XCTestCase {
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

    func setupVCForTests(propsEvaluatedExpectation: XCTestExpectation) -> StubViewController {
        let vc = StubViewController()

        vc.with(
            store: store,
            props: { state, store in

                propsEvaluatedExpectation.fulfill()
                return .init(title: state.subStateWithTitle.title)
            },
            removeStateDuplicates: .equal { $0.subStateWithIndex.index }
        )

        return vc
    }
}


extension VCWithStoreWithDeduplicationPropsTests {
    func test_WhenManyNonMutatingActionsAndNotSubscribed_ThenPropsNotEvaluated() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.isInverted = true

        let _ = setupVCForTests(propsEvaluatedExpectation: expectation)

        (0..<actionsCount).forEach { _ in
            store.dispatch(NonMutatingStateAction())
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyNonMutatingActions_ThenPropsEvaluatedOnce() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        let vc = setupVCForTests(propsEvaluatedExpectation: expectation)
        vc.viewDidLoad()

        (0..<actionsCount).forEach { _ in
            store.dispatch(NonMutatingStateAction())
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyMutatingActions_ThenPropsEvaluatedForSubscribtionAndEveryDeduplicatedMutation() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount

        let vc = setupVCForTests(propsEvaluatedExpectation: expectation)
        vc.viewDidLoad()

        (0..<actionsCount).forEach {
            store.dispatch(UpdateIndex(index: $0))
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenMutatingAndNonMutatingActions_ThenPropsEvaluatedForSubscribtionAndEveryDeduplicatedMutation() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount
        
        let vc = setupVCForTests(propsEvaluatedExpectation: expectation)
        vc.viewDidLoad()

        (0..<actionsCount).forEach {
            store.dispatch(UpdateIndex(index: $0))
        }

        (0..<actionsCount).forEach { _ in
            store.dispatch(NonMutatingStateAction())
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenSpecificSubStateMutatingActions_ThenPropsEvaluatedForSubscribtionAndEveryDeduplicatedMutation() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount

        let vc = setupVCForTests(propsEvaluatedExpectation: expectation)
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


extension VCWithStoreWithDeduplicationPropsTests {

    static var allTests = [
        ("test_WhenManyNonMutatingActionsAndNotSubscribed_ThenPropsNotEvaluated",
         test_WhenManyNonMutatingActionsAndNotSubscribed_ThenPropsNotEvaluated),

        ("test_WhenManyNonMutatingActions_ThenPropsEvaluatedOnce",
         test_WhenManyNonMutatingActions_ThenPropsEvaluatedOnce),

        ("test_WhenManyMutatingActions_ThenPropsEvaluatedForSubscribtionAndEveryDeduplicatedMutation",
         test_WhenManyMutatingActions_ThenPropsEvaluatedForSubscribtionAndEveryDeduplicatedMutation),

        ("test_WhenMutatingAndNonMutatingActions_ThenPropsEvaluatedForSubscribtionAndEveryDeduplicatedMutation",
         test_WhenMutatingAndNonMutatingActions_ThenPropsEvaluatedForSubscribtionAndEveryDeduplicatedMutation),

        ("test_WhenSpecificSubStateMutatingActions_ThenPropsEvaluatedForSubscribtionAndEveryDeduplicatedMutation",
         test_WhenSpecificSubStateMutatingActions_ThenPropsEvaluatedForSubscribtionAndEveryDeduplicatedMutation)
    ]
}
