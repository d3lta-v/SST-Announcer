//
//  SafeArray.swift
//  SST Announcer
//
//  Original by Pete Smith, modified by Pan Ziyue, FourierIndustries for use with SST Announcer
//  http://www.petethedeveloper.com
//
//  License
//  Copyright © 2016-present Pete Smith
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation

/*
 SafeArray is attended to be used in place of a general Swift Array
 It provides thread-safe access to it's underlying Array collection.
 Thread-safe versions Array/Collection methods such as append, map are provided.
 */
public struct SafeArray<Element> {

  // MARK: - Properties
  fileprivate var internalElements = Array<Element>()
  fileprivate var dispatchQueue: DispatchQueue = DispatchQueue(label: "SafeArray queue")

  /// Initializer for the SafeArray type
  ///
  /// - Parameter elements: Optional initial collection of elements
  public init(withElements elements: [Element]? = nil) {
    guard let elements = elements else { return }

    dispatchQueue.sync {
      self.internalElements.append(contentsOf: elements)
    }
  }
}

public extension SafeArray {

  /// Thread-safe get access to the SafeArray's elements
  public var elements: [Element] {
    get {
      var elements: [Element] = []

      dispatchQueue.sync {
        elements.append(contentsOf: internalElements)
      }

      return elements
    }
  }

  /// Thread safe access to the count of the array
  public var count: Int {
    var count = 0

    dispatchQueue.sync {
      count = self.internalElements.count
    }

    return count
  }

  public subscript(index: Int) -> Element {
    set {
      var copy = self
      dispatchQueue.sync {
        copy.internalElements[index] = newValue
      }
      self = copy
    }
    get {
      var element: Element!
      dispatchQueue.sync {
        element = self.internalElements[index]
      }
      return element
    }
  }

  /// Thread-safe insert of a single element
  ///
  /// - parameter newElement: The element to insert into the array
  /// - parameter i: The index to inser the element
  public mutating func insert(_ newElement: Element, at i: Int) {
    dispatchQueue.sync {
      self.internalElements.insert(newElement, at: i)
    }
  }

  /// Resets the SafeArray. Removes all current elements, and adds all the specified elements
  ///
  /// - Parameter elements: Elements to add to SafeArray
  public mutating func reset(withElements elements: [Element]) {
    dispatchQueue.sync {
      self.internalElements = elements
    }
  }

  /// Thread-safe appending of a single element
  ///
  /// - Parameter element: Element to append
  public mutating func append(_ element: Element) {
    dispatchQueue.sync {
      internalElements.append(element)
    }
  }

  /// Thread-safe appending of a collection of Elements
  ///
  /// - Parameter elements: Collection to append
  public mutating func append(contentsOf elements: [Element]) {
    dispatchQueue.sync {
      self.internalElements.append(contentsOf: elements)
    }
  }

  /// Thread-safe removing of the last element
  /// 
  /// - parameter n: Number of elements to remove. Defaults to 1
  public mutating func removeLast(_ n: Int = 1) {
    _ = dispatchQueue.sync {
      self.internalElements.removeLast(n)
    }
  }

  /// Sorts the array in increasing order
  /// - parameter areInIncreasingOrder: A predicate that returns true when 1st arg > 2nd arg
  public mutating func sort(by areInIncreasingOrder: (Element, Element) -> Bool) {
    dispatchQueue.sync {
      self.internalElements.sort(by: areInIncreasingOrder)
    }
  }

  /// Map method which returns an Array containing elements creating by the supplied transform
  ///
  /// - Parameter transform: Transform closure
  /// - Returns: Array of elements created by the map method
  /// - Throws: Possible Throw
  public func map<T>(_ transform: (Element) throws -> T) rethrows -> SafeArray<T> {
    var safeArray = SafeArray<T>()

    var results: [T] = []

    try dispatchQueue.sync {
      results = try self.internalElements.map(transform)
    }

    safeArray.append(contentsOf: results)

    return safeArray
  }

  /// Filter method which returns an Array containing elements which should be included
  ///
  /// - Parameter isIncluded: Closure for determining if element should be included in `return`
  /// - Returns: Array of filtered elements
  /// - Throws: Possible Throw
  public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> SafeArray<Element> {
    var safeArray = SafeArray<Element>()

    var results: [Element] = []

    try dispatchQueue.sync {
      results = try self.internalElements.filter(isIncluded)
    }
    safeArray.append(contentsOf: results)

    return safeArray
  }

}
