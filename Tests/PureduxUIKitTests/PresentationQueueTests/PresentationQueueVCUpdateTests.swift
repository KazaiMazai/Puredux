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
        let vc = StubViewController()

        vc.with(
            store: store,
            props: { state, store in
                .init(title: state.subStateWithTitle.title)
            },
            presentationQueue: queue
        )

        return vc
    }
}

extension PresentationQueueVCUpdateTests {
    func test_WhenMainQueueProvided_ThenVCUpdatedOnMainThread() {

        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        let vc = setupVCForTests(queue: .main)
        vc.didSetProps = {
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        vc.viewDidLoad()

        waitForExpectations(timeout: timeout)
    }

    func test_WhenSharedPresentationQueueProvided_ThenVCUpdatedOnMainThread() {

        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        let vc = setupVCForTests(queue: .sharedPresentationQueue)
        vc.didSetProps = {
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        vc.viewDidLoad()

        waitForExpectations(timeout: timeout)
    }

    func test_WhenCustomGlobalQueueProvided_ThenVCUpdatedOnMainThread() {

        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        let queue = DispatchQueue(label: "custom.serial.queue")
        let vc = setupVCForTests(queue: .serialQueue(queue))
        vc.didSetProps = {
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        vc.viewDidLoad()

        waitForExpectations(timeout: timeout)
    }

    func test_WhenMainQueueProvidedAsCustom_ThenVCUpdatedOnMainThread() {

        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        let vc = setupVCForTests(queue: .serialQueue(.main))
        vc.didSetProps = {
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        vc.viewDidLoad()

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
         test_WhenMainQueueProvidedAsCustom_ThenVCUpdatedOnMainThread),
    ]
}
