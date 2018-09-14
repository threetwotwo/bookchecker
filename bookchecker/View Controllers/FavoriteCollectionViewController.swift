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
	
	//MARK: - IBAction
	@IBAction func deleteAll(_ sender: Any) {
		DBManager.shared.deleteAll()
		favoriteCollectionView?.reloadData()
	}

	//MARK: - Variables
	let realm = try! Realm()
	var books: Results<RealmBook>?

	//MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		Navbar.addImage(to: self)
		setUpSearchbar()
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
		loadBooks()
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
		}
		return cell
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
		favoriteCollectionView?.reloadData()
	}
}
//MARK: - Search Bar
extension FavoriteCollectionViewController: UISearchBarDelegate {
	fileprivate func setUpSearchbar() {
		//remove borders
		searchBar.backgroundImage = UIImage()
		self.searchBar.setImage(#imageLiteral(resourceName: "searchglass"), for: .search, state: [])
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

