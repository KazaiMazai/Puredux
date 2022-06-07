import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(PresentationQueuePropsEvaluationTests.allTests),
        testCase(PresentationQueueVCUpdateTests.allTests),

        testCase(VCWithStoreWithAlwaysEqualDeduplicationPropsTests.allTests),
        testCase(VCWithStoreWithDeduplicationPropsTests.allTests),
        testCase(VCWithStoreWithoutDeduplicationPropsTests.allTests),

        testCase(VCWithStoreWithAlwaysEqualDeduplicationVCTests),
        testCase(VCWithStoreWithDeduplicationVCTests.allTests),
        testCase(VCWithStoreWithoutDeduplicationVCTests.allTests)
    ]
}
#endif
