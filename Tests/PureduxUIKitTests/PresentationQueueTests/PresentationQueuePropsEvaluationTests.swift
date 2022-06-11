//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 07.06.2022.
//

import XCTest
@testable import PureduxUIKit
import PureduxStore

final class PresentationQueuePropsEvaluationTests: XCTestCase {
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

    func setupVCForTests(queue: PresentationQueue, makeProps: @escaping () -> Void) -> StubViewController {
        let testVC = StubViewController()

        testVC.with(
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
        let testVC = setupVCForTests(queue: .serialQueue(queue), makeProps: makeProps)
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

        let testVC = setupVCForTests(queue: .serialQueue(.main), makeProps: makeProps)
        testVC.viewDidLoad()

        waitForExpectations(timeout: timeout)
    }
}

extension PresentationQueuePropsEvaluationTests {

    static var allTests = [
        ("test_WhenMainQueueProvided_ThenPropsEvaluatedOnMainThread",
         test_WhenMainQueueProvided_ThenPropsEvaluatedOnMainThread),

        ("test_WhenSharedPresentationQueueProvided_ThenPropsEvaluatedNotOnMainThread",
         test_WhenSharedPresentationQueueProvided_ThenPropsEvaluatedNotOnMainThread),

        ("test_WhenCustomGlobalQueueProvided_ThenPropsEvaluatedNotOnMainThread",
         test_WhenCustomGlobalQueueProvided_ThenPropsEvaluatedNotOnMainThread),

        ("test_WhenMainQueueProvidedAsCustom_ThenPropsEvaluatedOnMainThread",
         test_WhenMainQueueProvidedAsCustom_ThenPropsEvaluatedOnMainThread)

    ]
}
