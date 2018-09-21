//
//  SearchTableViewController.swift
//  bookchecker
//
//  Created by Gary on 8/16/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import SDWebImage

class SearchTableViewController: UIViewController, UIScrollViewDelegate {

	//MARK: - IBOutlets
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var searchTableView: UITableView!

	//MARK: - variables
	var books: [Book] = []
	var timer: Timer?
	var contentOffset: CGPoint?
	var activityIndicator = UIActivityIndicatorView(style: .gray)
	var searchImage: UIImage?
	var imageManager = SDWebImageManager.shared()
	var fetchMore = false


	//MARK: - Life cycle
	fileprivate func addTapGestureRecognizer() {
		//Looks for single or multiple taps.
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))

		//Uncomment the line below if you want the tap not not interfere and cancel other interactions.
		//tap.cancelsTouchesInView = false

		view.addGestureRecognizer(tap)
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		setUpSearchbar()
		searchTableView.tableFooterView = UIView()
		Navbar.addImage(to: self)
		searchTableView.delegate = self
		addTapGestureRecognizer()
    }

	//Calls this function when the tap is recognized.
	@objc func dismissKeyboard() {
		//Causes the view (or one of its embedded text fields) to resign the first responder status.
		view.endEditing(true)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		tabBarController?.delegate = self
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(true)
		tabBarController?.delegate = nil
		contentOffset = searchTableView.contentOffset
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let offsetY = searchTableView.contentOffset.y
		let contentHeight = searchTableView.contentSize.height
		if offsetY > contentHeight - scrollView.frame.height {
			if !fetchMore {
				beginBatchFetch()
			}
		}
	}

	func beginBatchFetch() {
//		fetchMore = true
//		print("Begin batch fetch")
//		var additionalBooks: [Book] = []
//		if (Services.cachedBooks[.archive]?.isEmpty)! {
//			print("No more books to fetch")
//			return
//		} else {
//			additionalBooks = Services.shared.extractBooks(from: Services.cachedBooks, searchParameter: searchBar.text!)
//			books += additionalBooks
//
//			let indexPaths = (books.count - additionalBooks.count ..< books.count)
//				.map { IndexPath(row: $0, section: 0) }
//			searchTableView.insertRows(at: indexPaths, with: .bottom)
//			fetchMore = false
//		}
	}
}

//MARK: - UITableViewDelegate
extension SearchTableViewController: UITableViewDelegate {

	 func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
		vc.book = books[indexPath.row]
		navigationController?.pushViewController(vc, animated: true)
		tableView.deselectRow(at: indexPath, animated: true)
	}

}

// MARK: - UITableViewDataSource
extension SearchTableViewController: UITableViewDataSource {

	 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if books.count == 0 {
			self.searchTableView.setEmptyMessage("Search for books, magazines, papers and more")
		} else {
			self.searchTableView.restore()
		}
		return books.count
	}

	 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchTableViewCell
		cell.coverImage.image = nil

		//Highlight color when cell is selected
		let backgroundView = UIView()
		backgroundView.backgroundColor = UIColor.init(hexString: "e8f4f8")
		cell.selectedBackgroundView = backgroundView
		return cell
	}

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let cell = cell as! SearchTableViewCell
		let book = books[indexPath.row]
		cell.apiSourceButton.text = book.apiSource
		cell.titleLabel.text = book.title
		cell.authorLabel.text = book.authors
		let url = Services.getBookImageURL(apiSource: book.apiSource, identifier: book.id)

		cell.coverImage.sd_setImage(with: url)
	}
}

//MARK: - Search bar methods
extension SearchTableViewController: UISearchBarDelegate {
	fileprivate func setUpSearchbar() {
		//remove borders
		searchBar.backgroundImage = UIImage()
		self.searchBar.setImage(UIImage(named: "search"), for: .search, state: [])
	}

	fileprivate func hideActivityIndicator() {
		let textField = searchBar.value(forKey: "searchField") as? UITextField
		let searchIconView = textField?.leftView as? UIImageView
		if let searchIconView = searchIconView {
			searchIconView.image = searchImage
		}
	}

	@objc func getBooksFromSearchbar() {
		Services.shared.getBooks(from: .archive, .google, searchParameter: searchBar.text!) { (books) in
			self.books = books
			self.searchTableView.reloadData()
			self.activityIndicator.stopAnimating()
			self.hideActivityIndicator()
		}
		self.searchTableView.setContentOffset(CGPoint.zero, animated: true)
	}

	fileprivate func showActivityIndicator() {
		//Show activity indicator
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

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()

		guard searchBar.text != "" else {return}
		getBooksFromSearchbar()
		showActivityIndicator()
	}
}

//MARK: - UITabBarDelegate
extension SearchTableViewController: UITabBarControllerDelegate {

	func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
		print("Selected: \(viewController)!")
		if let contentOffset = contentOffset {
			searchTableView.setContentOffset(contentOffset, animated: true)
		} else {
			self.searchTableView.setContentOffset(CGPoint.zero, animated: true)
		}
		self.contentOffset = nil
	}
}
