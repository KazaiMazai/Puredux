import XCTest

import PureduxSwiftUITests

var tests = [XCTestCaseEntry]()
tests += ViewWithStoreRenderTests.allTests()
tests += ContentViewEnvStoreRenderTests.allTests()
XCTMain(tests)
