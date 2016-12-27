//
//  AnnouncerErrorExtensions.swift
//  SST Announcer
//
//  Created by Pan Ziyue on 27/12/16.
//  Copyright © 2016 FourierIndustries. All rights reserved.
//

import Foundation
import Crashlytics

/// This extension was built specifically for the iPhone version for use with Crashlytics
extension AnnouncerError {

  /// Log the current error to Crashlytics/Fabric
  func relayTelemetry() {
    let attributes = ["description": localizedDescription]
    Answers.logCustomEvent(withName: errorTypeString, customAttributes: attributes)
  }

}
