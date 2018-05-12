//
//  RandomNumber.swift
//  SwiftExtensions
//
//  Created by Michael Bachand on 5/12/18.
//

import Darwin

// MARK: - RandomNumber

public struct RandomNumber {

  typealias Value = Int

  // MARK: Lifecycle

  /// - param allowedValues: Count must be fit in a UInt32.
  init(_ allowedValues: CountableClosedRange<Value> = 0...9) throws {
    guard allowedValues.lowerBound >= 0 else { throw RandomNumberError.notImplemented }
    guard UInt32(exactly: allowedValues.count) != nil else { throw RandomNumberError.tooLarge }
    self.allowedValues = allowedValues
  }

  // MARK: Private

  private let allowedValues: CountableClosedRange<Value>

  lazy var value: Value = {
    // This downcase is OK since we assert in the initalizer.
    let arc4random_upper_bound = UInt32(allowedValues.upperBound + 1)
    return Int(arc4random_uniform(arc4random_upper_bound))
  }()
}

// MARK: - RandomNumberError
public enum RandomNumberError: Error {
  /// The count of `allowedValues` must fit in a UInt32 due to limitations in Apple's `arc4random` library.
  case tooLarge
  /// This fucntionality is intended to exist but hasn't yet been implemented.
  case notImplemented
}
