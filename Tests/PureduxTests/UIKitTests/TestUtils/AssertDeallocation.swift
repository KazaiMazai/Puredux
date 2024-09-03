//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26/08/2024.
//

import XCTest

extension XCTestCase {
    func assertDeallocated<T: AnyObject>(of object: @escaping () -> T) {
        assertDeallocation(inversed: false, of: object)
    }

    func assertNotDeallocated<T: AnyObject>(of object: @escaping () -> T) {
        assertDeallocation(inversed: true, of: object)
    }
}

extension XCTestCase {
    private func assertDeallocation<T: AnyObject>(inversed: Bool,
                                          of object: @escaping () -> T) {

        weak var weakReferenceToObject: T?

        let autoreleasepoolExpectation = expectation(description: "Autoreleasepool should drain")

        autoreleasepool {
            let object = object()

            weakReferenceToObject = object

            XCTAssertNotNil(weakReferenceToObject)

            autoreleasepoolExpectation.fulfill()
        }

        wait(for: [autoreleasepoolExpectation], timeout: 10.0)
        let message = inversed ?
            "The object should not be deallocated"
            : "The object should be deallocated since no strong reference points to it."
        wait(inversed: inversed, for: weakReferenceToObject == nil, timeout: 3.0, description: message)
    }
}

extension XCTestCase {

    /// Checks for the callback to be the expected value within the given timeout.
    ///
    /// - Parameters:
    ///   - condition: The condition to check for.
    ///   - timeout: The timeout in which the callback should return true.
    ///   - description: A string to display in the test log for this expectation, to help diagnose failures.
    func wait(inversed: Bool = false,
              for condition: @autoclosure @escaping () -> Bool,
              timeout: TimeInterval,
              description: String,
              file: StaticString = #file,
              line: UInt = #line) {

        let end = Date().addingTimeInterval(timeout)

        var value: Bool = false
        let closure: () -> Void = {
            value = condition()
        }

        while !value && 0 < end.timeIntervalSinceNow {
            if RunLoop.current.run(mode: RunLoop.Mode.default, before: Date(timeIntervalSinceNow: 0.002)) {
                Thread.sleep(forTimeInterval: 0.002)
            }
            closure()
        }

        closure()
        guard inversed else {
            XCTAssertTrue(value, "Timed out waiting for condition to be true: \"\(description)\"", file: file, line: line)
            return
        }

        XCTAssertFalse(value, "Unexpected condition met: \"\(description)\"", file: file, line: line)
    }
}
