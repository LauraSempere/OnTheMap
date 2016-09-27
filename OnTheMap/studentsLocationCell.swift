//
//  studentsLocationCell.swift
//  OnTheMap
//
//  Created by Laura Scully on 27/9/2016.
//  Copyright © 2016 laura.sempere.com. All rights reserved.
//

import UIKit

class studentsLocationCell: UITableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
