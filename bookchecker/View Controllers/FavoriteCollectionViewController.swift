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

class FavoriteCollectionViewController: UICollectionViewController {
	//MARK: - IBAction
	@IBAction func deleteAll(_ sender: Any) {
		DBManager.shared.deleteAll()
		collectionView?.reloadData()
	}

	//MARK: - Variables
	let realm = try! Realm()
	var books: Results<RealmBook>?

	//MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		collectionView?.delegate = self
		Navbar.addImage(to: self)
    }

	override func viewDidAppear(_ animated: Bool) {
		loadBooks()
	}

    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return books?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FavoriteCollectionViewCell
		cell.coverImage.image = nil
		if let book = books?[indexPath.item],
		let imageData = book.image{
			cell.coverImage.image = UIImage(data: imageData)
		}
        return cell
    }

	//MARK: - UICollectionViewDelegate
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
		books = realm.objects(RealmBook.self)
		collectionView?.reloadData()
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
