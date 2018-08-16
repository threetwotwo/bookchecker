//
//  FeedTableViewCell.swift
//  bookchecker
//
//  Created by Gary on 8/13/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {

	//MARK: - IBActions and Outlets
	@IBOutlet weak var feedCollection: UICollectionView!

	//MARK: - Variables
	let baseURL = "https://www.googleapis.com/books/v1/volumes"

	var genre: String? {
		didSet {
			loadBooks()
		}
	}
	var books: [Book] = [] {
		didSet {
			for book in books {
				if let thumbnail = book.thumbnail {
					Services.shared.getBookImage(from: thumbnail) { (image) in
						self.coverImages.append(image)
					}
				}
			}
			feedCollection.reloadData()
		}
	}

	var coverImages: [UIImage?] = []

	//MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		loadBooks()
    }

	override func layoutSubviews() {
		feedCollection.dataSource = self
	}

	//MARK: - Network call

	fileprivate func loadBooks() {
		guard let genre = genre else {return}
		Services.shared.getBooks(from: baseURL, params: ["q" : genre]) { (books) in
			self.books = books
		}
	}

}

//MARK: - Collection View Data Source

extension FeedTableViewCell: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return books.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! FeedCollectionViewCell
		return cell
	}

	override func prepareForReuse() {
		super.prepareForReuse()
	}

}
