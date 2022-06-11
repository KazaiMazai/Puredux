//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 07.06.2022.
//

import Foundation

import XCTest
@testable import PureduxUIKit
import PureduxStore

final class PresentationQueueVCUpdateTests: XCTestCase {
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

    func setupVCForTests(queue: PresentationQueue) -> StubViewController {
        let testVC = StubViewController()

        testVC.with(
            store: store,
            props: { state, _ in
                .init(title: state.subStateWithTitle.title)
            },
            presentationQueue: queue
        )

        return testVC
    }
}

extension PresentationQueueVCUpdateTests {
    func test_WhenMainQueueProvided_ThenVCUpdatedOnMainThread() {

        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        let testVC = setupVCForTests(queue: .main)
        testVC.didSetProps = {
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        testVC.viewDidLoad()

        waitForExpectations(timeout: timeout)
    }

    func test_WhenSharedPresentationQueueProvided_ThenVCUpdatedOnMainThread() {

        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        let testVC = setupVCForTests(queue: .sharedPresentationQueue)
        testVC.didSetProps = {
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        testVC.viewDidLoad()

        waitForExpectations(timeout: timeout)
    }

    func test_WhenCustomGlobalQueueProvided_ThenVCUpdatedOnMainThread() {

        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        let queue = DispatchQueue(label: "custom.serial.queue")
        let testVC = setupVCForTests(queue: .serialQueue(queue))
        testVC.didSetProps = {
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        testVC.viewDidLoad()

        waitForExpectations(timeout: timeout)
    }

    func test_WhenMainQueueProvidedAsCustom_ThenVCUpdatedOnMainThread() {

        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        let testVC = setupVCForTests(queue: .serialQueue(.main))
        testVC.didSetProps = {
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        testVC.viewDidLoad()

        waitForExpectations(timeout: timeout)
    }
}

extension PresentationQueueVCUpdateTests {

    static var allTests = [
        ("test_WhenMainQueueProvided_ThenVCUpdatedOnMainThread",
         test_WhenMainQueueProvided_ThenVCUpdatedOnMainThread),

        ("test_WhenSharedPresentationQueueProvided_ThenVCUpdatedOnMainThread",
         test_WhenSharedPresentationQueueProvided_ThenVCUpdatedOnMainThread),

        ("test_WhenCustomGlobalQueueProvided_ThenVCUpdatedOnMainThread",
         test_WhenCustomGlobalQueueProvided_ThenVCUpdatedOnMainThread),

        ("test_WhenMainQueueProvidedAsCustom_ThenVCUpdatedOnMainThread",
         test_WhenMainQueueProvidedAsCustom_ThenVCUpdatedOnMainThread)
    ]
}
