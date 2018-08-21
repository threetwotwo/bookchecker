//
//  FavoriteCollectionViewController.swift
//  bookchecker
//
//  Created by Gary on 8/21/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit

private let reuseIdentifier = "FavoriteCollectionCell"

class FavoriteCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		collectionView?.delegate = self
    }

    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 500
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FavoriteCollectionViewCell
    
        // Configure the cell
        return cell
    }
}

//MARK: - UICollectionViewLayout

extension FavoriteCollectionViewController: UICollectionViewDelegateFlowLayout {

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		// Number of cells
		let collectionViewWidth = UIScreen.main.bounds.width/3 - 20
		let collectionViewHeight = collectionViewWidth

		return CGSize(width: collectionViewWidth, height: collectionViewHeight/5*8)
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 10
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 10
	}
}
