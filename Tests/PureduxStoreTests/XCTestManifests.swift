import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ObserverTests.allTests),
        testCase(RootStoreProxyTests.allTests),
        testCase(RootStoreQueueTests.allTests),
        testCase(RootStoreRefCyclesTests.allTests),
        testCase(RootStoreTests.allTests)
    ]
}
#endif
