//
//  FeedTableViewController.swift
//  bookchecker
//
//  Created by Gary on 8/13/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FeedTableViewController: UITableViewController {
	//MARK: - Variables

	fileprivate var tableViewCellCoordinator: [IndexPath: Int] = [:]
	let queries: [Int : String] = [
		0 :	"potter",
		1 :	"mommy",
		2 :	"john",
		3 :	"dumpster",
		4 :	"bear",
		5 :	"dota",
		6 :	"competition",
		7 :	"hiking",
		8 :	"gentle",
		9 :	"rough"
	]

	var booksArray: [Int : [Book]] = [ : ]
    var storedOffsets = [Int: CGFloat]()

	//MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
		for i in 0..<queries.count {
			Services.shared.getBooks(from: Services.baseURL, params: ["q" : queries[i]!]) { (books) in
				self.booksArray[i] = books
				self.tableView.reloadData()
			}
		}
    }


	//MARK: - UITableViewDataSource
	override func numberOfSections(in tableView: UITableView) -> Int {
		return queries.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return queries[section]
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedTableViewCell
		return cell
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let cell = cell as! FeedTableViewCell
		cell.feedCollection.tag = indexPath.section
		cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.section)
		cell.collectionViewOffset = storedOffsets[indexPath.section] ?? 0
	}

	override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let cell = cell as! FeedTableViewCell
		storedOffsets[indexPath.section] = cell.collectionViewOffset
	}
}

//MARK: - UICollectionViewDataSource
extension FeedTableViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return booksArray[collectionView.tag]?.count ?? 0
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! FeedCollectionViewCell
		cell.textLabel.text = "\(queries[collectionView.tag] ?? "") \(indexPath.row)"
		if let book = booksArray[collectionView.tag]?[indexPath.item] {
			Services.shared.getBookImage(from: book.thumbnail ?? "") { (image) in
				cell.coverImage.image = image
			}
		}
		return cell
	}

}

//MARK: - UICollectionViewDelegate
extension FeedTableViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		print("Selected cell with category \(queries[collectionView.tag] ?? "") at index \(indexPath.row)")
	}
}


