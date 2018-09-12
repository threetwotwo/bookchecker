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
	var contentOffset: CGPoint?
	var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
	var searchImage: UIImage?

	//MARK: - Life cycle
	override func viewDidLoad() {
        super.viewDidLoad()
		removeSearchbarBorders()
		tableView.tableFooterView = UIView()
		Navbar.addImage(to: self)
		self.searchBar.setImage(#imageLiteral(resourceName: "searchglass"), for: .search, state: [])
		searchBar.delegate = self
		tabBarController?.delegate = self
    }

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(true)
		contentOffset = tableView.contentOffset
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
		let backgroundView = UIView()
		backgroundView.backgroundColor = UIColor.init(hexString: "e8f4f8")
		cell.selectedBackgroundView = backgroundView
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
			self.activityIndicator.stopAnimating()
			self.searchBar.setImage(#imageLiteral(resourceName: "searchglass"), for: .search, state: [])
		}
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		//throttle the url requests
	}

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		getBooksFromSearchbar()
		let textField = searchBar.value(forKey: "searchField") as? UITextField
		let searchIconView = textField?.leftView as? UIImageView
		if let searchIconView = searchIconView {
			searchImage = searchIconView.image
			searchIconView.image = nil
			activityIndicator.hidesWhenStopped = true
			activityIndicator.center = CGPoint(x: 7, y: 7)
			activityIndicator.startAnimating()
			searchIconView.addSubview(activityIndicator)
		}
	}
}

//MARK: - UITabBarDelegate
extension SearchTableViewController: UITabBarControllerDelegate {

	func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
		print("Selected: \(viewController)!")
		if let contentOffset = contentOffset {
			tableView.setContentOffset(contentOffset, animated: true)
		} else {
			self.tableView.setContentOffset(CGPoint(x: 0, y: -64), animated: true)
		}
		self.contentOffset = nil
	}
}
