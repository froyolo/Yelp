//
//  BusinessDetailViewController.swift
//  Yelp
//
//  Created by Ngan, Naomi on 9/24/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessDetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var reviewsCountLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var posterView: UIImageView!
    
    var business: Business!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = business.name        
        categoriesLabel.text = business.categories
        distanceLabel.text = business.distance
        reviewsCountLabel.text = "\(business.reviewCount!) Reviews"
        ratingImageView.setImageWith(business.ratingImageURL!)
        addressLabel.text = business.address
        
        if let imageURL = business.imageURL {
            posterView.setImageWith(imageURL)
        } else {
            posterView.image = UIImage(named: "buildings2")
        }
    }

}
