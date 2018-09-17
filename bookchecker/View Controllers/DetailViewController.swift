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

	//MARK: - variables
	let realm = try! Realm()
	var book: Book!
	lazy var bookIDs: [String] = []
	var docController: UIDocumentInteractionController?
	var savedBook: RealmBook?

	//MARK: - IBOutlets
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var authorLabel: UILabel!
	@IBOutlet weak var backgroundImage: UIImageView!
	@IBOutlet weak var coverImage: UIImageView!
	@IBOutlet weak var publishedLabel: UILabel!
	@IBOutlet weak var categoryLabel: UILabel!
	@IBOutlet weak var languageLabel: UILabel!
	@IBOutlet weak var pageCountLabel: UILabel!
	@IBOutlet weak var ratingBar: CosmosView!
	@IBOutlet weak var ratingCountLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var readOrDownloadButton: LoadingButton!
	@IBOutlet weak var favoriteButton: UIButton!
	@IBOutlet weak var apiSourceButton: UIButton!
	@IBOutlet weak var languageStackView: UIStackView!
	@IBOutlet weak var pagesStackView: UIStackView!
	
	@IBOutlet weak var imageHeight: NSLayoutConstraint!

	//MARK: - IBActions
	@IBAction func cancelButtonPressed(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction func apisourceButtonPressed(_ sender: Any) {
		if book.infoLink != "" {
			let vc = storyboard?.instantiateViewController(withIdentifier: "WebReaderVC") as! WebReaderViewController
			guard let url = URL(string: book.infoLink) else {
				return
			}
			vc.previewLink = url
			//Turn reader to page 1 or the most current page
			present(vc, animated: true)
		}
	}

	@IBAction func readOrDownloadButtonPressed(_ sender: Any) {
		if book.readerLink != "" {
			let vc = storyboard?.instantiateViewController(withIdentifier: "WebReaderVC") as! WebReaderViewController
			guard let url = URL(string: book.readerLink) else {
				return
			}
			vc.bookID = book.id
			vc.previewLink = url
			//Turn reader to page 1 or the most current page
			vc.previewLink.setValue(forKey: "pg", to: savedBook?.currentPage == "" ? "PA1" : savedBook?.currentPage ?? "PA1")
			present(vc, animated: true)
		} else {
			let vc = storyboard?.instantiateViewController(withIdentifier: "PopUpVC") as! PopUpViewController
			vc.bookIdentifier = book.id
			vc.bookTitle = book.title
			vc.fileNames = book.downloadLinks
			self.present(vc, animated: true)
		}

		if let savedBook = savedBook {
			try! Realm().write {
				savedBook.lastOpened = Date()
			}
		}
	}

	@IBAction func favoriteButtonPressed(_ sender: UIButton) {

		if let savedBook = savedBook {
			DBManager.shared.delete(object: savedBook)
			Alert.showMessage(theme: .warning, title: "Book removed from favorites", body: nil, displayDuration: 1)
//			Alert.createAlert(self, title: "Book removed from favorites", message: nil)
		} else {
			saveToFavorites(book: book)
			Alert.showMessage(theme: .warning, title: "Book saved!", body: nil, displayDuration: 1)
//			Alert.createAlert(self, title: "Book added!", message: nil)
		}
		loadSavedBook()
		updateButtons()
	}

	//MARK: - Life cycle
	fileprivate func loadSavedBook() {
		savedBook = DBManager.shared.getBooks().filter("id == '\(book.id)'").first
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		loadSavedBook()
		let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
		swipeRight.direction = .right
		self.view.addGestureRecognizer(swipeRight)
    }

	@objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
		if gesture.direction == UISwipeGestureRecognizerDirection.right {
			print("Swipe Right")
			self.navigationController?.popViewController(animated: true)
		}
		else if gesture.direction == UISwipeGestureRecognizerDirection.left {
			print("Swipe Left")
		}
		else if gesture.direction == UISwipeGestureRecognizerDirection.up {
			print("Swipe Up")
		}
		else if gesture.direction == UISwipeGestureRecognizerDirection.down {
			print("Swipe Down")
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		//center the favorite icon 
		favoriteButton.imageView?.contentMode = .scaleAspectFit
		favoriteButton.imageEdgeInsets = UIEdgeInsetsMake(8, 7, 7, 7)
		adjustImageHeight()
		updateUI()
	}

//	override func viewWillDisappear(_ animated: Bool) {
//		if let savedBook = savedBook {
//			try! Realm().write {
//				savedBook.lastOpened = Date()
//			}
//		}
//	}

	//MARK: - UI
	fileprivate func updateButtons() {
		if book.readerLink != "" {
			savedBook?.currentPage == nil || savedBook?.currentPage == "" ? readOrDownloadButton.setTitle("READ ONLINE", for: []) : readOrDownloadButton.setTitle("CONTINUE", for: [])
		} else {
			readOrDownloadButton.showLoading()
			Services.shared.getDownloadLinks(book: book) { (links) in
				self.readOrDownloadButton.hideLoading()
				self.book.downloadLinks = links
				self.readOrDownloadButton.setTitle("DOWNLOAD", for: [])
				print(links)
			}
		}

		savedBook == nil ? favoriteButton.setImage(#imageLiteral(resourceName: "baseline_favorite_border_white_36pt_1x"), for: []) : favoriteButton.setImage(#imageLiteral(resourceName: "baseline_favorite_white_36pt_1x"), for: [])
	}

	fileprivate func adjustImageHeight() {
		if let image = coverImage.image {
			let width = image.size.width
			let height = image.size.height
			let scaleFactor = coverImage.frame.width / width
			let adjustedHeight = height * scaleFactor
			imageHeight.constant = adjustedHeight
		}
	}

	func updateUI() {
		apiSourceButton.setTitle(book.apiSource, for: [])
		titleLabel.text = book.title
		authorLabel.text = book.authors
		let publisher = book.publisher == "" ? "" : "· \(book.publisher)"
		publishedLabel.text = "\(book.publishedDate) \(publisher)"
		categoryLabel.text = book.categories

		if book.language == "" {
			languageStackView.isHidden = true
		} else {
			languageLabel.text = book.language
		}

		if book.pageCount == "" {
			pagesStackView.isHidden = true
		} else {
			pageCountLabel.text = book.pageCount
		}

		if book.ratingsCount == "" {
			ratingBar.isHidden = true
			ratingCountLabel.isHidden = true
		} else {
			ratingBar.rating = Double(book.averageRating) ?? 0
			ratingCountLabel.text = book.ratingsCount == "1" ?  "\(book.ratingsCount) review" : "\(book.ratingsCount) reviews"
		}

		updateButtons()

		descriptionLabel.text = book.about == "" ? "No description" : book.about
		categoryLabel.text =  book.categories
		let url = Services.getBookImageURL(apiSource: book.apiSource, identifier: book.id)
		coverImage.sd_setImage(with: url) { (image, _, _, _) in
			self.adjustImageHeight()
			self.backgroundImage.image = image
			self.book.image = UIImagePNGRepresentation(image ?? UIImage())
			self.view.layoutIfNeeded()
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
