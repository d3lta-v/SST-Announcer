//
//  StringExtensions+DTCoreText.swift
//  SST Announcer
//
//  Created by Pan Ziyue on 17/12/16.
//  Copyright © 2016 FourierIndustries. All rights reserved.
//

import Foundation
import DTCoreText

extension String {

  static func getPixelSizeForDynamicType() -> String {
    // Support for Dynamic Type for DTCoreText!!!
    let preferredSizeCategory = UIApplication.shared.preferredContentSizeCategory
    var size = "" // Font size
    switch preferredSizeCategory {
    case UIContentSizeCategory.extraSmall:
      size = "13.5px"
    case UIContentSizeCategory.small:
      size = "14px"
    case UIContentSizeCategory.medium:
      size = "15.5px"
    case UIContentSizeCategory.large:
      size = "17px"
    case UIContentSizeCategory.extraLarge:
      size = "18.5px"
    case UIContentSizeCategory.extraExtraLarge:
      size = "20px"
    case UIContentSizeCategory.extraExtraExtraLarge:
      size = "21.5px"
    case UIContentSizeCategory.accessibilityMedium:
      size = "24px"
    case UIContentSizeCategory.accessibilityLarge:
      size = "27px"
    case UIContentSizeCategory.accessibilityExtraLarge:
      size = "30px"
    case UIContentSizeCategory.accessibilityExtraExtraLarge:
      size = "33px"
    case UIContentSizeCategory.accessibilityExtraExtraExtraLarge:
      size = "36px"
    default:
      size = "16.4px"
    }
    return size
  }

}
