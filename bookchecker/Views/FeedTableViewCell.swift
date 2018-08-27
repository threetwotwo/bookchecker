//
//  FeedTableViewCell.swift
//  bookchecker
//
//  Created by Gary on 8/13/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
	//MARK: - IBOutlet
	@IBOutlet weak var feedCollection: UICollectionView!
}

extension FeedTableViewCell {

	func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
		feedCollection.delegate = dataSourceDelegate
		feedCollection.dataSource = dataSourceDelegate
		feedCollection.setContentOffset(feedCollection.contentOffset, animated:false) // Stops collection view if it was scrolling.
		feedCollection.reloadData()

	}

	var collectionViewOffset: CGFloat {
		set { feedCollection.contentOffset.x = newValue }
		get { return feedCollection.contentOffset.x }
	}
}
