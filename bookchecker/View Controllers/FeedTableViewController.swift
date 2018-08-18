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
	let queries = [
		"potter",
		"mommy",
		"john",
		"dumpster",
		"bear",
		"dota",
		"competition",
		"hiking",
		"gentle",
		"rough"
	]

	var books: [[Book]] = []
	var storedOffsets: [CGFloat] = []

	//MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
		for i in 0..<queries.count {
			Services.shared.getBooks(from: Services.baseURL, params: ["q" : queries[i]]) { (books) in
				self.books.append(books)
				print(books.first!.title)
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
//		cell.feedCollection.tag = (100 * indexPath.section) + 1
		cell.feedCollection.tag = indexPath.section

		cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.section)
	}

}

//MARK: - UICollectionViewDataSource
extension FeedTableViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard books.count > collectionView.tag else {
			return 0
		}
		return books[collectionView.tag].count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! FeedCollectionViewCell
		cell.textLabel.text = "\(queries[collectionView.tag]) \(indexPath.row)"
		let book = books[collectionView.tag][indexPath.row]
		Services.shared.getBookImage(from: book.thumbnail ?? "") { (image) in
			cell.coverImage.image = image
		}
		return cell
	}

}

//MARK: - UICollectionViewDelegate
extension FeedTableViewController: UICollectionViewDelegate {
	
}

extension Dictionary where Value: Equatable {
	/// Returns all keys mapped to the specified value.
	/// ```
	/// let dict = ["A": 1, "B": 2, "C": 3]
	/// let keys = dict.keysForValue(2)
	/// assert(keys == ["B"])
	/// assert(dict["B"] == 2)
	/// ```
	func keyForValue(value: Value) -> Key {
		return compactMap { (key: Key, val: Value) -> Key? in
			value == val ? key : nil
			}.first!
	}
}
