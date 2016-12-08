//
//  UITraitCollectionExtensions.swift
//  SST Announcer
//
//  Created by Pan Ziyue on 8/12/16.
//  Copyright © 2016 FourierIndustries. All rights reserved.
//

import UIKit

extension UITraitCollection {

  /// A computed property for checking if the current trait collection is Compact, Regular
  var isCR: Bool {
    return self.horizontalSizeClass == .compact && self.verticalSizeClass == .regular
  }

  /// A computed property for checking if the current trait collection is Compact, Compact
  var isCC: Bool {
    return self.horizontalSizeClass == .compact && self.verticalSizeClass == .compact
  }

}
