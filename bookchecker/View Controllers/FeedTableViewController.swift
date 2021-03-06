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
import Alamofire
import SVProgressHUD

class FeedTableViewController: UITableViewController {

	//MARK: - Variables
	var queries: [Int : Category] = Services.createSubjectQueriesWithIndex(queries: .savedCollection,
   .fiction,
   .youngadult,
   .fantasy,
   .scifi,
   .crime,
   .romance,
   .food,
   .selfhelp,
   .business,
   .mystery,
   .historicalFiction,
   .kids,
   .comicshumor,
   .comicsmanga,
   .freemanga,
   .comicssuperheroes,
   .freecomics,
   .freemagazines,
   .horror,
   .classics)
	var savedBooks: Results<RealmBook>?
	var booksArray: [[Book]?] = []
	var storedOffsets = [Int: CGFloat]()
	var fetchCount: Int = 0
	let reachabilityManager = NetworkReachabilityManager()

	func startNetworkReachabilityObserver() {

		reachabilityManager?.listener = { status in
			switch status {
			case .notReachable:
				print("The network is not reachable")
			case .unknown :
				print("It is unknown whether the network is reachable")
			case .reachable:
				print("The network is reachable")
				self.tableView.reloadData()
			}
		}
		// start listening
		reachabilityManager?.startListening()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		startNetworkReachabilityObserver()
		booksArray = [[Book]?](repeating: nil, count: queries.count)
		UserDefaults.standard.addObserver(self, forKeyPath: "matureContent", options: NSKeyValueObservingOptions.new, context: nil)
	}

	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

		//Refetch sections that has mature content
		print("Changed mature setting")

		let sectionsWithMatureContent = [15, 17, 18]
		for section in sectionsWithMatureContent {
			self.fetchBooks(ofIndex: section, from: .archive)
			SVProgressHUD.dismiss()
		}
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
		booksArray[index] = books
		self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
	}

	func fetchBooks(ofIndex index: Int, from apiSource: APISource = .google) {
		let category = queries[index]

		guard category != .savedCollection else {
			loadSavedBooks(index)
			return
		}
		SVProgressHUD.show()
		Services.shared.getBooksFromCategory(category: category ?? .fiction, from: apiSource) { (books) in
//			print("Fetched books for category \(category?.headerDescription())!!!")
			self.booksArray[index] = books
			SVProgressHUD.dismiss()
			let indexPath = IndexPath(row: 0, section: index)
			// check if the row of news which we are calling API to retrieve is in the visible rows area in screen
			// the 'indexPathsForVisibleRows?' is because indexPathsForVisibleRows might return nil when there is no rows in visible area/screen
			// if the indexPathsForVisibleRows is nil, '?? false' will make it become false
			if self.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
				// if the row is visible (means it is currently empty on screen, refresh it with the loaded data with fade animation
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

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedTableViewCell
		let index = indexPath.section
		cell.setCollectionViewDataSourceDelegate(self, forRow: index)
		cell.collectionViewOffset = storedOffsets[index] ?? 0
		cell.feedCollection.tag = index

		if index == 0 {
			cell.collectionViewOffset = 0
		}
		guard reachabilityManager?.isReachable ?? true else {return cell}
		let fetchCount = booksArray.compactMap{$0}.count
//		print("index = \(index), fetchCount = \(fetchCount)")
		if index == fetchCount,
			booksArray[index] == nil {
			booksArray[index] = []
			if queries[index]?.headerDescription().contains("Free") ?? false {
					fetchBooks(ofIndex: index, from: .archive)
			} else {
				fetchBooks(ofIndex: index)
			}
		}
		return cell
	}

	override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let cell = cell as! FeedTableViewCell
		storedOffsets[indexPath.section] = cell.collectionViewOffset
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard let header = queries[section]?.headerDescription() else {
			return "Books"
		}
		return header
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if booksArray[section]?.isEmpty ?? true {
			return 0
		}
		return tableView.sectionHeaderHeight
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if booksArray[indexPath.section]?.isEmpty ?? true{
			return 0
		} else {
			return tableView.rowHeight
		}
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
			cell.authorLabel.text = book.authors
			cell.titleLabel.text = book.title
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
		return 0
	}
}


