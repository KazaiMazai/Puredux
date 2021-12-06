import XCTest

import PureduxStoreTests

var tests = [XCTestCaseEntry]()
tests += ObserverTests.allTests()
tests += RootStoreProxyTests.allTests()
tests += RootStoreQueueTests.allTests()
tests += RootStoreRefCyclesTests.allTests()
tests += RootStoreTests.allTests()
XCTMain(tests)
