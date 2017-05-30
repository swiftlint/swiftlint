/*
   Copyright 2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

import Foundation

import Source
import AST
import Metric

class NCSSRule : RuleBase, ASTVisitorRule {
  static let ThresholdKey = "NCSS"
  static let DefaultThreshold = 30

  let name = "High Non-Commenting Source Statements"
  let identifier = "high_ncss"
  let description = ""
  let markdown = ""
  let severity = Issue.Severity.major
  let category = Issue.Category.readability

  private var threshold: Int {
    return getConfiguration(
      for: NCSSRule.ThresholdKey,
      orDefault: NCSSRule.DefaultThreshold)
  }

  private func emitIssue(_ ncss: Int, _ sourceRange: SourceRange) {
    guard ncss > threshold else {
      return
    }
    emitIssue(
      sourceRange,
      description: "Method of \(ncss) NCSS exceeds limit of \(threshold)")
  }

  func visit(_ funcDecl: FunctionDeclaration) throws -> Bool {
    emitIssue(funcDecl.ncssCount, funcDecl.sourceRange)
    return true
  }

  func visit(_ initDecl: InitializerDeclaration) throws -> Bool {
    emitIssue(initDecl.ncssCount, initDecl.sourceRange)
    return true
  }

  func visit(_ deinitDecl: DeinitializerDeclaration) throws -> Bool {
    emitIssue(deinitDecl.ncssCount, deinitDecl.sourceRange)
    return true
  }

  func visit(_ subscriptDecl: SubscriptDeclaration) throws -> Bool {
    emitIssue(subscriptDecl.ncssCount, subscriptDecl.sourceRange)
    return true
  }
}
