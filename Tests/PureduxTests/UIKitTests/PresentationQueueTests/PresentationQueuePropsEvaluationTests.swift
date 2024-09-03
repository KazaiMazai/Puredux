//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 07.06.2022.
//

import XCTest
@testable import Puredux

final class PresentationQueuePropsEvaluationTests: XCTestCase {
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

    func setupVCForTests(queue: DispatchQueue, makeProps: @escaping () -> Void) -> StubViewController {
        let testVC = StubViewController()

        testVC.setPresenter(
            store: store,
            props: { state, _ in
                makeProps()
                return .init(title: state.subStateWithTitle.title)
            },
            presentationQueue: queue
        )

        return testVC
    }
}

extension PresentationQueuePropsEvaluationTests {
    func test_WhenMainQueueProvided_ThenPropsEvaluatedOnMainThread() {

        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        let makeProps = {
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }

        let testVC = setupVCForTests(queue: .main, makeProps: makeProps)
        testVC.viewDidLoad()

        waitForExpectations(timeout: timeout)
    }

    func test_WhenSharedPresentationQueueProvided_ThenPropsEvaluatedNotOnMainThread() {

        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        let makeProps = {
            XCTAssertFalse(Thread.isMainThread)
            expectation.fulfill()
        }

        let testVC = setupVCForTests(queue: .sharedPresentationQueue, makeProps: makeProps)
        testVC.viewDidLoad()

        waitForExpectations(timeout: timeout)
    }

    func test_WhenCustomGlobalQueueProvided_ThenPropsEvaluatedNotOnMainThread() {

        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        let makeProps = {
            XCTAssertFalse(Thread.isMainThread)
            expectation.fulfill()
        }

        let queue = DispatchQueue(label: "custom.serial.queue")
        let testVC = setupVCForTests(queue: queue, makeProps: makeProps)
        testVC.viewDidLoad()

        waitForExpectations(timeout: timeout)
    }

    func test_WhenMainQueueProvidedAsCustom_ThenPropsEvaluatedOnMainThread() {

        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        let makeProps = {
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }

        let testVC = setupVCForTests(queue: .main, makeProps: makeProps)
        testVC.viewDidLoad()

        waitForExpectations(timeout: timeout)
    }
}
