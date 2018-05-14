//
//  RandomNumber.swift
//  SwiftExtensions
//
//  Created by Michael Bachand on 5/12/18.
//

import Darwin

// MARK: - RandomNumber

/// By default a `RandomNumber` represents a value between 0 and 9, inclusive.
public struct RandomNumber {

  public typealias Value = UInt32

  // MARK: Lifecycle

  /// - param start: The start of the inclusive range of allowed values.
  /// - param start: The number of allowed values.
  public init(start: Int = 0, count: UInt32 = 10) throws {
    guard start >= 0 else { throw RandomNumberError.notImplemented }
    self.start = start
    self.count = count
  }

  // MARK: Public

  public var possibleValues: CountableRange<Int> {
    // Casting an `Int32` to an `Int` is lossless.
    return (start..<(Int(count)-start))
  }

  public lazy var value: Value = {
    // Eventually I will want to shift this value based on `start`.
    return arc4random_uniform(count)
  }()

  // MARK: Private

  private let start: Int
  private let count: UInt32
}

// MARK: - RandomNumberError

public enum RandomNumberError: Error {
  /// This fucntionality is intended to exist but hasn't yet been implemented.
  case notImplemented
}
