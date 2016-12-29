//
//  AnnouncerError.swift
//  SST Announcer
//
//  Created by Pan Ziyue on 25/12/16.
//  Copyright © 2016 FourierIndustries. All rights reserved.
//

import Foundation

/// A unified system of all the possible errors that the entire Announcer app can
/// propagate from class to class, optimised for maximum interoperability
struct AnnouncerError: LocalizedError {

  /// All possible error types that can occur
  enum ErrorType: Error {
    /// A network error occured
    case networkError
    /// The program was unable to unwrap data from nil to a non-nil value
    case unwrapError
    /// The parser was unable to validate the XML
    case validationError
    /// The parser was unable to parse the XML
    case parseError
    /// An unknown error occured. This error should never occur in the program
    case unknownError
  }

  let errorType: ErrorType
  let errorTypeString: String
  public var errorDescription: String?

  init(type errorType: ErrorType, errorDescription: String? = nil) {
    self.errorType = errorType
    self.errorDescription = errorDescription
    switch errorType {
    case .networkError:
      self.errorTypeString = "Network Error"
    case .unwrapError:
      self.errorTypeString = "Unwrap Error"
    case .validationError:
      self.errorTypeString = "Validation Error"
    case .parseError:
      self.errorTypeString = "Parser Error"
    case .unknownError:
      self.errorTypeString = "Unknown Error"
    }
  }

  func printError() {
    print("\(self.errorTypeString): \(self.errorDescription)")
  }

}
