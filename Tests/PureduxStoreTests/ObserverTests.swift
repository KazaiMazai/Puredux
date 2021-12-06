//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03.12.2021.
//

import XCTest
@testable import PureduxStore

final class ObserverTests: XCTestCase {
    let timeout: TimeInterval = 10

    func test_WhenObserve_ThenObserverClosureCalledWithState() {
        let extectedState = 100

        let expectation = XCTestExpectation(description: "Observer handler")

        let observer = Observer<Int> { state, complete in
            expectation.fulfill()
            XCTAssertEqual(state, extectedState)
            complete(.active)
        }

        observer.send(extectedState) { _  in }

        wait(for: [expectation], timeout: timeout)
    }

    func test_WhenSendToObserver_ThenObserverStatusReceived() {
        let state = 100
        let extectedStatus = ObserverStatus.active

        let expectation = XCTestExpectation(description: "Observer status handler")

        let observer = Observer<Int> { _, complete in
            complete(extectedStatus)
        }

        observer.send(state) { receivedStatus  in
            expectation.fulfill()
            XCTAssertEqual(extectedStatus, receivedStatus)
        }

        wait(for: [expectation], timeout: timeout)
    }

    static var allTests = [
        ("test_WhenObserve_ThenObserverClosureCalledWithState",
         test_WhenObserve_ThenObserverClosureCalledWithState),

        ("test_WhenObserve_ThenObserverStatusReceived",
         test_WhenSendToObserver_ThenObserverStatusReceived)
    ]
}
