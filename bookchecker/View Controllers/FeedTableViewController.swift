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
	let queries: [Int : Categories] = Services.createSubjectQueriesWithIndex(queries: .savedCollection, .fantasy)
	var savedBooks: Results<RealmBook>?
	var booksArray: [Int : [Book]] = [ : ]
    var storedOffsets = [Int: CGFloat]()

	//MARK: - Life Cycle
	fileprivate func fetchBooks(tillSectionIndex index: Int) {
		savedBooks = DBManager.shared.getBooks().filter("lastOpened!=nil").sorted(byKeyPath: "lastOpened", ascending: false)
		print(savedBooks?.count)
		for i in 0..<index {
			if i == 0 {
				var books = [Book]()
				for savedBook in savedBooks! {
					books.append(Book(realmBook: savedBook))
					booksArray[i] = books
					print(booksArray[i]?.count)
					tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
				}
			} else {
				Services.shared.getBooks(from: .google, searchParameter: "subject:\"\(queries[i]!.parameterValue())\"") { (books) in
					self.booksArray[i] = books
					self.tableView.reloadRows(at: [IndexPath(row: 0, section: i)], with: .automatic)
				}
			}
		}
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		networkManager = NetworkManager()
		Navbar.addImage(to: self)
		fetchBooks(tillSectionIndex: queries.count)
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
		fetchBooks(tillSectionIndex: 1)
	}

	//MARK: - UITableViewDataSource
	override func numberOfSections(in tableView: UITableView) -> Int {
		return (savedBooks?.isEmpty)! ? queries.count : queries.count
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
//			vc.tabBarController?.tabBar.isHidden = true
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


