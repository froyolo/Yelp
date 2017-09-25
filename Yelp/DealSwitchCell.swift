//
//  DealSwitchCell.swift
//  Yelp
//
//  Created by Ngan, Naomi on 9/24/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

class DealSwitchCell: UITableViewCell {

    @IBOutlet weak var dealSwitch: UISwitch!
    var switchHandler: (Bool) -> Void = { (isOn: Bool) in }
    
    @IBAction func onSwitchChanged(_ sender: UISwitch) {
        switchHandler(sender.isOn)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
