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

        let observer = Observer<Int> { state in
            asyncExpectation.fulfill()
            XCTAssertEqual(state, extectedState)
            return .active
        }

        let _ = observer.send(extectedState) 

        waitForExpectations(timeout: timeout)
    }

    func test_WhenSendToObserver_ThenObserverStatusReceived() {
        let state = 100
        let extectedStatus = ObserverStatus.active
 
        let observer = Observer<Int> { _ in
            return extectedStatus
        }

        let receivedStatus = observer.send(state)
        XCTAssertEqual(extectedStatus, receivedStatus)
    }

    func test_WhenObserverObjectDeallocated_ThenObserverDies() {
        let asyncExpectation = expectation(description: "Observer handler")
        asyncExpectation.expectedFulfillmentCount = 2
        var someClass: ReferenceTypeObserver? = ReferenceTypeObserver()

        let observer = Observer<Int>(someClass!) { _ in
            asyncExpectation.fulfill()
            return .active
        }

        let _ = observer.send(100)
        let _ = observer.send(200)
        someClass = nil

        let status = observer.send(200)
        XCTAssertEqual(status, .dead)

        waitForExpectations(timeout: timeout)
    }

    func test_WhenObserverObjectIsAlive_ThenObserverClosureCalledWithState() {
        let asyncExpectation = expectation(description: "Observer handler")

        let someClass = ReferenceTypeObserver()

        let observer = Observer<Int>(someClass) { _ in
            asyncExpectation.fulfill()
            return .active
        }

        let status = observer.send(100)
        XCTAssertEqual(status, .active)
        
        waitForExpectations(timeout: timeout)
    }

    func test_WhenObserverDedublicatesEqualValues_ThenObserverIsCalledOnce() {
        let asyncExpectation = expectation(description: "Observer handler")
        asyncExpectation.expectedFulfillmentCount = 1
        let someClass = ReferenceTypeObserver()

        let observer = Observer<Int>(someClass, removeStateDuplicates: .alwaysEqual) { _ in
            asyncExpectation.fulfill()
            return .active
        }

        let _ = observer.send(300)
        let _ = observer.send(300)
        let _ = observer.send(300)

        waitForExpectations(timeout: timeout)
    }

    func test_WhenObserverDedublicatesAsAlwaysEqual_ThenObserverIsCalledOnce() {
        let asyncExpectation = expectation(description: "Observer handler")
        asyncExpectation.expectedFulfillmentCount = 1
        let someClass = ReferenceTypeObserver()

        let observer = Observer<Int>(someClass, removeStateDuplicates: .alwaysEqual) { _ in
            asyncExpectation.fulfill()
            return .active
        }

        let _ = observer.send(1)
        let _ = observer.send(2)
        let _ = observer.send(3)

        waitForExpectations(timeout: timeout)
    }

    func test_WhenObserverDedublicatesAsEquatable_ThenObserverIsCalledAccordingly() {
        let asyncExpectation = expectation(description: "Observer handler")
        asyncExpectation.expectedFulfillmentCount = 3
        let someClass = ReferenceTypeObserver()

        let observer = Observer<Int>(someClass, removeStateDuplicates: .asEquatable) { _ in
            asyncExpectation.fulfill()
            return .active
        }

        let _ = observer.send(1)
        let _ = observer.send(2)
        let _ = observer.send(3)

        waitForExpectations(timeout: timeout)
    }
}

class ReferenceTypeObserver {

}
