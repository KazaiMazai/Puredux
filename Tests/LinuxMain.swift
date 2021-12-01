import XCTest

import PureduxSwiftUITests

var tests = [XCTestCaseEntry]()
tests += ContentViewWithStoreRenderTests.allTests()
tests += ContentViewEnvStoreRenderTests.allTests()
XCTMain(tests)
