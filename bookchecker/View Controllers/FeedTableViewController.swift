//
//  FeedTableViewController.swift
//  bookchecker
//
//  Created by Gary on 8/13/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import SDWebImage
import RealmSwift

class FeedTableViewController: UITableViewController {
	//MARK: - Variables
	var networkManager: NetworkManager!
	var queries: [Int : Categories] = Services.createSubjectQueriesWithIndex(queries: .savedCollection, .fantasy, .crime, .food, .mystery, .business, .kids, .scifi)
	var savedBooks: Results<RealmBook>?
	var booksArray: [Int : [Book]] = [ : ]
    var storedOffsets = [Int: CGFloat]()
	var collectionTags = Set<Int>()
	var fetchMore = false

	//MARK: - Life Cycle
	fileprivate func fetchBooks(fromSectionIndex index: Int) {
		savedBooks = DBManager.shared.getBooks().filter("lastOpened!=nil").sorted(byKeyPath: "lastOpened", ascending: false)
		let categoriesToLoad = min(3, queries.count - index)
		for i in index..<categoriesToLoad + index{
			if i == 0 {
				var books = [Book]()
				for savedBook in savedBooks! {
					books.append(Book(realmBook: savedBook))
					booksArray[i] = books
				}
			} else {
				let stopIndex = i + index
				guard !collectionTags.contains(i) else {return}
				Services.shared.getBooks(from: .google, searchParameter: "subject:\"\(queries[i]!.parameterValue())\"") { (books) in
					self.booksArray[i] = books
					self.tableView.reloadData()
					print("Downloaded books for category: \(self.queries[i])!!!!")
				}
			}
		}
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		networkManager = NetworkManager()
		Navbar.addImage(to: self)
		fetchBooks(fromSectionIndex: 0)
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
		var books = [Book]()
		for savedBook in savedBooks! {
			books.append(Book(realmBook: savedBook))
			booksArray[0] = books
		}
		tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
	}

	//MARK: - UITableViewDataSource
	override func numberOfSections(in tableView: UITableView) -> Int {
		return booksArray.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return queries[section]?.headerDescription() ?? "books"
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if section == 0 && (savedBooks?.isEmpty)!{
			return 0
		} else {
			return tableView.sectionHeaderHeight
		}
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 0 && (savedBooks?.isEmpty)!{
			return 0
		} else {
			return tableView.rowHeight
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedTableViewCell
		return cell
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let lastItem = booksArray.count - 1
		if indexPath.section == lastItem {
			fetchBooks(fromSectionIndex: lastItem)
			print("Begin batch fetch")
		}
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
		let tag = collectionView.tag
		collectionTags.insert(tag)
		print(self.collectionTags)
		return booksArray[collectionView.tag]?.count ?? 0
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCollectionCell", for: indexPath) as! FeedCollectionViewCell
		cell.coverImage.image = nil
		if let book = booksArray[collectionView.tag]?[indexPath.row] {
			let url = Services.getBookImageURL(apiSource: book.apiSource, identifier: book.id)
			cell.coverImage.sd_setImage(with: url)
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
			navigationController?.pushViewController(vc, animated: true)
		}
	}
}

//MARK: - UI
extension FeedTableViewController {

	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		let header = view as! UITableViewHeaderFooterView
		header.textLabel?.font = UIFont(name: "Futura-Medium", size: 13)
		header.textLabel?.textColor = UIColor.init(hexString: "10165E")
	}

	//Footer Height
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 20
	}
}


