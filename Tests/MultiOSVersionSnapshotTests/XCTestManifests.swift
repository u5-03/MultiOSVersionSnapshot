import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(MultiOSVersionSnapshotTests.allTests),
    ]
}
#endif
