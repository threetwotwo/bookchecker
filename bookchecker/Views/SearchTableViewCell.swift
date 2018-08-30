//
//  SearchTableViewCell.swift
//  bookchecker
//
//  Created by Gary on 8/16/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

	//MARK: - IBOutlets

	@IBOutlet weak var coverImage: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var authorLabel: UILabel!
	@IBOutlet weak var apiSourceButton: DesignableButton!
	

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
