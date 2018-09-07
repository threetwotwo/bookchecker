//
//  FeedTableViewController.swift
//  bookchecker
//
//  Created by Gary on 8/13/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import SDWebImage

class FeedTableViewController: UITableViewController {
	//MARK: - Variables
	var networkManager: NetworkManager!
	let queries: [Int : Categories] = Services.createSubjectQueriesWithIndex(queries: .fiction, .fantasy, .scifi, .food, .kids, .mystery, .crime, .business, .historicalFiction)

	var booksArray: [Int : [Book]] = [ : ]
    var storedOffsets = [Int: CGFloat]()

	//MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
		networkManager = NetworkManager()
		Navbar.addImage(to: self)
		for i in 0..<queries.count {
			Services.shared.getBooks(from: .google, searchParameter: "subject:\"\(queries[i]!.parameterValue())\"") { (books) in
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
		return queries[section]?.headerDescription() ?? "books"
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
		cell.coverImage.image = nil
		if let book = booksArray[collectionView.tag]?[indexPath.row] {
			let url = Services.getBookImageURL(apiSource: book.apiSource, identifier: book.id)
			cell.coverImage.sd_setImage(with: url) { (image, error, cache, url) in
				self.booksArray[collectionView.tag]?[indexPath.row].image = UIImagePNGRepresentation(image!)
			}
		}
		return cell
	}
}

//MARK: - UICollectionViewDelegate
extension FeedTableViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let vc = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
		if let book = booksArray[collectionView.tag]?[indexPath.item] {
			vc.book = book
			present(vc, animated: true)
		}
	}
}

//MARK: - UI
extension FeedTableViewController {

	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		let header = view as! UITableViewHeaderFooterView
		header.textLabel?.font = UIFont(name: "Futura-Medium", size: 13)
		header.textLabel?.textColor = UIColor.white
		header.contentView.backgroundColor = UIColor(hexString: "70719A")
	}

	//Footer Height
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 20
	}
}


