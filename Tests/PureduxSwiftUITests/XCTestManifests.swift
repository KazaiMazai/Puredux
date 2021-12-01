import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ContentViewWithStoreRenderTests.allTests),
        testCase(ContentViewEnvStoreRenderTests.allTests),
    ]
}
#endif
