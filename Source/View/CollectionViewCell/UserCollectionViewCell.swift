//
//  UserCollectionViewCell.swift
//  Cacher
//
//  Created by Prajwal Lobo on 19/03/18.
//  Copyright © 2018 Prajwal Lobo. All rights reserved.
//

import UIKit

class UserCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    class func loadNib() -> UINib{
        return UINib(nibName: "UserCollectionViewCell", bundle: nil)
    }

}
