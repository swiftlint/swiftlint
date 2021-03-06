/*
   Copyright 2016-2017 Ryuichi Laboratories and the Yanagiba project contributors

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

import XCTest

@testable import Lint
@testable import Source

class TextReporterTests : XCTestCase {
  let textReporter = TextReporter()

  func testReportIssues() {
    let testIssue = Issue(
      ruleIdentifier: "rule_id",
      description: "text description for testing",
      category: .badPractice,
      location: SourceRange(
        start: SourceLocation(identifier: "test/testTextReporterStart", line: 1, column: 2),
        end: SourceLocation(identifier: "test/testTextReporterEnd", line: 3, column: 4)),
      severity: .major,
      correction: nil)
    XCTAssertEqual(
      textReporter.handle(issues: [testIssue, testIssue, testIssue]),
      """
      test/testTextReporterStart:1:2-3:4: major: rule_id: text description for testing
      test/testTextReporterStart:1:2-3:4: major: rule_id: text description for testing
      test/testTextReporterStart:1:2-3:4: major: rule_id: text description for testing
      """)
  }

  func testReportIssueWithCurrentDirectoryPathTrimmed() {
    let pwd = FileManager.default.currentDirectoryPath
    let testIssue = Issue(
      ruleIdentifier: "rule_id",
      description: "text description for testing",
      category: .badPractice,
      location: SourceRange(
        start: SourceLocation(identifier: "\(pwd)/test/testTextReporterStart", line: 1, column: 2),
        end: SourceLocation(identifier: "\(pwd)/test/testTextReporterEnd", line: 3, column: 4)),
      severity: .critical,
      correction: nil)
    XCTAssertEqual(
      textReporter.handle(issues: [testIssue]),
      "test/testTextReporterStart:1:2-3:4: critical: rule_id: text description for testing")
  }

  func testReportIssueWithEmptyDescription() {
    let testIssue = Issue(
      ruleIdentifier: "rule_id",
      description: "",
      category: .badPractice,
      location: SourceRange(
        start: SourceLocation(identifier: "test", line: 1, column: 2),
        end: SourceLocation(identifier: "testEnd", line: 3, column: 4)),
      severity: .minor,
      correction: nil)
    XCTAssertEqual(textReporter.handle(issues: [testIssue]), "test:1:2-3:4: minor: rule_id")
  }

  func testReportSummary() {
    for (index, severity) in Issue.Severity.allSeverities.enumerated() {
      let testIssue = Issue(
        ruleIdentifier: "rule_id",
        description: "",
        category: .badPractice,
        location: .EMPTY,
        severity: severity,
        correction: nil)
      let issueSummary = IssueSummary(issues: [testIssue])
      var numIssues = [0, 0, 0, 0]
      numIssues[index] = 1
      XCTAssertEqual(
        textReporter.handle(numberOfTotalFiles: index, issueSummary: issueSummary),
        """
        Summary:
        Within a total number of \(index) files, 1 file have issues.
        Number of critical issues: \(numIssues[0])
        Number of major issues: \(numIssues[1])
        Number of minor issues: \(numIssues[2])
        Number of cosmetic issues: \(numIssues[3])
        """)
    }
  }

  func testReportSummaryForMultipleIssues() {
    let testIssues = [
      Issue(
        ruleIdentifier: "rule_id",
        description: "",
        category: .badPractice,
        location: .EMPTY,
        severity: .cosmetic,
        correction: nil),
      Issue(
        ruleIdentifier: "rule_id",
        description: "",
        category: .badPractice,
        location: .INVALID,
        severity: .cosmetic,
        correction: nil),
    ]
    let issueSummary = IssueSummary(issues: testIssues)
    XCTAssertEqual(
      textReporter.handle(numberOfTotalFiles: 2, issueSummary: issueSummary),
      """
      Summary:
      Within a total number of 2 files, 2 files have issues.
      Number of critical issues: 0
      Number of major issues: 0
      Number of minor issues: 0
      Number of cosmetic issues: 2
      """)
  }

  func testNoIssue() {
    let issueSummary = IssueSummary(issues: [])
    XCTAssertEqual(
      textReporter.handle(numberOfTotalFiles: 100, issueSummary: issueSummary),
      "Good job! Inspected 100 files, found no issue.")
    XCTAssertTrue(textReporter.handle(issues: []).isEmpty)
  }

  func testHeader() {
    XCTAssertTrue(textReporter.header.hasPrefix("Yanagiba's swift-lint (http://yanagiba.org/swift-lint) v"))
    XCTAssertTrue(textReporter.header.contains(" Report"))
  }

  func testFooter() {
    XCTAssertTrue(textReporter.footer.isEmpty)
  }

  func testSeparator() {
    XCTAssertEqual(textReporter.separator, "\n")
  }

  static var allTests = [
    ("testReportIssues", testReportIssues),
    ("testReportIssueWithCurrentDirectoryPathTrimmed", testReportIssueWithCurrentDirectoryPathTrimmed),
    ("testReportIssueWithEmptyDescription", testReportIssueWithEmptyDescription),
    ("testReportSummary", testReportSummary),
    ("testReportSummaryForMultipleIssues", testReportSummaryForMultipleIssues),
    ("testNoIssue", testNoIssue),
    ("testHeader", testHeader),
    ("testFooter", testFooter),
    ("testSeparator", testSeparator),
  ]
}
