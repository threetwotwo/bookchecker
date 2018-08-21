//
//  FeedCollectionViewCell.swift
//  bookchecker
//
//  Created by Gary on 8/13/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit

class FeedCollectionViewCell: UICollectionViewCell {
    
	@IBOutlet weak var coverImage: UIImageView!

	var imageURL: String?

	override func prepareForReuse() {
		super.prepareForReuse()
		coverImage.image = nil
	}
}
