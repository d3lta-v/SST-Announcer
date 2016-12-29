//
//  Logger.swift
//  SST Announcer
//
//  Created by Pan Ziyue on 29/12/16.
//  Copyright © 2016 FourierIndustries. All rights reserved.
//

import XCGLogger

class Logger {

  static let shared = Logger()
  let log: XCGLogger = {
    let l = XCGLogger.init(identifier: "advancedLogger", includeDefaultDestinations: false)
    // swiftlint:disable:next line_length
    let systemDestination = AppleSystemLogDestination(owner: l, identifier: "advancedLogger.systemDestination")
    systemDestination.outputLevel = .debug
    systemDestination.showLogIdentifier = false
    systemDestination.showFunctionName = false
    systemDestination.showThreadName = false
    systemDestination.showLevel = false
    systemDestination.showFileName = false
    systemDestination.showLineNumber = false
    systemDestination.showDate = true
    l.add(destination: systemDestination)
    l.logAppDetails()
    return l
  }()

  private init() {} //prevents others from using Logger()

}
