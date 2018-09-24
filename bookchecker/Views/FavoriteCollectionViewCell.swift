//
//  FavoriteCollectionViewCell.swift
//  bookchecker
//
//  Created by Gary on 8/21/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit

class FavoriteCollectionViewCell: UICollectionViewCell {
    
	@IBOutlet weak var coverImage: UIImageView!
	@IBOutlet weak var deleteButton: UIButton!

	var bookID: String?

	@IBAction func deleteButtonPressed(_ sender: Any) {
		guard let bookID = bookID,
		let realmBook = DBManager.shared.getBooks().filter("id == %@", bookID).first  else {return}

		DBManager.shared.deleteBook(object: realmBook)
	}

}
