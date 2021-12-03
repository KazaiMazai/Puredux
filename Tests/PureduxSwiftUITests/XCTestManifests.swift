import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ViewWithStoreRenderTests.allTests),
        testCase(ContentViewEnvStoreRenderTests.allTests),
    ]
}
#endif
