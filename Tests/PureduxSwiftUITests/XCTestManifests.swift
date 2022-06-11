import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ViewWithStoreRenderTests.allTests),
        testCase(ViewEnvStoreRenderTests.allTests),

        testCase(ViewEnvStoreWithAlwaysEqualDeduplicationPropsTests.allTests),
        testCase(ViewWithStoreWithAlwaysEqualDeduplicationPropsTests.allTests),

        testCase(ViewEnvStoreDeduplicationTests.allTests),
        testCase(ViewWithStoreDeduplicationTests.allTests),

        testCase(ViewEnvStoreWithoutDeduplicationPropsTests.allTests),
        testCase(ViewWithStoreWithoutDeduplicationPropsTests.allTests),
    ]
}
#endif
