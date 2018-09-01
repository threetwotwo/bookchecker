//
//  DetailViewController.swift
//  bookchecker
//
//  Created by Gary on 8/18/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import Cosmos
import RealmSwift
import Alamofire

class DetailViewController: UIViewController {
	//MARK: - IBOutlets
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var authorLabel: UILabel!
	@IBOutlet weak var coverImage: UIImageView!
	@IBOutlet weak var publisherLabel: UILabel!
	@IBOutlet weak var publishedDateLabel: UILabel!
	@IBOutlet weak var categoryLabel: UILabel!
	@IBOutlet weak var ratingBar: CosmosView!
	@IBOutlet weak var ratingCountLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var descriptionHeaderLabel: UILabel!
	@IBOutlet weak var previewButton: UIButton!
	@IBOutlet weak var downloadButton: LoadingButton!
	@IBOutlet weak var favoriteButton: UIButton!
	@IBOutlet weak var apiSourceButton: DesignableButton!
	
	//MARK: - IBActions
	@IBAction func previewButtonPressed(_ sender: UIButton) {
		let vc = storyboard?.instantiateViewController(withIdentifier: "WebReaderVC") as! WebReaderViewController
		guard let previewURL = URL(string: book.readerLink.replacingOccurrences(of: "gbs_api", with: "kp_read_button")) else {
			return
		}
		vc.previewLink = previewURL
		//Turn reader to page 1
		vc.previewLink.setValue(forKey: "pg", to: "PA1")
		navigationController?.pushViewController(vc, animated: true)
	}
	
	@IBAction func getBookButtonPressed(_ sender: UIButton) {
		let vc = storyboard?.instantiateViewController(withIdentifier: "PopUpVC") as! PopUpViewController
		vc.bookIdentifier = book.id
		vc.title = book.title
		vc.fileNames = book.downloadLinks
		self.present(vc, animated: true)

	}

	@IBAction func favoriteButtonPressed(_ sender: UIButton) {
		saveToFavorites(book: book)
		Alert.createAlert(self, title: "Book added!", message: nil)
	}

	//MARK: - variables
	let realm = try! Realm()
	var book: Book!
	lazy var bookIDs: [String] = []
	var docController: UIDocumentInteractionController?

	//MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
		downloadButton.showLoading()
		Services.shared.getDownloadLinks(book: book) { (links) in
			self.downloadButton.hideLoading()
			self.book.downloadLinks = links
			self.downloadButton.isHidden = self.book.downloadLinks.isEmpty ? true : false
			print(links)
		}
    }

	override func viewWillAppear(_ animated: Bool) {
		updateUI()
	}

	//MARK: - Update UI
	func updateUI() {
		apiSourceButton.setTitle(book.apiSource, for: [])
		titleLabel.text = book.title
		authorLabel.text = book.authors
		publisherLabel.text = book.publisher == "" ? "Unknown Publisher" : book.publisher
		publishedDateLabel.text = book.publishedDate
		categoryLabel.text = book.categories

		if book.ratingsCount == "" {
			ratingBar.isHidden = true
			ratingCountLabel.isHidden = true
		} else {
			ratingBar.rating = Double(book.averageRating) ?? 0
			ratingCountLabel.text = "(\(book.ratingsCount))"
		}

		previewButton.isHidden = book.readerLink == "" ? true : false
		descriptionHeaderLabel.text = book.about == "" ? "No description" : "Description"

		descriptionLabel.text = book.about
		categoryLabel.text =  book.categories
		if let image = book.image {
			coverImage.image = UIImage(data: image)
		}
	}
}

//MARK: - Realm
extension DetailViewController {

	func saveToFavorites(book: Book) {
		//Check if book has already been added
		bookIDs = DBManager.shared.getBooks().map{$0.id}
		guard !bookIDs.contains(book.id) else {
			Alert.createAlert(self, title: "Book has already been added!", message: nil)
			return
		}
		let realmBook = RealmBook(book: book)

		DBManager.shared.addBook(object: realmBook)
	}
}
