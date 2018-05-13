//
//  RandomNumberTests.swift
//  SwiftExtensionsTests
//
//  Created by Michael Bachand on 5/12/18.
//

import XCTest
@testable import SwiftExtensions

final class RandomNumberTests: XCTestCase {

  func testThatAllAllowedValuesAreUtilized() {
    let allowedValues = 0...99

    // Let's assume that if we run this `allowedValues.upperBound` * 100 times that it would be
    // _highly improbable_ not to see each value. As such, even though this test isn't guaranteed
    // to succeed, the false negative rate should be acceptably low.
    var seenValueCounts = Array<UInt>.init(repeating: 0, count: allowedValues.count)
    for _ in 0...(allowedValues.upperBound * 100) {
      var randomNumber = try! RandomNumber(count: Int32(allowedValues.count))
      seenValueCounts[Int(randomNumber.value)] += 1
    }

    for value in allowedValues {
      XCTAssertTrue(seenValueCounts[value] > 0)
    }
  }
}
