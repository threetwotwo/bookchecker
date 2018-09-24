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
	var queries: [Int : Categories] = Services.createSubjectQueriesWithIndex(queries: .savedCollection, .scifi, .fantasy, .food, .crime, .business, .kids)

	var savedBooks: Results<RealmBook>?
	var booksArray: [Int : [Book]] = [ : ]
	var booksCollection: [[Book]?] = []
    var storedOffsets = [Int: CGFloat]()
//	var collectionTags = Set<Int>()

	override func viewDidLoad() {
        super.viewDidLoad()
		networkManager = NetworkManager()
		booksCollection = [[Book]?](repeating: nil, count: queries.count)
//		addSwipeGesturesForSwitchingTabs()
    }


	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
		loadSavedBooks(0)
	}

	//MARK: - Data Fetching
	fileprivate func loadSavedBooks(_ index: Int) {
		savedBooks = DBManager.shared.getBooks().filter("lastOpened != nil").sorted(byKeyPath: "lastOpened", ascending: false)
		var books = [Book]()
		guard let savedBooks = savedBooks else {return}
		for savedBook in savedBooks {
			books.append(Book(realmBook: savedBook))
		}
		booksCollection[index] = books
		self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
	}

	func fetchBooks(ofIndex index: Int) {
		let category = queries[index]

		guard category != .savedCollection else {
			loadSavedBooks(index)
			return
		}
		Services.shared.getBooks(from: .google, searchParameter: "subject:\"\(category!.parameterValue())\"") { (books) in
			print("Fetched books for category \(category?.parameterValue())!!!")
			self.booksArray[index] = books
			self.booksCollection[index] = books
			let indexPath = IndexPath(row: 0, section: index)
			// check if the row of news which we are calling API to retrieve is in the visible rows area in screen
			// the 'indexPathsForVisibleRows?' is because indexPathsForVisibleRows might return nil when there is no rows in visible area/screen
			// if the indexPathsForVisibleRows is nil, '?? false' will make it become false
			if self.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
				// if the row is visible (means it is currently empty on screen, refresh it with the loaded data with fade animation
				self.tableView.reloadRows(at: [IndexPath(row: 0, section: index)], with: .automatic)
			}
		}
	}

	//MARK: - UITableViewDataSource
	override func numberOfSections(in tableView: UITableView) -> Int {
		return booksCollection.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedTableViewCell
		return cell
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

		guard let cell = cell as? FeedTableViewCell else {return}
		let index = indexPath.section
		cell.setCollectionViewDataSourceDelegate(self, forRow: index)
		cell.collectionViewOffset = storedOffsets[index] ?? 0
		cell.feedCollection.tag = index

		if index == 0 {
			cell.collectionViewOffset = 0
		}
		if booksCollection[index] == nil {
			fetchBooks(ofIndex: index)
		}
	}

	override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let cell = cell as! FeedTableViewCell
		storedOffsets[indexPath.section] = cell.collectionViewOffset
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return queries[section]?.headerDescription() ?? "books"
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if queries[section] == .savedCollection && savedBooks?.isEmpty ?? true {
			return 0
		}
		return tableView.sectionHeaderHeight
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if queries[indexPath.section] == .savedCollection && savedBooks?.isEmpty ?? true{
			return 0
		} else {
			return tableView.rowHeight
		}
	}
}

//MARK: - UITableViewDataSourcePrefetching
extension FeedTableViewController: UITableViewDataSourcePrefetching {
	func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		for indexPath in indexPaths {
			fetchBooks(ofIndex: indexPath.section)
		}
	}
}

//MARK: - UICollectionViewDataSource
extension FeedTableViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return booksCollection[collectionView.tag]?.count ?? 0
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCollectionCell", for: indexPath) as! FeedCollectionViewCell
		cell.coverImage.image = nil
		if let book = booksCollection[collectionView.tag]?[indexPath.row] {
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


