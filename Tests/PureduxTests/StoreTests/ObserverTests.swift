//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03.12.2021.
//

import XCTest
@testable import Puredux

final class ObserverTests: XCTestCase {
    let timeout: TimeInterval = 10

    func test_WhenObserve_ThenObserverClosureCalledWithState() {
        let extectedState = 100

        let asyncExpectation = expectation(description: "Observer handler")

        let observer = Observer<Int> { state, complete in
            asyncExpectation.fulfill()
            XCTAssertEqual(state, extectedState)
            complete(.active)
        }

        observer.send(extectedState) { _  in }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenSendToObserver_ThenObserverStatusReceived() {
        let state = 100
        let extectedStatus = ObserverStatus.active

        let asyncExpectation = expectation(description: "Observer status handler")

        let observer = Observer<Int> { _, complete in
            complete(extectedStatus)
        }

        observer.send(state) { receivedStatus  in
            asyncExpectation.fulfill()
            XCTAssertEqual(extectedStatus, receivedStatus)
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenObserverObjectDeallocated_ThenObserverDies() {
        let asyncExpectation = expectation(description: "Observer handler")
        asyncExpectation.expectedFulfillmentCount = 2
        var someClass: ReferenceTypeObserver? = ReferenceTypeObserver()

        let observer = Observer<Int>(someClass!) { _, complete in
            asyncExpectation.fulfill()
            complete(.active)
        }

        observer.send(100) { _  in }
        observer.send(200) { _  in }
        someClass = nil

        observer.send(200) { status in XCTAssertEqual(status, .dead)}

        waitForExpectations(timeout: timeout)
    }

    func test_WhenObserverObjectIsAlive_ThenObserverClosureCalledWithState() {
        let asyncExpectation = expectation(description: "Observer handler")

        let someClass = ReferenceTypeObserver()

        let observer = Observer<Int>(someClass) { _, complete in
            asyncExpectation.fulfill()
            complete(.active)
        }

        observer.send(100) { status in XCTAssertEqual(status, .active) }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenObserverDedublicatesEqualValues_ThenObserverIsCalledOnce() {
        let asyncExpectation = expectation(description: "Observer handler")
        asyncExpectation.expectedFulfillmentCount = 1
        let someClass = ReferenceTypeObserver()

        let observer = Observer<Int>(someClass, removeStateDuplicates: .alwaysEqual) { _, complete in
            asyncExpectation.fulfill()
            complete(.active)
        }

        observer.send(300) { _ in }
        observer.send(300) { _ in }
        observer.send(300) { _ in }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenObserverDedublicatesAsAlwaysEqual_ThenObserverIsCalledOnce() {
        let asyncExpectation = expectation(description: "Observer handler")
        asyncExpectation.expectedFulfillmentCount = 1
        let someClass = ReferenceTypeObserver()

        let observer = Observer<Int>(someClass, removeStateDuplicates: .alwaysEqual) { _, complete in
            asyncExpectation.fulfill()
            complete(.active)
        }

        observer.send(1) { _ in }
        observer.send(2) { _ in }
        observer.send(3) { _ in }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenObserverDedublicatesAsEquatable_ThenObserverIsCalledAccordingly() {
        let asyncExpectation = expectation(description: "Observer handler")
        asyncExpectation.expectedFulfillmentCount = 3
        let someClass = ReferenceTypeObserver()

        let observer = Observer<Int>(someClass, removeStateDuplicates: .asEquatable) { _, complete in
            asyncExpectation.fulfill()
            complete(.active)
        }

        observer.send(1) { _ in }
        observer.send(2) { _ in }
        observer.send(3) { _ in }

        waitForExpectations(timeout: timeout)
    }
}

class ReferenceTypeObserver {

}
