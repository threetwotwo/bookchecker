//
//  DetailViewController.swift
//  bookchecker
//
//  Created by Gary on 8/18/18.
//  Copyright © 2018 Gary. All rights reserved.
//
import AVFoundation
import UIKit
import Cosmos
import RealmSwift
import Alamofire

class DetailViewController: UIViewController {
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


	//MARK: - variables
	let realm = try! Realm()
	var book: Book! {
		didSet {
			if let imageData = book.image {
				image = UIImage(data: imageData)
			}
		}
	}
	var image: UIImage?
	lazy var bookIDs: [String] = []
	var docController: UIDocumentInteractionController?
	var savedBook: RealmBook?
	var viewWidth: CGFloat?

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
	}

	@IBAction func favoriteButtonPressed(_ sender: UIButton) {

		if let savedBook = savedBook {
			DBManager.shared.delete(object: savedBook)
			Alert.createAlert(self, title: "Book removed from favorites", message: nil)
		} else {
			saveToFavorites(book: book)
			Alert.createAlert(self, title: "Book added!", message: nil)
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
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)

		favoriteButton.imageView?.contentMode = .scaleAspectFit
		favoriteButton.imageEdgeInsets = UIEdgeInsetsMake(8, 7, 7, 7)

		if let image = image {
			let width = image.size.width
			let height = image.size.height
			let scaleFactor = coverImage.frame.width / width
			let adjustedHeight = height * scaleFactor
			imageHeight.constant = adjustedHeight
		}

		updateUI()
	}

	func resizedImage(sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage {
		let oldWidth = sourceImage.size.width
		let scaleFactor = scaledToWidth / oldWidth

		let newHeight = sourceImage.size.height * scaleFactor
		let newWidth = oldWidth * scaleFactor

		UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
		sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return newImage!
	}

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
		coverImage.image = image
		backgroundImage.image = image
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
