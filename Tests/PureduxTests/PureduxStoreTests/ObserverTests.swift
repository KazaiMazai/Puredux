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
}
