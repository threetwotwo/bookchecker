//
//  SearchTableViewController.swift
//  bookchecker
//
//  Created by Gary on 8/16/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import SDWebImage

class SearchTableViewController: UITableViewController {

	//MARK: - IBOutlets
	@IBOutlet weak var searchBar: UISearchBar!
	
	//MARK: - variables
	var books: [Book] = []
	var timer: Timer?

	//MARK: - Life cycle
	override func viewDidLoad() {
        super.viewDidLoad()
		removeSearchbarBorders()
		Navbar.addImage(to: self)
		searchBar.delegate = self
    }

    // MARK: - UITableViewDataSource
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return books.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchTableViewCell
		cell.coverImage.image = nil
		let book = books[indexPath.row]
		cell.apiSourceButton.setTitle(book.apiSource, for: [])
		cell.titleLabel.text = book.title
		cell.authorLabel.text = book.authors
		let url = Services.getBookImageURL(apiSource: book.apiSource, identifier: book.id)
		cell.coverImage.sd_setImage(with: url) { (image, error, cache, url) in
			self.books[indexPath.row].image = UIImagePNGRepresentation(image ?? UIImage())
		}
		return cell
	}

	//MARK: - UITableViewDelegate
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
			vc.book = books[indexPath.row]
			present(vc, animated: true)
	}

}

//MARK: - Search bar methods
extension SearchTableViewController: UISearchBarDelegate {
	fileprivate func removeSearchbarBorders() {
		searchBar.backgroundImage = UIImage()
	}

	@objc func getBooksFromSearchbar() {
		Services.shared.getBooks(from: .archive, .google, searchParameter: searchBar.text!) { (books) in
			self.books = books
			self.tableView.reloadData()
		}
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		//throttle the url requests
	}

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		getBooksFromSearchbar()
	}
}
