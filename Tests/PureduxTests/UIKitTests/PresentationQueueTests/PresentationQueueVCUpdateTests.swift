//
//  File.swift
//
//
//  Created by Sergey Kazakov on 07.06.2022.
//

import Foundation

import XCTest
@testable import Puredux


final class PresentationQueueVCUpdateTests: XCTestCase {
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
    
    
    func setupVCForTests(queue: DispatchQueue) -> StubViewController {
        let testVC = StubViewController()
        
        testVC.setPresenter(
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
        let testVC = setupVCForTests(queue: queue)
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
        
        let testVC = setupVCForTests(queue: .main)
        testVC.didSetProps = {
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        testVC.viewDidLoad()
        
        waitForExpectations(timeout: timeout)
    }
}
