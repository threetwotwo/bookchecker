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
		0 :	"Potter",
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

		addNavBarImage()
		for i in 0..<queries.count {
			Services.shared.getBooks(from: Services.baseURL, params: ["q" : queries[i]!]) { (books) in
				self.booksArray[i] = books
				self.tableView.reloadData()
			}
		}
    }

	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		let header = view as! UITableViewHeaderFooterView
		header.textLabel?.font = UIFont(name: "Futura-Medium", size: 15)
		header.textLabel?.textColor = UIColor.black
		header.contentView.backgroundColor = UIColor.white
	}

	func addNavBarImage() {
		let navController = navigationController!

		let image = #imageLiteral(resourceName: "bookchecker_logo_happy")
		let imageView = UIImageView(image: image)

		let bannerWidth = navController.navigationBar.frame.size.width
		let bannerHeight = navController.navigationBar.frame.size.height

		let bannerX = bannerWidth / 2 - image.size.width / 2
		let bannerY = bannerHeight / 2 - image.size.height / 2

		imageView.frame = CGRect(x: bannerX, y: bannerY, width: 200, height: bannerHeight)
		imageView.contentMode = .scaleAspectFit

		navigationItem.titleView = imageView
	}


	//MARK: - UITableViewDataSource
	override func numberOfSections(in tableView: UITableView) -> Int {
		return queries.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return queries[section] ?? "books"
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

	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0
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
			Services.shared.getBookImage(from: book.thumbnail) { (image) in
				cell.coverImage.image = image
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
			navigationController?.pushViewController(vc, animated: true)
		}
	}
}



