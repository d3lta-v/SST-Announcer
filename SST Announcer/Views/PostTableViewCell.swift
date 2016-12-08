//
//  PostTableViewCell.swift
//  SST Announcer
//
//  Created by Pan Ziyue on 23/11/16.
//  Copyright © 2016 Pan Ziyue. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var chevronImageView: UIImageView!
  @IBOutlet weak var readIndicator: UIImageView!

  @IBOutlet weak var dateWidthConstraint: NSLayoutConstraint!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    chevronImageView.tintColorDidChange() //required to fix bug with tintColor
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

}
