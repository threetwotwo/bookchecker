//
//  FavoriteCollectionViewController.swift
//  bookchecker
//
//  Created by Gary on 8/21/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import RealmSwift

private let reuseIdentifier = "FavoriteCollectionCell"

class FavoriteCollectionViewController: UIViewController {
	//MARK: - IBOutlets
	@IBOutlet weak var favoriteCollectionView: UICollectionView!
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var editButton: UIBarButtonItem!

	//MARK: - IBAction
	fileprivate func updateEditButtonTitle() {
		editButton.title = editMode ? "Done" : "Edit"
	}

	@IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
		editMode = !editMode
	}

	//Delete all books currently shown on screen
	@objc func deleteAll(sender: Any) {
		Alert.createAlertWithCancel(self, title: "Delete books?", message: nil) { (_) in
			guard let currentBooks = self.currentBooks else {return}
			DBManager.shared.deleteBooks(objects: currentBooks)
			self.favoriteCollectionView?.reloadData()
			self.editMode = false
		}
	}

	//MARK: - Variables
	let realm = try! Realm()
	var books: Results<RealmBook>?
	var currentBooks: Results<RealmBook>?
	var editMode = false {
		didSet {
			if editMode {
				self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Delete All", style: .plain, target: self, action: #selector(deleteAll(sender:)))
			} else {
				self.navigationItem.leftBarButtonItem = nil
			}
			updateEditButtonTitle()
			favoriteCollectionView?.reloadData()
		}
	}


	//MARK: - Life Cycle
	fileprivate func addTapGestureRecognizerToDismissKeyboard() {
		//Looks for single or multiple taps.
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))

		//Uncomment the line below if you want the tap not not interfere and cancel other interactions.
		tap.cancelsTouchesInView = false

		view.addGestureRecognizer(tap)
	}
	//Calls this function when the tap is recognized.
	@objc func dismissKeyboard() {
		//Causes the view (or one of its embedded text fields) to resign the first responder status.
		view.endEditing(true)
	}

    override func viewDidLoad() {
        super.viewDidLoad()
//		navigationController?.navigationBar.prefersLargeTitles = true
		setUpSearchbar()
		addTapGestureRecognizerToDismissKeyboard()
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
		loadBooks()
		currentBooks = books
	}

	override func viewWillDisappear(_ animated: Bool) {
		super .viewWillDisappear(true)
		editMode = false
	}
}

// MARK: UICollectionViewDataSource
extension FavoriteCollectionViewController: UICollectionViewDataSource {
	 func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of items
		if books?.count == 0 {
			collectionView.setEmptyMessage("Your collection is empty. Save books by pressing the favorite button.")
		} else {
			collectionView.restore()
		}
		return books?.count ?? 0
	}

	 func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FavoriteCollectionViewCell
		cell.coverImage.image = nil
		if let book = books?[indexPath.item],
			let imageData = book.image{
			cell.coverImage.image = UIImage(data: imageData)
			cell.bookID = book.id
			cell.deleteButton.addTarget(self, action: #selector(deleteButtonTapped(sender:)), for: .touchUpInside)
			if editMode {
				cell.deleteButton.isHidden = false
			} else {
				cell.deleteButton.isHidden = true
			}
		}
		return cell
	}

	@objc func deleteButtonTapped(sender: UIButton) {
		favoriteCollectionView.reloadData()
	}
}

//MARK: - UICollectionViewDelegate
extension FavoriteCollectionViewController: UICollectionViewDelegate {
	 func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		searchBar.resignFirstResponder()
		searchBar.text = nil
		let vc = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
		if let realmBook = books?[indexPath.item] {
			vc.book = Book(realmBook: realmBook)
			navigationController?.pushViewController(vc, animated: true)
		}
	}
}

//MARK: - Realm
extension FavoriteCollectionViewController {
	func loadBooks() {
		books = realm.objects(RealmBook.self).sorted(byKeyPath: "dateAdded", ascending: false)
		favoriteCollectionView?.reloadData()
	}

	func loadBooks(query: String) {
		books = realm.objects(RealmBook.self).sorted(byKeyPath: "dateAdded", ascending: false).filter("title CONTAINS[cd] %@ OR authors CONTAINS[cd] %@", query, query)
		currentBooks = books
		favoriteCollectionView?.reloadData()
	}
}
//MARK: - Search Bar
extension FavoriteCollectionViewController: UISearchBarDelegate {
	fileprivate func setUpSearchbar() {
		//remove borders
		searchBar.backgroundImage = UIImage()
		self.searchBar.setImage(UIImage(named: "search"), for: .search, state: [])
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		guard searchBar.text != "" else {
			loadBooks()
			return
		}
		loadBooks(query: searchBar.text!)
	}	

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
	}
}

//MARK: - UICollectionViewLayout

extension FavoriteCollectionViewController: UICollectionViewDelegateFlowLayout {

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		// Number of cells
		let collectionViewWidth = UIScreen.main.bounds.width/3 - 25
		let collectionViewHeight = collectionViewWidth

		return CGSize(width: collectionViewWidth, height: collectionViewHeight/5*8)
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 15
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 15
	}
}

