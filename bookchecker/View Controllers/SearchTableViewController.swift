//
//  SearchTableViewController.swift
//  bookchecker
//
//  Created by Gary on 8/16/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController {

	//MARK: - IBOutlets
	@IBOutlet weak var searchBar: UISearchBar!
	
	//MARK: - variables
	var books: [Book] = []
	var timer: Timer?

	override func viewDidLoad() {
        super.viewDidLoad()
		searchBar.delegate = self
    }

    // MARK: - UITableViewDataSource
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return books.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchTableViewCell
		let book = books[indexPath.row]
		cell.titleLabel.text = book.title
		cell.authorLabel.text = book.authors
		Services.shared.getBookImage(from: book.thumbnail) { (image) in
			cell.coverImage.image = image
		}
		return cell
	}

	//MARK: - UITableViewDelegate
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
			vc.book = books[indexPath.row]
			navigationController?.pushViewController(vc, animated: true)
	}

}

//MARK: - Search bar methods

extension SearchTableViewController: UISearchBarDelegate {

	@objc func getBooksFromSearchbar() {
		Services.shared.getBooks(from: Services.baseURL, params: ["q" : searchBar.text!]) { (books) in
			self.books = books
			self.tableView.reloadData()
		}
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		//throttle the url requests
		timer?.invalidate()
		timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(getBooksFromSearchbar), userInfo: nil, repeats: false)
	}

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		getBooksFromSearchbar()
	}
}
